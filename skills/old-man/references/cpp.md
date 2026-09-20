# C++

Modern C++, using what the standard library already solves — but without
adding language machinery that solves no real problem.

## Naming

- One namespace per module, public symbols inside it: `cfg::load_kv()`.
- Types in `PascalCase` (`HttpRequest`), functions and variables in
  `snake_case`, compile-time constants in `kPascalCase` or
  `SCREAMING_SNAKE` — pick one and keep it across the project.
- Private members with a `_` suffix (`count_`, `capacity_`), so inside a
  method body they are distinguishable from a local without hunting for
  the declaration.
- No Hungarian type prefixes (`pBuffer`, `iCount`): the type is already
  in the declaration and the compiler checks it.

## Resource management — RAII

The SKILL's rule says every resource has a single deterministic release
point tied to the lifetime of its owner. The destructor *is* that point:
you write it once and can no longer forget it, not even when an
exception cuts the flow in half.

- No loose `new`/`delete` in application code. A resource lives inside a
  type that releases it in its destructor: `std::vector`, `std::string`,
  `std::fstream`, `std::unique_ptr`, `std::lock_guard`.
- `std::unique_ptr` by default for exclusive ownership. `std::shared_ptr`
  only when ownership is genuinely shared and you cannot determine who
  dies last — not as a way to avoid thinking about who the owner is.
- An API that hands you a raw handle and its release function is used
  exactly as it comes, with its acquire-and-release pattern. Wrapping it
  in a new type to "make it more C++" is a layer that adds nothing, and
  the premature-abstraction rule forbids it like any other.

```cpp
// good — acquired and released here, the whole flow is in view
void dump_config(const char* path) {
    FILE* f = fopen(path, "r");
    if (!f) return;
    print_contents(f);
    fclose(f);
}
```

## Errors

By default the function returns the failure type and the caller checks
it on the spot. Exceptions exist and in some cases are the right tool,
but they are not the default path.

- For a function that can fail in predictable, expected ways (parsing an
  input, looking up something that may not be there, opening a file that
  may not exist): return the result or the error in the return value —
  `std::expected<T, Error>` in C++23, `std::optional<T>` if the only
  possible failure is "not there", or your own error enum class.
- The error goes in an `enum class`, not a loose `int`: the compiler
  forces you to name it and it does not blend in with other integers.
- Save exceptions for what is genuinely exceptional: failures the
  surrounding code can do nothing useful about, and that you want to
  travel several levels up to a handling point. A constructor that
  cannot leave the object in a valid state is also a legitimate case,
  because it has no return value.
- If you throw, throw your own types derived from `std::exception`, with
  the same differentiated-errors logic as the SKILL: whoever catches has
  to be able to tell the failure types apart.
- Catch by const reference (`catch (const ConfigError& e)`), never by
  value.
- Do not use exceptions as ordinary control flow. If the "failure"
  happens in half the cases, it is not exceptional: it is a result, and
  it goes in the return value.

```cpp
// bad — exception for an expected, frequent case
int parse_port(std::string_view text) {
    if (text.empty()) throw std::runtime_error("empty");
    // ...
}

// good — the expected failure travels in the return type
enum class ParseError { Empty, NotANumber, OutOfRange };

std::expected<uint16_t, ParseError> parse_port(std::string_view text) {
    if (text.empty()) return std::unexpected(ParseError::Empty);
    // ...
}
```

## Control flow

- Validations of the same value are combined into one condition, just as
  in the rest of the skill.
- `if` with initializer to scope a temporary to the `if` that uses it:
  `if (auto it = map.find(key); it != map.end())`.
- A loop's exit condition goes in the header. A range-for
  (`for (const auto& item : items)`) is only for traversing everything;
  if there is a conditional exit, use a `while` or a `for` with a
  condition.
- Before writing a loop by hand, check whether an `<algorithm>` already
  does it: `std::find_if`, `std::any_of`, `std::count_if`. The
  algorithm's name states the intent better than the loop does, and the
  stopping condition ends up inside the call instead of in a `break`.

```cpp
// bad — manual loop with a break hiding the stopping condition
const Provider* found = nullptr;
for (const auto& p : providers) {
    if (p.matches(selector)) { found = &p; break; }
}

// good — the stopping condition is in the call
auto it = std::find_if(providers.begin(), providers.end(),
                       [&](const Provider& p) { return p.matches(selector); });
```

## Const and parameters

`const` goes where it communicates something the reader cannot take for
granted — real constants and parameters. Putting it on every local is
noise: nobody doubts that a three-line temporary is not modified.

- **Parameters** are where it pays off most, because the caller does not
  see the body. Pass by `const&` what is expensive to copy; by value
  what is cheap (primitives, `std::string_view`, `std::span`); and by
  value + `std::move` when the function keeps a copy.
- `std::string_view` and `std::span` take read-only data without owning
  it — they avoid the copy without leaving raw pointers in the
  signature.
- On non-mutating methods, the trailing `const` is established language
  convention.

## Classes

- A class exists for invariants: a set of data that has to change
  together or satisfy a rule. If it is just a group of fields with no
  rules, it is a `struct` with public members, and that is fine.
- No trivial getters and setters for every field. If a field is read and
  written freely from outside, it is public, and the class saves two
  one-line functions (which the SKILL's rule forbids anyway).
- Prefer composition to inheritance. Save inheritance for a real "is a"
  with a polymorphic interface, and there the base class carries a
  virtual destructor.
- No inheritance hierarchy just to reuse a couple of methods: that is a
  free function or a composed member.

## Templates

- Write the concrete version first. Turn it into a template when the
  second real type that needs it shows up, not before — it is the
  SKILL's same premature-abstraction rule, and here the cost of getting
  it wrong is worse: enormous error messages and compile times that go
  through the roof.
- If the template expects the type to satisfy something, say so with a
  concept (`template <std::integral T>`) instead of letting it fail
  inside with a twenty-line instantiation error.

## Comments

Same as the rest of the skill: the name and the types do the work. Here
the types say a lot on their own: `std::unique_ptr<Conn>` declares
ownership, `const&` declares that it is not modified, an `enum class`
declares the domain. When the signature says it, the comment is
redundant.

The exception is the same one: the header that exposes a public API to
consumers who will not see the implementation carries proper
documentation. An internal header of the same project does not.

## Efficiency

- `reserve()` before filling a `std::vector` whose final size you know —
  it avoids the reallocations and copies from the general efficiency
  rule.
- Pass by `const&` instead of by value for types that copy memory
  (`std::string`, containers). It is the most common performance mistake
  and the easiest to avoid.
- Use `emplace_back` when you construct an element in place instead of
  `push_back` with a temporary.
- Do not fight the compiler over micro-optimizations: writing clear code
  with correct types wins almost every time. The ones that do pay off
  are structural — the copy you do not make, the allocation you do not
  request, the traversal you do not repeat.

## Testing

- A lightweight framework (Catch2, doctest, GoogleTest) with one test
  file per module.
- Test through the same seams the real code uses. If a dependency
  already exists and works, use it for real in the test instead of
  mocking it.
