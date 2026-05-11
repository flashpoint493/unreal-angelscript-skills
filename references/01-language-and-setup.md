# AngelScript Language Core & Environment Setup

## 1. What is UE-AngelScript

UE-AngelScript is a source-code fork of Unreal Engine maintained by Hazelight Studios.
It deeply integrates the AngelScript scripting language into UE5, enabling hot-reload
game logic with near-C++ syntax. It has been adopted in production on multiple shipped
UE titles.

### Three-Layer Architecture

```
┌─────────────────────────────────────────────────────────┐
│ Blueprint Layer — asset config, simple logic, WYSIWYG   │
│  → Inherits from AS classes, config + visuals only      │
├─────────────────────────────────────────────────────────┤
│ AngelScript Layer — game logic workhorse, hot-reload    │
│  → Business logic, state machines, UI, networking, tools│
├─────────────────────────────────────────────────────────┤
│ C++ Layer — performance-critical, engine bindings       │
│  → USTRUCT/UENUM definitions, engine modifications      │
└─────────────────────────────────────────────────────────┘
```

## 2. Environment Setup

### Hardware Requirements
- SSD required, reserve 256GB+ space
- 12+ core CPU recommended, 32GB+ RAM
- Full engine build ~42 min on AMD 5900X + 64GB

### Software Requirements (UE 5.4+)
- Windows 10 SDK 19041
- Visual Studio 2022 v17.8+ with MSVC v14.38
- LLVM Clang (WinLibs)
- .NET 4.6.2 Targeting Pack + .NET 6.0

### Build Flow
```
git clone (requires Epic GitHub access + Hazelight fork access)
→ checkout angelscript-master branch
→ Setup.bat → GenerateProjectFiles.bat
→ VS: Development Editor / Win64 → Build
```

### Iron Rules
- ❌ Never use VS "Clean" or "Rebuild"
- ✅ Set `Source/Runtime` as read-only to prevent accidental edits
- ✅ Third-party plugins go to `Engine/Plugins/Marketplace`
- ✅ Use `BuildConfiguration.xml` to control parallel compile cores

### VSCode Setup
- Install "Unreal Angelscript" extension (Hazelight official)
- Install "Unreal Angelscript Clang-Format" extension
- **RULE**: VSCode must open `<Project>/Script/` as workspace root
  (the extension hardcodes this convention)
- For dual workflow: use Multi-root Workspace with Script/ first in folder order

## 3. Language Core — Key Differences from C++

### Objects and References
- AS uses **references** not pointers. `UObject Ref` not `UObject* Ref`.
- Null check: `if (Ref != nullptr)` or `if (Ref.IsValid())`
- No raw memory management, GC handles lifetime

### Properties
```angelscript
// UPROPERTY defaults: BlueprintReadWrite, EditAnywhere
UPROPERTY()
float Health = 100.0;

// Restrict access
UPROPERTY(BlueprintReadOnly, VisibleAnywhere)
FName Id;
```

### Functions
```angelscript
// Plain script function (not visible to BP)
void MyInternalFunc() { }

// Blueprint-callable
UFUNCTION(BlueprintCallable)
void DoSomething() { }

// Override C++ / parent AS event
UFUNCTION(BlueprintOverride)
void BeginPlay() { Super::BeginPlay(); }
```

### FName Literals
```angelscript
// Compile-time FName — zero runtime lookup cost
FName Tag = n"Player.Health";

// ❌ WRONG: Cannot initialize FName from string literal as class member
const FName BAD = "SomePath";  // Compilation error!

// ✅ Correct alternatives:
const FString PATH_STR = "/Game/Data/DT_Hero.DT_Hero";
// Then in function: FName(PATH_STR)
```

### Format Strings
```angelscript
FString Msg = f"Player {Name} has {Health} HP";
// Similar to Python f-strings / C# string interpolation
```

### Delegates and Events
```angelscript
// Delegate declaration
delegate void FOnHealthChanged(float NewHealth);

// Event (multicast delegate)
event void FOnDeath(AActor Victim);

// Usage
FOnHealthChanged OnHealthChanged;
OnHealthChanged.Broadcast(NewHealth);
```

### Structs
- Structs are **value types** in AS — assignment copies
- Pass by reference with `&` for output parameters

### Default Keyword
```angelscript
class AMyActor : AActor
{
    // Set CDO defaults
    default CollisionProfileName = n"Pawn";
    default bReplicates = true;
}
```

## 4. ScriptName Normalization Rules

AS renames UE reflection exports. Three families of rules:

### FAMILY-1: UBlueprintFunctionLibrary → Namespace
| C++ Class | AS Namespace | Rule |
|-----------|-------------|------|
| UGameplayStatics | Gameplay:: | Strip U + Statics |
| UKismetSystemLibrary | System:: | Strip UKismet + Library |
| UKismetMathLibrary | Math:: | Strip UKismet + Library, rename |
| UNiagaraFunctionLibrary | Niagara:: | Strip U + FunctionLibrary |
| UWidgetBlueprintLibrary | Widget:: | Strip UWidget + BlueprintLibrary |
| Custom `UXxxStatics` | Xxx:: | Strip U + Statics |

**Rule**: When calling static functions from a `UBlueprintFunctionLibrary` subclass,
use the namespace form: `Gameplay::GetPlayerController(0)`, never `UGameplayStatics::...`

### FAMILY-2: Type References Keep Prefix
- `UAbilitySystemComponent` stays as `UAbilitySystemComponent` in variable declarations
- `APlayerController` stays as `APlayerController`
- Prefix only stripped in namespace context (FAMILY-1)

### FAMILY-3: K2_ Prefix Stripped on Override
```angelscript
// ❌ Wrong
UFUNCTION(BlueprintOverride)
void K2_ActivateAbility() { }

// ✅ Correct — AS strips K2_ prefix
UFUNCTION(BlueprintOverride)
void ActivateAbility() { }
```

Common K2_ functions: `K2_ActivateAbility → ActivateAbility`,
`K2_DestroyActor → DestroyActor`, `K2_DestroyComponent → DestroyComponent`

### Quick Self-Check
- `.as` files should have **zero** matches for `K2_[A-Z]` in override methods
- `.as` files should have **zero** matches for `U[A-Z].+(Statics|Library)::`
- When AS compiler says "Use name X instead" — X is always the correct answer

## 5. Project Structure Best Practice

```
<Project>/
├── Source/<Module>/           — C++ (USTRUCT, UENUM, base classes, tools)
│   ├── <Module>.Build.cs
│   ├── <Module>DataRows.h    — All FTableRowBase structs
│   ├── <Module>Enums.h       — All gameplay enums
│   └── <SubDir>/             — Feature subdirectories
├── Script/<Module>/           — AngelScript (all game logic)
│   ├── Domain/               — Registries, subsystems
│   ├── GM/                   — GM command system
│   ├── UI/                   — Widget classes
│   ├── Skills/               — Ability executors
│   └── Tests/                — Unit tests
├── Content/<Module>/          — UE assets
│   ├── Data/                 — DataTables, DataAssets
│   ├── UI/                   — WBP widget blueprints
│   └── Maps/                 — Level assets
├── Config/                   — INI files
├── Plugins/                  — Project plugins
└── Tools/                    — Python/CLI utilities
```

### Build.cs Key Rule (UE5 V5 Flat Layout)
When using `BuildSettingsVersion.V5` with flat module layout (no Public/Private dirs),
add this to Build.cs:
```csharp
PublicIncludePaths.Add(ModuleDirectory);
```
Without this, `#include` paths will fail with `C1083: Cannot open include file`.
