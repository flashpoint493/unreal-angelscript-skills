# AngelScript Skill Tree & Learning Paths

## 20 Sub-Skills Overview

### Foundation Layer (S1–S3)
| Skill | Name | Scope |
|-------|------|-------|
| S1 | as-setup | Engine install, project creation, VSCode config |
| S2 | as-language-core | AS syntax, C++ differences, FName, f-strings |
| S3 | as-class-system | Class definition, inheritance, virtual methods, Mixin |

### Development Layer (S4–S7)
| Skill | Name | Scope |
|-------|------|-------|
| S4 | as-functions-events | Functions, BP events, delegates, event dispatchers |
| S5 | as-actors-components | DefaultComponent, Attach, dynamic creation |
| S6 | as-function-libraries | System::/Gameplay::/Math:: namespaces |
| S7 | as-blueprint-interop | AS↔BP bidirectional interop |

### UE Integration Layer (S8–S13)
| Skill | Name | Scope |
|-------|------|-------|
| S8 | as-networking | Replication, RPC, server authority |
| S9 | as-subsystems | World/GameInstance/LocalPlayer/Editor subsystems |
| S10 | as-editor-tools | Editor-Only scripts, asset batch processing |
| S11 | as-ui-widgets | UMG + CommonUI + AS-native logic |
| S12 | as-gameplay-systems | GAS, damage, input, AI, animation |
| S13 | as-data-management | DataAssets, DataTables, config, serialization |

### Quality Layer (S14–S16)
| Skill | Name | Scope |
|-------|------|-------|
| S14 | as-testing | xUnit unit tests, integration tests |
| S15 | as-debugging | VSCode breakpoints, bytecode dump, log system |
| S16 | as-code-quality | Coverage reports, Clang-Format, coding standards |

### Engineering Layer (S17–S20)
| Skill | Name | Scope |
|-------|------|-------|
| S17 | as-performance | Benchmarks, coding optimization, architecture optimization |
| S18 | as-build-pipeline | Precompile, transpile, shipping builds |
| S19 | as-engine-internals | Engine diff, class binding, plugin architecture, AOT/JIT |
| S20 | as-project-management | Folder structure, Git workflow, C++/AS/BP responsibilities |

## Dependency Graph

```
S1 (Setup)
 ↓
S2 (Language Core) ← prerequisite for all other skills
 ↓
S3 (Class System)
 ├→ S4 (Functions & Events)
 ├→ S5 (Actors & Components)
 └→ S6 (Function Libraries)
     ↓
     S7 (Blueprint Interop)
     ├→ S8 (Networking)
     ├→ S9 (Subsystems)
     ├→ S10 (Editor Tools)
     ├→ S11 (UI)
     ├→ S12 (Gameplay Systems)
     └→ S13 (Data Management)

S14 (Testing) ← depends on S2–S7
S15 (Debugging) ← depends on S1
S16 (Code Quality) ← depends on S14

S17 (Performance) ← depends on S2, S6
S18 (Build Pipeline) ← depends on S17
S19 (Engine Internals) ← advanced, depends on S2
S20 (Project Management) ← depends on all
```

## Team Role × Skill Matrix

| Skill | Programmer | Tech Artist | Designer | Engine Dev |
|-------|-----------|-------------|----------|-----------|
| S1 Setup | Required | Required | Required | Required |
| S2 Language | Required | Required | Required | Required |
| S3 Classes | Required | Recommended | Awareness | Required |
| S4 Functions | Required | Required | Recommended | Required |
| S5 Actors | Required | Recommended | Awareness | Required |
| S6 Libraries | Required | Recommended | Recommended | Required |
| S7 BP Interop | Required | Required | Required | Recommended |
| S8 Networking | Recommended | Awareness | Awareness | Required |
| S9 Subsystems | Recommended | Awareness | — | Required |
| S10 Editor | Recommended | Recommended | — | Required |
| S11 UI | Recommended | Required | — | Awareness |
| S12 Gameplay | Required | Awareness | Awareness | Recommended |
| S13 Data | Recommended | Awareness | Recommended | Recommended |
| S14 Testing | Required | Awareness | — | Required |
| S15 Debugging | Required | Recommended | Awareness | Required |
| S16 Quality | Recommended | Awareness | — | Required |
| S17 Performance | Recommended | Awareness | — | Required |
| S18 Build | Awareness | — | — | Required |
| S19 Engine | Awareness | — | — | Required |
| S20 Management | Recommended | Awareness | Awareness | Required |

## Learning Paths

### Quick Start (1–2 days)
```
S1 → S2 → S5 → S7
```
Get environment running, understand syntax, create first Actor, interact with BP.

### Full Developer Path (1–2 weeks)
```
S1 → S2 → S3 → S4 → S5 → S6 → S7 → S14 → S15
```
Complete foundation + development layer + testing/debugging.

### Advanced Engineering (as needed)
```
S8 (Networking) / S9 (Subsystems) / S17 (Performance) / S18 (Build) / S19 (Engine)
```
Pick based on project requirements.

### UI Specialist Path
```
S1 → S2 → S4 → S7 → S11 → S16
```
Focus on widget development with AS-native logic.

### Multiplayer Specialist Path
```
S1 → S2 → S3 → S8 → S9 → S12
```
Focus on networking, replication, and gameplay systems.

## Key Resources

| Resource | URL | Type |
|----------|-----|------|
| Hazelight Official Docs | angelscript.hazelight.se | Authority |
| AS Chinese Wiki | unrealengine-angelscript-zh.github.io/Wiki | Translation |
| AngelscriptLab | github.com/UnrealEngine-Angelscript-ZH/AngelscriptLab/ | Examples |
| asaot (AOT compiler) | github.com/quarnster/asaot | Performance |
| EmmsUI | github.com/Hazelight/EmmsUI | Immediate-mode UI |
