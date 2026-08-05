<?php

/*
|==============================================================================
| Tenant isolation — wiring
|==============================================================================
*/

/* 1. Every tenant-owned table gets a tenant_id column + index --------------- */

// In each business table migration:
//
//   $t->uuid('tenant_id')->index();
//
// Index it: every query now filters on tenant_id, so it must be indexed or every read
// table-scans. For hot tables, make it the FIRST column of your composite indexes
// (tenant_id, created_at), since the tenant filter is always present.


/* 2. The auth middleware already sets the request attribute ----------------- */

// AuthenticateSession / AuthenticateJwt set request->attributes 'tenant_id' from the token.
// TenantContext reads that as its fallback, so NO middleware change is needed. Optionally,
// set it explicitly for clarity right after verification:
//
//   app(\App\Support\TenantContext::class)->set($verify['tenantId']);


/* 3. Models opt in ---------------------------------------------------------- */

//   use App\Models\Concerns\BelongsToTenant;
//
//   class Sale extends Model {
//       use BelongsToTenant;
//       protected $fillable = ['amount', 'customer_id'];   // NOT tenant_id — stamped server-side
//   }
//
// Now: Sale::create([...]) stamps tenant_id; Sale::find($id) only finds it within the tenant;
// Sale::where(...)->get() is tenant-filtered. Nothing in the controller mentions tenant.


/* 4. Jobs and commands: set the tenant explicitly --------------------------- */

// A queued job has no request, so capture the tenant at dispatch and restore it in handle():
//
//   class PostSaleToLedger implements ShouldQueue {
//       public function __construct(public string $saleId, public string $tenantId) {}
//
//       public function handle(\App\Support\TenantContext $tenant): void {
//           $tenant->set($this->tenantId);          // scope restored
//           $sale = Sale::findOrFail($this->saleId); // now tenant-scoped again
//           // ...
//       }
//   }
//
// Dispatch with the acting tenant:
//   PostSaleToLedger::dispatch($sale->id, authTenantId());


/* 5. Deliberate cross-tenant access ----------------------------------------- */

// Platform reporting, admin tools:
//
//   Sale::acrossAllTenants()->where(...)->get();     // bypasses the tenant scope
//   TenantContext::runFor($tenantId, fn () => Sale::sum('amount'));  // scoped to one other tenant


/* 6. Guard rails ------------------------------------------------------------ */

// - NEVER add tenant_id to $fillable. It is stamped from the token; mass-assignable tenant_id
//   is a cross-tenant write waiting to happen.
// - Unique constraints must be COMPOSITE with tenant_id. A per-tenant-unique invoice number is
//   UNIQUE (tenant_id, number), not UNIQUE (number) — otherwise tenant A blocks tenant B's number.
// - Foreign keys stay within a tenant. The global scope protects reads through the model, but a
//   raw DB::table() query bypasses it — use models for tenant-owned data, or add the tenant_id
//   filter by hand on raw queries.
