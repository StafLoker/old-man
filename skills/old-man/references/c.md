# C

## Naming

- A module's public symbols carry their own prefix as a stand-in for a
  namespace (`cfgparser_load_kv`, `http_client_send`) — it avoids link
  collisions, since C has no namespaces. It pays off inside an
  application too: the prefix says which module each symbol comes from.
- One casing per syntactic category, no exceptions: types are
  structs/enums typedef'd in `PascalCase` (`HttpRequest`);
  functions/variables in `snake_case`; macros and constants in
  `SCREAMING_SNAKE`, prefixed as well (`HTTP_SERVER_MAX_PORT`).

## Function shape

- Default calling convention for anything that can fail: output through
  pointer parameter(s) plus an `int` return code
  (`int cron_parse(const char *expr, CronExpr *out)`). Save
  pointer-returning functions for "produces a heap object or fails,
  returns NULL on failure".
- Declare locals at the top of the function (C89 style) so stack usage
  and lifetimes are visible before you read the logic.
- Internal helpers go `static` — it is C's way of saying "private", and
  it keeps the module's visible surface small.

```c
/* bad — returning a pointer conflates "empty" with "failed", no error detail */
CronExpr *cron_parse(const char *expr) {
    if (!expr || !*expr) return NULL;
    /* ... */
}

/* good — explicit error code, output through a pointer parameter */
int cron_parse(const char *expr, CronExpr *out) {
    if (!expr || !*expr) return CRON_ERR_EMPTY;
    /* ... */
    return CRON_OK;
}
```

## Memory management

- By default, zero heap allocations for anything bounded: fixed-size
  `char[N]` fields for keys/names/headers with a known maximum, instead
  of `char*` + `malloc`.
- Where growth is unavoidable (response bodies, header arrays), use a
  dynamic array that doubles its capacity (`count`/`capacity` pair) —
  never realloc for every item appended.
- Every function that returns a heap-allocated value has its paired,
  named free function, and that function accepts `NULL` happily
  (`http_client_free_response(NULL)` is a no-op) — ownership is always
  unambiguous: if `_start`/`_send`/`_get` allocates, there is a matching
  `_free`/`_stop`.

```c
/* bad — heap alloc + realloc per header added, no paired free */
char **add_header(char **headers, int n, const char *h) {
    headers = realloc(headers, sizeof(char *) * (n + 1));
    headers[n] = strdup(h);
    return headers;
}

/* good — capacity-doubling growth, paired free */
typedef struct { char **items; int count; int capacity; } HeaderList;

void header_list_add(HeaderList *list, const char *h) {
    if (list->count == list->capacity) {
        list->capacity = list->capacity ? list->capacity * 2 : 4;
        list->items = realloc(list->items, sizeof(char *) * list->capacity);
    }
    list->items[list->count++] = strdup(h);
}

void header_list_free(HeaderList *list) {
    if (!list) return;
    for (int i = 0; i < list->count; i++) free(list->items[i]);
    free(list->items);
}
```

## Control flow

- In C the `for` carries its condition in the header, so it serves both
  full traversal and conditional iteration — the exit condition goes
  there, never a `break` in the body.

```c
/* bad — the exit condition is hidden in the body */
for (size_t i = 0; i < list->count; i++) {
    if (list->items[i].state == STATE_DONE) break;
    process(&list->items[i]);
}

/* good — the condition that stops the loop is in the header */
for (size_t i = 0; i < list->count && list->items[i].state != STATE_DONE; i++) {
    process(&list->items[i]);
}
```

## Errors

- A single flat namespace of int error codes per module, defined with
  `#define` (`PROJECT_ERR_FOO`), success always `0` — that keeps them
  usable in preprocessor checks and stable across a versioned
  header/ABI.
- The sign is your preference: negative or positive, as long as it is
  consistent across the module. The only thing that decides it for you
  is the nature of the function: if it returns a useful positive value
  (a count, a number of bytes read, an index), errors must be negative,
  because otherwise they collide with legitimate values and the caller
  cannot tell them apart.
- Propagate through the return value, checked immediately at the call
  site — no global, hidden side channel for errors (except when you are
  genuinely wrapping a syscall that uses `errno`).

## Header vs source

- Headers contain: version macros, error codes, size/limit constants,
  public typedefs, small inline validation macros, and the prototypes of
  public functions.
- Everything else (parsing internals, helpers, callbacks) lives in the
  `.c` file, declared `static`. If something does not need to be visible
  outside its `.c`, it goes `static` — it is C's way of saying
  "private".
- A struct needed by several translation units of the same module but
  not meant for outside consumers still goes in the header — one header
  per module instead of splitting out a private header.

## Comments — the one deliberate exception

Everywhere else in this skill, comment only what the code cannot say.
The exception is the **header that exposes a public API to consumers who
will never see your `.c`** — a distributed library, or a module with a
stable contract inside a large application. There the header *is* the
contract, and every public function/type/macro group carries a proper
Doxygen block (`@brief`/`@param`/`@return`).

This does not apply to just any header: an internal module's header,
evolving alongside the rest of the project with its `.c` one file away,
follows the general rule — if the name and the types already say what it
does, it carries no comment.

Inside the `.c` files, keep it minimal: section banner comments and
notes about genuinely non-obvious trims or offsets. A guard condition or
a well-named helper carries no comment at all.

## Efficiency

- Prefer a fixed-size bitset over a set/hashmap when the domain is small
  and known (day-of-week or hour fields, for example) — O(1) test, zero
  allocations, cache friendly.
- Grow buffers geometrically (with a named growth-factor constant, `x2`
  for example), never linearly, to bound the number of reallocs/copies
  on large data.
- Prefer fixed-size stack buffers over heap allocation for anything
  under a few KB with a known bound imposed by the protocol (line
  lengths, header names).

## Testing

- Include a `tests/` directory using a lightweight C test framework
  (vendored Unity, for example), one `test_<module>.c` per module,
  fixtures in `tests/fixtures/`, built as a separate test binary.
- When a component depends on another that already exists and works,
  treat it as a real black-box integration partner instead of mocking
  it.

## Project organization

- Mirror `include/<domain>/*.h` with `src/<domain>/*.c`.
- Put optional third-party integrations behind compile-time `-D` flags
  so the core stays dependency-free by default.
