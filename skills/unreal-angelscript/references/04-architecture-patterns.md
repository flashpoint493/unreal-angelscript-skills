# Architecture Patterns for UE + AngelScript

## 1. Three Architecture Red Lines

### R1: Data-Driven
All constants go into DataTable / UDataAsset. No hardcoded values in scripts or code.
- Every numeric constant must have a DataTable row
- grep for bare literals in `.as` / `.cpp` should return zero hits
- Asset references use `TSoftObjectPtr<>` in DataTable rows

### R2: Strategy Pattern for Polymorphism
N rules/skills/events → N Executor subclasses + Registry dispatch.
Never write "god if-else" or "god switch".
```
Registry.Find(Key) → Executor.Execute(Params)
```

### R3: Server Authoritative
- Random source generation → Server only
- AI decisions → Server only
- Validation / damage calculation → Server only
- Sealed fields → `COND_SkipReplication`
- Client visual/audio randomness is separate from gameplay randomness

### Three Key Distinctions
- **D1**: Display Value / Internal Value / Actual Value — must be separate fields
  in any multiplayer economy, trading, or competitive scoring scenario
- **D2**: Gameplay Random (Server) / Visual Random (Client) / Audio Random (Client)
  — three separate random sources to prevent client-side gameplay manipulation
- **D3**: Design Intent vs Implementation Detail — migrate rules/formulas/state machines,
  don't line-by-line translate prototype code

## 2. 8-Document Single Source of Truth (Prototype → Engine Migration)

When migrating a large HTML/Web prototype to UE+AS:

```
Docs/<FeatureName>/
├── 00-README.md              — Index + reading path
├── 01-design-intent.md       — Gameplay loop, art direction, emotion curve, trade-offs
├── 02-numerical-design.md    — All constants extracted into tables
├── 03-system-design.md       — State machines, rules, AI, timing, log spec
├── 04-module-architecture.md — Prototype → engine fine-grained module split
├── 05-ui-layout.json         — UI Layout JSON DSL (name/type/xywh/color/children)
├── 06-baking-pipeline.md     — Lightweight baking pipeline design
├── 07-asset-references.md    — All icons/colors/animations/SFX + engine placeholders
└── 08-do-and-dont.md         — Red/yellow line list (≥10 items with violation examples)
```

**Rule**: Build all 8 docs BEFORE writing code. No "code as you design".

## 3. Spike Methodology — Pipeline Validation

### Placeholder Reuse Pattern (PATTERN-1)
When validating a "config-driven pipeline" (DataAsset + Executor + Tag/Key + Registry):

- **N instances share 1 executor** during Spike phase
- Each DA has unique RoutingKey but same ExecutorClass (log-only stub)
- Cost: 2N+1 changes instead of 3N

Apply when ALL three conditions are met:
1. Current phase goal is "pipeline validation", not "business implementation"
2. N ≥ 3 (below 3, naive path is cheaper)
3. Next phase explicitly upgrades to independent executors

### Three-Consistent Naming (PATTERN-2)
DataAsset directory / prefix / Id must be three-way consistent:

| Dimension | Convention |
|-----------|-----------|
| Directory | Plural form of data category: `Skills/`, `Heroes/`, `Items/` |
| Prefix | `DA_` + category abbreviation: `DA_Skill_`, `DA_Hero_` |
| Body | Exactly matches DataTable row Id field (case-sensitive) |
| Full Path | `/Game/<Project>/Data/<PluralDir>/DA_<Abbr>_<Id>.DA_<Abbr>_<Id>` |

### Acceptance Matrix (PATTERN-3)
Minimum evidence for pipeline PASS = 6 log entries (3 positive + 3 negative):

| Case | Command | Expected | Validates |
|------|---------|----------|-----------|
| VP-1 | grant \<id\> | Grant OK, handle=N | Host registers Spec |
| VP-2 | fire \<id\> | result=true + activation log | Key routing works |
| VP-3 | revoke \<id\> | Cleared=1 | Spec truly removed |
| VN-1 | fire (no grant) | result=false | Key routing isolation |
| VN-2 | grant \<unknown\> | NOT FOUND | Registry defensive lookup |
| VN-3 | revoke after revoke | Cleared=0 | Revoke idempotency |

**Key Insight**: Negative path testing ≥ positive path testing. Positive paths only
prove happy path works; negative paths prove routing/state/boundaries are correct.

### Incremental Upgrade (PATTERN-4)
Never batch-replace all placeholders at once. Upgrade one instance at a time:
1. Create independent executor file
2. Update DA's ExecutorClass field
3. Run full acceptance matrix
4. Update project state documentation
5. Repeat for next instance

## 4. Registry Expansion Workflow (Summary)

Standard flow for adding a new data type to a UE+AS project:

```
Phase 1: C++ Row Struct    → Add USTRUCT(BlueprintType) to DataRows.h
Phase 2: Three-Step Sync   → VS Build → Close Editor → Reopen
Phase 3: CSV Data          → Prepare CSV matching struct fields
Phase 4: Import DataTable  → Content Browser import, verify rowCount
Phase 5: AS Registry       → Create Subsystem with Find/GetAllIds API
Phase 6: GM Commands       → Register query/list/count commands
Phase 7: Two-Stage Accept  → Log-level (P0) → GM E2E (positive + negative)
Phase 8: Doc Sync          → Update context, changelog, roadmap
```

## 5. C++ Thin Layer Design Principle

```
C++ Layer (thin):
  ✅ USTRUCT / UENUM definitions
  ✅ Empty base classes (anchor classes)
  ✅ Static utility libraries (UBlueprintFunctionLibrary)
  ✅ Tool chain (Baker, importer, linter)
  ❌ Business logic
  ❌ State machines
  ❌ UI logic

AS Layer (thick):
  ✅ Registries, Subsystems
  ✅ GameMode, PlayerController, PlayerState
  ✅ Widget classes (with BindWidget)
  ✅ Ability executors
  ✅ GM command handlers
  ✅ All business logic

Blueprint Layer (config only):
  ✅ DataTable / DataAsset instances
  ✅ WBP widget blueprints (layout only, no Event Graph logic)
  ✅ Asset references (materials, meshes, sounds)
  ❌ Logic nodes in Event Graph
```
