---
name: old-man
description: >
  Use this skill every time you are about to write, generate, or hand-write
  any source code, in any language — not just when the user explicitly asks
  for "clean code" or "best practices". It teaches the discipline of an old
  school senior developer: few exit points, explicit loop conditions, no
  hidden global state, differentiated error types, recovery before failure,
  deterministic resource cleanup, minimal comments, no premature
  abstraction, and CPU/memory-efficient code. Apply it proactively and
  silently while writing code — don't wait for the user to ask for a style
  pass or a refactor afterwards; the code should already come out this way
  the first time. Trigger on any request to implement a function, write a
  script, build a feature, fix a bug with new code, or generate a
  class/module, regardless of language (Go, C, C++, Python, JavaScript,
  TypeScript, Java, Rust, etc.).
---

# Old Man

Write code the way a senior engineer who got woken at 3am by someone else's
clever code writes it: boring, obvious, cheap to run, cheap to test. This
isn't a style pass applied afterwards — it's how the first draft comes out.

## The one idea behind all of it

**Every line, branch, and comment has to earn its place.**

Each branch is a path someone has to test and hold in their head. Each
abstraction is a layer someone has to go through to find the real logic.
Each comment is a sentence that can go stale and lie. The senior engineer's
advantage isn't cleverness — it's producing code that has fewer ways to be
wrong and that a tired reader can verify at a glance.

Everything below follows from that. These aren't independent rules to tick
off; they're what that idea looks like in practice. When a case comes up
that none of them covers, go back to the idea and reason from there.

## Control flow

### Few exit points

Minimize a function's exit points — keep only the minimum needed for
maximum control over what the function returns. An early `return` is fine
as an **initial guard** (validating parameters or resources at the start of
a function), but not scattered through the main logic.

What matters is that checks validating the *same* value get combined into a
single condition. Whether you then write it as a guard that returns or as
an `if` holding the body is secondary — both are one exit and one
condition. What's wrong is a separate `return` per individual check, or an
`if` nested inside another `if`.

With one or two conditions, keeping the body inside the `if` reads well and
costs no extra exit point. When avoiding the guard would push you into a
pyramid of nesting, the combined guard is the better shape — it buys a flat
body for the price of a single early return.

Why: it reads like prose. "If x is valid, do the thing" is one sentence,
not three fragments on separate lines — and fewer lines means less to
write, less to review, and less that can drift out of sync as the checks
evolve.

```
// bad — nested, three states to track before reaching the real logic
function process(x) {
  if (x != null) {
    if (x.isValid()) {
      // real logic three levels deep
    }
  }
}

// bad — a separate return per check
function process(x) {
  if (x == null) return
  if (!x.isValid()) return
  // real logic
}

// good — combined condition, body inside
function process(x) {
  if (x != null && x.isValid()) {
    // real logic, unindented
  }
}

// equally good — combined condition as a single guard
function process(x) {
  if (x == null || !x.isValid()) return
  // real logic, unindented
}
```

This applies to checks on the *same* value. Separate operations that each
fail for their own reason are a different situation: three sequential calls
that can each fail differently get checked where each one happens
(`if err != nil { return nil, err }` after each call in Go). Those are
distinct errors that can't be meaningfully `&&`-ed together, and merging
them would hide which operation actually failed.

### Explicit loop conditions

A loop's exit condition belongs to the loop itself, not buried in the body.
Using `return` or `break` inside a loop to exit it is prohibited — the
condition that ends the loop has to be visible in the header.

- Use `for`/for-each **only** when iterating over the full range.
- Use `while` when the loop has a conditional exit — stop at element X, or
  while condition X still holds. In C, C++, Java and similar, where `for`
  takes a condition in its header, `for` can express conditional iteration
  too.

Why: someone asking "when does this loop stop?" should find the answer on
one line, not by scanning the body for hidden exits.

```
// bad — exit condition hidden in the body
for (i = 0; i < items.length; i++) {
  if (items[i].isTarget()) break
  process(items[i])
}

// good — the condition that stops the loop is the loop's condition
i = 0
while (i < items.length && !items[i].isTarget()) {
  process(items[i])
  i++
}
```

## Errors and failure

### Differentiated errors

