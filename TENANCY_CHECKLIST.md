# What `BelongsToTenant` does NOT cover

The trait handles Eloquent model reads and writes. Everything below is outside it.

## 1. Raw query-builder calls bypass the scope entirely

`DB::table('approval_requests')` is not a model, so no global scope applies. **Every
DataTables index method in this codebase is a raw builder** — they scope by hand:

```php
DB::table('approval_requests as ar')->where('ar.tenant_id', $tenantId)   // manual, and required
```

One forgotten `where` is a full cross-tenant read. If you take one thing from this list:
grep for `DB::table(` and check each has a tenant filter.

## 2. `insert()` and `upsert()` skip model events

`Model::create()` fires `creating`, so the trait stamps it. These do **not**:

```php
Sale::insert([...]);                    // no event -> no tenant_id
Sale::upsert([...], ['id'], ['amount']); // no event -> no tenant_id
DB::table('sales')->insert([...]);       // not a model at all
```

Either add `tenant_id` explicitly in those payloads or avoid them for tenant-owned tables.

## 3. Jobs, commands, consumers have no request

`TenantContext` falls back to the request attribute; a queued job has none. Capture the
tenant at dispatch and restore it:

```php
PostSaleToLedger::dispatch($sale->id, authTenantId());
// handle(): app(TenantContext::class)->set($this->tenantId);
```

Without this, console context means the read scope adds no filter and the job sees every
tenant's data.

## 4. Cache, storage, and search keys

None of these are models:

- `Cache::remember('item_groups', ...)` — must include the tenant (see `DropdownCacheService`)
- File uploads — partition the path: `tenants/{tenant}/uploads/…`, not `uploads/…`
- Scout / external search indexes — filter by tenant at query time, not just at index time
- Broadcast channels — `private-tenant.{tenant}.orders`, never `private-orders`

## 5. Composite unique constraints

`UNIQUE (number)` means tenant B cannot reuse tenant A's invoice number. Every per-tenant
unique must include the tenant:

```php
$t->unique(['tenant_id', 'number']);
```

## 6. Foreign keys are not validated across tenants

The scope stops you *reading* another tenant's customer, but nothing stops you *writing* a
`customer_id` that belongs to another tenant. For FKs that arrive from user input, verify
ownership before saving — a scoped `findOrFail()` on the parent is enough, since the scope
makes a foreign id resolve to nothing.

## 7. Pivot tables

Many-to-many pivots usually have no `tenant_id` and no model, so they get neither stamping
nor scoping. Add the column where the pivot is tenant-owned, and filter it in raw joins.

## 8. `acrossAllTenants()` is unrestricted

Anyone can call it. It is the intended escape hatch, but every call site deserves a comment
saying why, and a periodic grep to confirm none crept into ordinary request paths.

## 9. Tests give false confidence

A test that never sets a tenant runs in console context, where the read scope adds no filter —
so cross-tenant bugs pass. Set a tenant in your test setup, and add one test that asserts
tenant A cannot see tenant B's rows.

---

## Quick audit

```bash
grep -rn "DB::table(" app/ Modules/            # each needs a manual tenant filter
grep -rn "::insert(\|::upsert(" app/ Modules/  # these skip the stamping event
grep -rn "acrossAllTenants" app/ Modules/      # each needs a justification
grep -rn "Cache::remember\|Cache::put" app/    # each key needs the tenant
grep -rn "dispatch(" app/ Modules/             # each job needs the tenant passed
```
