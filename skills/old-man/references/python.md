# Python

## Naming

Follow PEP 8 and leave formatting to black or ruff.

- `_` prefix on everything that is an internal detail; no prefix means
  contract.
- Classes named `NounRole`, with the suffix indicating the category
  (`ClickAction`, `FlowElementNotFoundError`) — grepping by suffix finds
  the whole family.
- States and modes in enums, not in magic strings or ints
  (`ResolveMode.WRITE`).

## Function and method structure

- Small, single-purpose private methods, each one a step of the
  pipeline, called in order from a single public orchestrating method
  (`_map_app`, `_map_settings`, `_map_variables` all called from
  `map_2_flow`). The orchestrator reads like an index.
- Complete type hints everywhere, including private helpers and
  dataclass fields declared as class-level annotations.
- When you group parameters, a dataclass or a small context object is
  the natural form in Python — with type hints on every field.

## Control flow

- Validations of the same value are combined into one condition:
  `if x is None or not x.is_valid(): return None` — neither one `if`
  per check, nor wrapped in an `else`.
- Prefer `match`/`case` over a long `if/elif` chain for dispatch on a
  discriminated type.
- In Python the `for` is always for-each: use it only to traverse the
  entire collection. For a conditional exit use `while`, with the
  condition in the header — not a `for` with a `break` inside.
- Use `next((x for x in seq if cond), None)` for "find the first or
  None" instead of a manual loop with a `break`. It is the idiomatic way
  to keep the stopping condition in the expression rather than in the
  body.
- Generator expressions instead of intermediate lists when you only
  traverse the result once: `sum(x.price for x in items)` does not
  materialize the list.

```python
# bad — nested conditionals, manual loop with a break
def resolve(self, selector):
    result = None
    if selector is not None:
        for provider in self._providers:
            if provider.matches(selector):
                result = provider.resolve(selector)
                break
    return result

# good — early guard, generator expression
def resolve(self, selector):
    if selector is None:
        return None
    provider = next((p for p in self._providers if p.matches(selector)), None)
    return provider.resolve(selector) if provider else None
```

## Errors

- Root your own exception hierarchy in a single shared base
  (`class FlowError(AppError)`) that carries an error code; each
  subclass is a short one-liner mapping to that code, with no logic
  duplicated per exception.
- Catch `Exception` broadly only at the outer boundaries (top-level run,
  cleanup) to guarantee reporting/cleanup — internal code raises and
  catches specific exception types.
- Use `try/finally` for single-resource cleanup instead of reaching for
  a context manager wrapper when there is no natural one.
- Chain with `raise X(...) from e` to preserve the original cause.
- Save exceptions for real failures; an expected "not found" case
  returns `None` and the caller checks it with a guard — do not use
  exceptions for ordinary control flow.

## Class design

- Prefer frozen dataclasses for immutable value/config objects (built
  once, no setters).
- Prefer composition over inheritance for sharing behavior (a class
  receives a list of providers/strategies instead of subclassing per
  variant).
- Save inheritance for hierarchies that are genuinely an "is a",
  typically with `ABC` + `abstractmethod`, each abstract method a single
  bounded capability.

## Comments and docstrings

Sparse and pragmatic. A docstring earns its place only for genuinely
non-obvious behavior (the semantic meaning of an exception, a retry
method with multiple strategies) — a simple getter or a method with an
obvious name and clear type hints carries no docstring at all. Inline
comments explain the *why*, never the *what* the next line already
shows.

## Module organization

- When a class is a conceptual piece of its own and of real size, one
  file per class named in `snake_case` (`if_action.py` → `IfAction`)
  works well and makes it obvious where everything lives. But this does
  not override the general rule against fragmenting: several small,
  cohesive classes (exceptions of one family, related value dataclasses)
  go together in one file, not one per file.
- Organize by category (`actions/`, `conditions/`, `models/`,
  `providers/`, `utils/`), with each package's `__init__.py`
  re-exporting the public names as a flat facade via `__all__`.
- Use `from __future__ import annotations` with `TYPE_CHECKING` guards
  to avoid runtime import cycles when a module only needs a type for
  annotations.
