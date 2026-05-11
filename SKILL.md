---
name: unreal-angelscript
description: "This skill provides comprehensive knowledge for developing Unreal Engine projects using AngelScript (Hazelight UE-AS fork). It should be used when the user is working on a UE+AngelScript project, writing .as scripts, integrating C++ with AS, debugging AS compilation errors, setting up a new UE-AS project, optimizing AS performance, or building UI, networking, or GAS systems with AngelScript. Covers the full stack from language syntax and UE integration to pitfall diagnostics, architecture patterns, workflow SOPs, and production-proven best practices distilled from public documentation and open community discussions."
---

# Unreal AngelScript — AI Development Skill

## Purpose

Provide an AI coding assistant with the procedural knowledge, diagnostic decision
trees, architecture patterns, and workflow SOPs needed to be an effective pair
programmer on any Unreal Engine + AngelScript project. All content is
project-agnostic — no proprietary code, no project-specific asset paths, no
business logic.

## When to Use

- Setting up a new UE-AS project (engine build, VSCode, directory structure)
- Writing AngelScript classes (Actor, Component, Widget, Subsystem, GA)
- Integrating C++ base layer with AS script layer
- Encountering `No matching signatures`, `may not be initialized`, or other AS errors
- Building networked gameplay (RPC, property replication)
- Creating UMG/CommonUI widgets with AS-native logic
- Working with GAS (Gameplay Ability System) via AngelscriptGAS plugin
- Optimizing AS performance (precompile, transpile, JIT)
- Migrating from HTML/Web prototypes to UE+AS
- Planning data-driven architecture (DataTable, DataAsset, Registry, Strategy pattern)

## Knowledge Architecture

```
references/
├── 01-language-and-setup.md        — AS syntax, C++ differences, environment setup
├── 02-ue-integration.md            — Actor/Component, networking, subsystems, blueprints
├── 03-pitfall-diagnostics.md       — 12+ pitfalls with symptom→root-cause→fix decision trees
├── 04-architecture-patterns.md     — Data-driven, strategy pattern, server-authoritative, naming
├── 05-workflow-sops.md             — Session onboard, registry expansion, feature spike, bugfix, etc.
├── 06-performance-and-build.md     — Benchmarks, precompile, transpile, JIT, shipping
├── 07-ui-and-commonui.md           — UMG + CommonUI + AS-native logic, BindWidget, ListView
├── 08-gas-integration.md           — AngelscriptGAS plugin pitfalls and patterns
├── 09-community-wisdom.md          — Distilled community consensus, decision matrix
└── 10-skill-tree-and-learning.md   — 20 sub-skills, dependency graph, team role matrix
```

## How to Use This Skill

### Reactive (error-driven)

When encountering an AS compilation or runtime error:

1. Read `references/03-pitfall-diagnostics.md` — match the symptom to a PITFALL/FAMILY entry
2. Follow the unified diagnostic decision tree (covers `No matching signatures`,
   `may not be initialized`, `SkipPackage`, `C1083`, `StaticClass deprecated`, etc.)
3. If the error involves GAS, also read `references/08-gas-integration.md`
4. If the error involves UI/BindWidget, also read `references/07-ui-and-commonui.md`

### Proactive (task-driven)

When starting a new task:

| Task | Reference to Read |
|------|-------------------|
| Set up new UE-AS project | `01-language-and-setup.md` |
| Write AS classes / override functions | `01-language-and-setup.md` § ScriptName rules |
| Add DataTable + Registry + GM commands | `04-architecture-patterns.md` + `05-workflow-sops.md` § Registry Expansion |
| Build a new pipeline (GAS / items / events) | `04-architecture-patterns.md` § Spike methodology |
| Create UI widgets | `07-ui-and-commonui.md` |
| Network replication / RPC | `02-ue-integration.md` § Networking |
| Migrate HTML prototype to UE | `05-workflow-sops.md` § HTML-to-UE Migration |
| Optimize performance / ship | `06-performance-and-build.md` |
| Evaluate AS for a new project | `09-community-wisdom.md` § Decision Matrix |

### Key Rules (Always in Context)

1. **Three-Step Strong Sync**: After any C++ reflection change (USTRUCT/UFUNCTION/UENUM),
   always: VS Build → Close Editor → Reopen Editor. AS only loads reflection at startup.

2. **ScriptName Normalization**: AS renames UE reflection exports:
   - `UBlueprintFunctionLibrary` subclasses → namespace (`UGameplayStatics` → `Gameplay::`)
   - `K2_` prefix stripped on override (`K2_ActivateAbility` → `ActivateAbility`)
   - Type references keep U/A/F prefix (`UAbilitySystemComponent`)

3. **Data-Driven Architecture**: All constants in DataTable/UDataAsset. No hardcoded
   values in .as/.cpp. Strategy pattern (N executors + Registry) over god if-else.

4. **Server Authoritative**: Random sources, AI decisions, validation, damage — all
   server-side. Use `COND_SkipReplication` for sealed fields.

5. **UInterface Not Supported**: AS does not support `class X : Base, IFoo`.
   Use component-based design + Cast, or WBP 1-node thunk for ListView entry widgets.

6. **AS FName Literal**: Use `n"Name"` for compile-time FName. Never write
   `const FName X = "string";` as class member — use function body or `const FString`.

7. **Explicit Over Implicit**: For C++ static functions called from AS, use explicit
   parameters (ASC, PC, PS) instead of `meta=(WorldContext=...)`.
