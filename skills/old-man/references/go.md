# Go

## Naming

Follow `gofmt` and the standard conventions of the language.

- Export only what is the package's contract; everything else
  lowercase.
- Packages by layer/responsibility (`handler`, `service`, `repository`,
  `domain`, `dto`, `errors`), not by file type.
- Do not repeat the package in the symbol: `http.Server`, not
  `http.HTTPServer`.
- `NewXxx(deps...)` constructors that return the struct assembled from
  its dependencies — that is Go's dependency injection, no framework
  needed.
- Interfaces named after the noun they abstract (`NewsRepository`, not
  `INewsRepository`); single-method ones with `-er`.

## Control flow

- `if err != nil { return nil, err }` immediately after every call that
  can fail. This does not contradict the few-exit-points rule: each of
  those returns propagates the error of a different operation, and they
  are exactly the case the SKILL marks as non-combinable. Check them
  where they happen.
- Validations of the *same* value do get combined into one condition, as
  in any other language: `if id == "" || !isValidUUID(id)`.
- Go has no `while`: `for cond { ... }` is the conditional loop form,
  and that is where the exit condition goes. `for range` is only for
  traversing the entire collection.
- No `break` or `return` to leave from the loop body — the condition
  goes in the `for`.

```go
// bad — the exit condition is hidden in the body
for _, item := range items {
    if item.IsTarget() {
        break
    }
    process(item)
}

// good — the conditional for carries the exit condition
i := 0
for i < len(items) && !items[i].IsTarget() {
    process(items[i])
    i++
}
```

## Errors

- Differentiate errors by type, not a generic `errors.New(...)`
  everywhere. A small set of app error constructors
  (`errors.NotFound(...)`, `errors.InvalidCredentials(...)`,
  `errors.Internal(...)`) wraps a message and carries a code the caller
  can switch on to decide the HTTP status or the behavior.
- No bare `panic` in request/business logic — panic is reserved for
  startup cases or genuinely unrecoverable programmer errors. A
  definitive failure returns an error and lets the caller (the handler
  layer) decide how to respond.
- Every resource gets a `defer` right after acquiring it — no cleanup
  logic duplicated across several exit points.

```go
// bad
func GetAdmin(id string) (*Admin, error) {
    admin, err := db.Find(id)
    if err != nil {
        return nil, errors.New("something went wrong")
    }
    return admin, nil
}

// good
func GetAdmin(id string) (*Admin, error) {
    admin, err := db.Find(id)
    if err != nil {
        return nil, errors.NotFound("admin not found")
    }
    return admin, nil
}
```

## Function shape

- Locals that are needed together are declared in a single `var (...)`
  block at the top of the function when there are several; 1-3 locals
  can be declared inline near their first use.
- File length has no artificial cap — split by cohesion (one file for an
  entity's complete CRUD), not mechanically one file per function.

## Comments

Comment only when the function's name and its parameter types do not
already say what it does — most exported functions in well-named Go code
need no comment at all. Add a doc comment only for genuinely non-obvious
behavior (an encoding convention, a surprising precondition), not as a
blanket rule for every exported symbol.

## Testing

- Name tests `Test<Type>_<Method>_<Case>` (for example
  `TestAuthHandler_Login_InvalidCredentials`) — one test per
  behavior/branch.
- Test through the same seams production code uses: build a real router
  with mocked repositories instead of mocking the handler itself, so the
  test exercises the real wiring.
- Generate mocks per interface (one mock per repository interface), not
  a single giant hand-written mock.

## Efficiency

- Return concrete structs from repositories instead of wrapping them in
  generic containers beyond a single shared pagination type (`Page[T]`,
  for example).
- Do not re-wrap or re-annotate the same error over and over as it goes
  up the call stack — wrap it once, at the boundary where context is
  genuinely added.
- Generate SQL queries once into constants instead of building query
  strings at runtime.