A function that returns errors has to distinguish the *kind* of failure —
specific codes or types (`ERR_NOT_FOUND`, `ERR_INVALID_INPUT`, specific
exception classes) rather than one generic error. The caller needs to react
differently per case, and it can't do that by parsing a message string.

```
// bad — the caller can't tell what actually failed
function findUser(id) {
  if (!exists(id)) throw new Error("something went wrong")
}

// good — the caller can branch on the type
function findUser(id) {
  if (!exists(id)) throw new NotFoundError(`user ${id} not found`)
}
```

### Recovery before failure

The program should try to recover its state after an error, not die. An
error is handled and reported (log, screen) — it isn't left to kill the
process. An operation that can fail transiently (starting a service,
opening a connection) is retried a bounded number of times before being
given up on. A definitive exception or hard failure is the last resort,
once nothing else can be tried — not the default outcome of the first
error.

### Resource management

Every acquired resource (memory, connection, file, lock) has a single,
deterministic release point, ideally tied to the lifecycle of the object
that owns it — `defer` right after acquisition in Go, RAII in C++, a
context manager or `try/finally` in Python, a paired `_free` function in C.

## Shape of the code

### File and function length

As long as necessary — no artificial limits. Don't split a cohesive
function because it crossed some line count, and don't pad one out either.
Length follows from the work the function actually does.

### No one-line functions

If a function's body is a single line, put that line where it's used.
Wrapping an expression in a function doesn't make it clearer: it hides it
behind a name and forces the reader to jump somewhere else in the file (or
to another file) to find out there was a multiplication inside.

And it isn't free at runtime. The compiler might inline it, but you never
know for sure — it depends on the optimizer, the optimization level,
whether it crosses a module boundary, whether it's virtual. When it isn't
inlined, every call sets up a stack frame, pushes the arguments, jumps, and
returns. Inside a hot loop that's paid on every iteration, for nothing.

```
// bad — applyDiscount exists only to wrap a multiplication
function checkout(order, user) {
  const total = order.items.reduce((a, b) => a + b.price, 0)
  const final = applyDiscount(total, user.discountRate)
  return { total: final, currency: order.currency }
}

function applyDiscount(amount, rate) {
  return amount * (1 - rate)
}

// good — the multiplication lives where it's used
function checkout(order, user) {
  const total = order.items.reduce((a, b) => a + b.price, 0)
  return {
    total: total * (1 - user.discountRate),
    currency: order.currency
  }
}
```

Extract a function when there's a real reason: it's called from several
places, the name explains a calculation that isn't understandable without
it, or the body is big enough to be a conceptual step of its own. "It looks
tidier" isn't a reason.

### Function parameters

Maximum 3–4 parameters; 5–6 as a justified exception, never more. Beyond
that, group them into a logical struct/object. A long parameter list
usually hides a concept — a request, a config, a context — that deserves a
name.

### Variable declaration

Declare variables and attributes at the top of the class, struct, function
or scope (`{...}`), grouped by type, so the shape of the scope reads before
the logic does.

Exception: a short function with 1–3 variables may declare them near their
use — though the top of the scope is still preferable where it reads well.

### Global variables

Prohibited, except for a resource genuinely shared between threads and
protected with a mutex. Module-level state belongs to a class or an
explicit context struct, not to file-scope variables — if two parts of the
program share state, that relationship has to be visible in a constructor
or a signature, not implicit through a global.

```
// bad — hidden dependency, invisible from the signature
let currentUser = null
function loadDashboard() {
  return renderFor(currentUser)
}

// good — the dependency is in the signature
function loadDashboard(user) {
  return renderFor(user)
}
```

### Classes are sealed boxes

A class is designed around how it's used from the outside, not how it's
built on the inside. Same as an integrated circuit: you use it through its
pins, and what's inside the package is none of your business as long as it
does what the datasheet says. If using a class requires reading its body,
it's badly designed.

Two things follow from that:

- **One responsibility per class.** If explaining what it does gives you
  two unrelated things, those are two classes. A class that does everything
  has no clear surface to expose — it has a pile of loose methods.
- **The public surface is the bare minimum.** Everything that's an
  implementation detail goes private. Every public method is a promise
  you'll have to keep once someone uses it, so expose only what's needed to
  use the class, not everything the class knows how to do.

Two practical consequences, and the second is the one that matters most:

- You can rewrite the whole interior without touching a single line of the
  code that uses it.
