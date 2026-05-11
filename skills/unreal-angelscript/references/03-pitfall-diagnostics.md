# Pitfall Diagnostics & Decision Trees

## Unified Diagnostic Decision Tree

When AS compiler reports `"No matching signatures"` or `"Use name X instead"`:

```
┌─ Error contains "Use name X instead to override ..."?
│   └─ YES → Replace function name with X. Done. (FAMILY-3: K2_ prefix stripped)
│   └─ NO  → Continue
│
├─ Call form is TypeName::Fn(...) and TypeName ends with Statics/Library?
│   └─ YES → Change to namespace form: strip U + suffix → Xxx::Fn(). (FAMILY-1)
│   └─ NO  → Continue
│
├─ Was the C++ function signature changed in the last hour?
│   └─ YES → Three-Step Strong Sync: Build → Close Editor → Reopen. (Reflection lag)
│   └─ NO  → Continue
│
├─ Does the function have meta=(WorldContext="XX")?
│   └─ YES → Refactor to explicit parameters (ASC/PC/PS). (WorldContext hidden in AS)
│   └─ NO  → Continue
│
├─ Is it a protected UFUNCTION?
│   └─ YES → Find public wrapper or use NonInstanced workaround.
│   └─ NO  → Check AS plugin source / community channels for new edge case.
```

## PITFALL-1: VSCode Workspace Root Wrong → No IntelliSense

**Symptom**: No autocomplete, no jump-to-definition, F5 can't attach debugger
**Misdiagnosis**: Plugin version or socket port issue
**Root Cause**: VSCode must open `<Project>/Script/` as workspace root (extension convention)
**Fix**: Open `Script/` folder directly in VSCode. For dual workflow, use Multi-root
Workspace with Script/ as first folder.

## PITFALL-2: AS Class Member Init with String Literal

**Symptom**: `Expected ')' or ','` / `Instead found '<string constant>'`
**Bad Code**: `const FName SOME_PATH = "/Some/Path";`
**Root Cause**: AS class members don't support direct FName initialization from string literals
**Fix**:
```angelscript
// Option A: Initialize in function body
private FName SomePath;
UFUNCTION(BlueprintOverride)
void BeginPlay() { SomePath = FName("/Some/Path"); }

// Option B: Use const FString, convert at use site
private const FString SOME_PATH = "/Some/Path";
// Then: FName(SOME_PATH) where needed
```

## PITFALL-3: Subsystem Access Fails — StaticClass Deprecated

**Symptom**: `No matching signatures to 'UGameInstance::GetSubsystemByClass(UClass)'`
**Root Cause**: AS uses generic function syntax for subsystem access
**Fix**:
```angelscript
// ✅ Correct
UMySubsystem Sub = GameInstance.GetSubsystem<UMySubsystem>();
UMyWorldSubsystem WSub = GetWorld().GetSubsystem<UMyWorldSubsystem>();

// ❌ Wrong
UMySubsystem Sub = GameInstance.GetSubsystemByClass(UMySubsystem::StaticClass());
```

## PITFALL-4: USTRUCT Not Visible in AS — "Not a data type"

**Symptom**: `Identifier 'FMyStruct' is not a data type`
**Root Cause**: C++ USTRUCT must be `USTRUCT(BlueprintType)` AND module must be recompiled
**Fix**: After adding/modifying USTRUCT:
1. VS Build (Development Editor Win64)
2. Editor: `Angelscript.Reload` or restart editor
3. Then check AS errors (old reflection data until step 1-2 complete)

## PITFALL-5: Reload AngelScript Menu Missing

**Symptom**: Tools → AngelScript submenu has no Reload option
**Fix**: Use console command `Angelscript.Reload` or `as.reload`. Three reload paths:
1. Console command (best after C++ changes)
2. Save .as file in VSCode (plugin auto-pushes — best for daily dev)
3. Restart editor (nuclear option)

## PITFALL-6: DataTable Path Mismatch — SkipPackage

**Symptom**: `LoadPackage: SkipPackage: /Game/Xxx/DT_Yyy`
**Root Cause**: Content physical path vs code logical path mismatch
**Fix**: Enforce project namespace prefix `/Game/<ProjectName>/...` everywhere.
After any resource path change, grep `/Game/` across the project.

