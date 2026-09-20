# Common Patterns to Propose

Illustrated in Python/FastAPI for concreteness. Translate the pattern to
the project's real language/framework — don't force Python idioms (`ABC`,
`Protocol`, FastAPI exception handlers) onto another stack.

### SOLID per layer
- **S**: each repository/service/router handles a single resource
- **O**: extend via inheritance or composition, never modify base classes
- **L**: concrete classes fully satisfy the `BaseRepository[T]` contract
- **I**: split large service interfaces into narrow protocols
- **D**: services depend on repository abstractions, not concrete
  implementations

### Abstractions and generics
A generic base repository `BaseRepository(ABC, Generic[T])` with abstract
`get`/`create`/`update`/`delete`; each concrete
(`CollectionRepository(BaseRepository[Collection])`) implements them plus
its own specific methods. Use `Protocol` for structural subtyping where
`ABC` is too rigid.

### Exception hierarchy
A base `AppException(code, message, status_code)` with subtypes per
failure kind (`NotFoundError`, `PermissionError`, `ValidationError`). A
global handler catches it and returns the standard envelope. Log before
raising. Never swallow exceptions silently.

### Classes vs functions
Classes for repositories, services, models. Plain functions for
transformations, utilities, parsing, formatting. Don't wrap stateless
logic in a class just because.

### API response envelope
Always consistent: `status` (`success`/`error`), `message` (English text,
logs only), `data`, `metadata`. Error codes go in `data.code`; the
frontend maps them to localized strings.

### EAV for dynamic fields
With user-defined field collections: `records` table (one row per record)
+ `record_values` table (one row per field value).

### File cleanup by TTL
Store a creation timestamp on generated files; a background task deletes
ones older than the configured TTL.

### Background queues with resume and retry
For anything too slow to run inline (generation, processing, sending), a
queue instead of blocking the request:
- Status as an explicit enum (`pending`, `processing`, `done`, `failed`),
  not a boolean — the UI and retry logic need to distinguish failure kinds
- Progress resumable at the smallest sensible unit (chunk, page, record),
  not "restart the job", so a mid-way crash doesn't throw away completed
  work
- Retries bounded by a counter with increasing backoff; once exhausted, a
  terminal `failed` state visible to the user — never silent infinite
  retry

### Caching
No cache by default. Add one only when a specific read is both expensive
and repeated. When you add it:
- Start in-memory behind a small interface (`get`/`set`/`invalidate`), not
  a hard Redis dependency — leaves room to add a shared cache later
  without touching callers
- State the invalidation trigger explicitly (TTL, explicit-on-write, or
  both) — without that, caches go stale silently

### Error/retry UX
Anything user-facing and fallible (upload, generation, external API):
- A specific message per failure category, not one generic "something
  went wrong"
- A retry action when the failure is plausibly transient, without redoing
  the whole flow
- A visible "in progress" state so the user isn't left guessing

### Payments/subscriptions
*(only if the product charges money)*
- Choose the provider partly by merchant-of-record and tax handling
  (Stripe vs Paddle vs LemonSqueezy), not just price — determines whether
  you or the provider files sales tax
- Bind trials to something harder to reset than an account (device ID,
  fingerprint) if trial abuse is realistic; if it isn't, say so
- Keep the paywall boundary as a single source of truth (an entitlement
  check), not `if user.is_premium` scattered through the code