- **Someone who has never seen the class can't use it wrong.** The public
  methods are designed so the object is always left in a valid state,
  whatever you do with them: there's no way to leave it half-initialized,
  or to call things in an order that breaks it. If using it properly
  requires knowing that "first you call this, then that", that sequence has
  to live inside, not in the head of whoever uses it.

### Don't fragment into many small files

If the content fits in one or a few cohesive files, don't create a file per
function/handler/component out of habit. Split when size or responsibility
justifies it, not mechanically.

## Comments

Document only what the code can't say on its own. A function's name, its
parameter names, and their types should already describe what it does as
fully as possible — when they do, a comment adds nothing and will drift out
of sync the first time the code changes.

Write a comment or docstring when:

- the *why* isn't visible in the code — a workaround, a non-obvious
  constraint, a business rule the types don't express; or
- the function is part of a **public library interface** consumed by other
  projects or teams, where the header or signature is the only contract the
  caller ever sees. There, use the language's standard mechanism (Doxygen
  for C/C++, docstrings for Python, JSDoc/TSDoc for frontend).

Inside a function body, comment only a decision the reader would otherwise
have to reconstruct. Never restate what the next line plainly does.

## Beyond the written rules

The sections below don't come from an explicit rulebook — they're patterns
visible in code written this way, and they follow from the same idea that
every line has to earn its place.

### No premature abstraction

Don't introduce an interface for one implementation, a generic wrapper for
one caller, or a config knob for a value that never varies. Concrete and
direct beats "flexible for a future that may not come". Add the abstraction
when a second real use case shows up.

```
// bad — an interface with exactly one implementation, ever
interface PaymentGateway { charge(amount: number): void }
class StripeGateway implements PaymentGateway { charge(amount) { ... } }

// good — call it directly until a second implementation is real
class StripeGateway { charge(amount) { ... } }
```

### No single-use variables

If a variable is written once and read once immediately after, it isn't
needed: use the expression directly. Two lines where one was enough is
noise the reader has to follow only to find out it added nothing.

```
// bad — the variable exists to be read once, on the next line
function getTotal(order) {
  const subtotal = order.items.sum()
  return subtotal
}

// good
function getTotal(order) {
  return order.items.sum()
}
```

The exception is when the variable's name explains something the
expression alone doesn't say — there the variable *is* the comment, and it
earns its place:

```
// good — the name gives meaning to a condition that isn't clear on its own
const isEligibleForRefund = order.age < 30 && order.status == "delivered"
if (isEligibleForRefund) { ... }
```

### Efficiency by default

- Don't ask the system for memory if you don't have to. If you know the
  maximum size up front (an HTTP header name, a line of a config file), use
  a fixed-size buffer on the stack instead of allocating on the heap. If
  the buffer does have to grow, double its capacity each time it fills —
  don't grow it one element at a time, or every `append` copies the whole
  contents again.
- Don't make the program spin doing nothing while it waits. A
  `while (!ready) {}` loop burns a whole core for no work. Use the
  primitive that blocks until the event happens, or if you have to poll,
  sleep between attempts and stretch that wait if it's still not ready.
- Watch out for scanning a list inside another scan of the same list: with
  100 elements that's 10,000 comparisons, with 1,000 it's a million. If
  you're going to look things up many times in a collection, build a
  map/index first and search there. With a few dozen elements it isn't
  worth it: the plain scan is faster to read and the cost is irrelevant.
- Prefer the minimum number of branches needed to express the logic
  correctly — fewer branches, fewer paths to test.

## Language-specific guidance

Read the relevant reference for how this maps onto a specific language's
tools (error mechanism, memory model, naming, testing):

- `references/go.md` — Go
- `references/c.md` — C
- `references/cpp.md` — C++
- `references/python.md` — Python

For a language without a reference file, apply the principles above and
follow that language's own idiomatic naming and error-handling
conventions.

## Applying this

Write it this way in the first draft — don't produce over-nested,
over-commented, over-abstracted code and then clean it up. When asked to
review or refactor existing code, the same ideas are the checklist: nested
conditionals to flatten, scattered returns to consolidate, loop exits to
lift into the condition, generic errors to differentiate, dead abstractions
to remove, comments that only restate the code. When two options are
equally reasonable, take the one with fewer branches, fewer parameters,
fewer moving parts.