## PITFALL-7: UE5 V5 Flat Module — Include Path Fails

**Symptom**: `fatal error C1083: Cannot open include file`
**Root Cause**: With `BuildSettingsVersion.V5`, flat modules have no auto include paths
**Fix**: Add to Build.cs: `PublicIncludePaths.Add(ModuleDirectory);`
Then use module-root-relative paths: `#include "SubDir/MyHeader.h"`

## PITFALL-8: C++ Reflection Change → AS Still Shows Old Signatures

**Symptom**: New UFUNCTION added in C++ but AS reports "No matching signatures"
**Root Cause**: AS IntelliSense depends on compiled .dll reflection metadata, not header files
**Fix** (Three-Step Strong Sync):
1. VS Build — confirm new .cpp compiled + linked
2. Close Unreal Editor completely (not just PIE stop)
3. Reopen Editor — AS plugin loads fresh reflection

**Diagnostic trick**: Check `Intermediate/Build/.../<Class>.generated.h` timestamp > .h timestamp
(UHT ran), AND `Binaries/Win64/UnrealEditor-<Project>.dll` timestamp > Intermediate (actually
compiled). Both true + still errors = editor not restarted.

## PITFALL-9: WorldContextObject Hidden in AS Signatures

**Symptom**: `No matching signatures to 'MyStatics::Fn(UObject, FString)'`
**Root Cause**: `meta=(WorldContext=...)` parameters are hidden in AS (same as BP nodes).
If caller can't resolve as WorldContext (e.g., GameInstanceSubsystem), injection fails.
**Fix**: Design C++ static functions with explicit parameters:
```cpp
// ❌ Don't
static bool Fn(const UObject* WorldContextObject, FString Path);

// ✅ Do — explicit context
static bool Fn(UAbilitySystemComponent* ASC, FString Path);
```

## PITFALL-10: "may not be initialized" — Cascading False Positive

**Symptom**: `'bOk' may not be initialized.` on perfectly valid assignment
**Root Cause**: Right-side function call can't resolve (PITFALL-8 or 9) → AS treats return
as unknown → variable flagged uninitialized. **It's a cascade from signature error.**
**Fix**:
1. First fix any `No matching signatures` in the same block → warning auto-disappears
2. Only if no signature errors: add explicit initializer (`bool bOk = false;`)

## PITFALL-11: K2_EndAbility Not Accessible in AS

**Symptom**: `No matching signatures to 'K2_EndAbility()'`
**Root Cause**: `UGameplayAbility::K2_EndAbility` is `protected UFUNCTION`. AS binding
only exposes public UFUNCTIONs.
**Fix**: For early/stub GAs, use `NonInstanced` policy (activation returns = auto-end).
For advanced: create C++ base class with `public UFUNCTION void EndAbilityFromAS()` wrapper.

## PITFALL-12: GameInstanceSubsystem as WorldContext — ASC Resolution Fails

**Symptom**: Any world-scoped operation from GameInstanceSubsystem fails
**Root Cause**: `UGameInstanceSubsystem` is world-agnostic by design
**Fix**: Standard ASC resolution chain:
```angelscript
APlayerController PC = Gameplay::GetPlayerController(0);
// Then C++ static: PC → GetPlayerState → Cast<IAbilitySystemInterface> → GetASC()
```
**Rule**: GameInstanceSubsystem should never hold Actor references or resolve ASC.

## Meta-Tips

- **T1**: "No matching signatures" → first check FAMILY-1/3 writing rules (zero cost),
  then check Three-Step Strong Sync, then check WorldContext. Never debug in reverse order.
- **T2**: AS error messages are literal and precise. "Use name X instead" = X is the answer.
- **T3**: Diagnosis priority: VSCode AS errors > C++ Build errors > UE runtime log
- **T4**: Every time `No matching signatures` appears with `may not be initialized`,
  fix the signature error first — the init warning is always a cascade.
- **T5**: When adding a new `UBlueprintFunctionLibrary` subclass, always add a comment:
  `// AngelScript namespace: Xxx::` to help downstream AS authors.
