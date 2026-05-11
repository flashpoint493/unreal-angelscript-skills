# GAS (Gameplay Ability System) Integration with AngelScript

## 1. AngelscriptGAS Plugin Overview

The AngelscriptGAS plugin provides AS bindings for UE's Gameplay Ability System.
Key class: `UAngelscriptGASAbility` — AS-friendly base for Gameplay Abilities.

## 2. Basic GA Pattern (Stub / Log-Only)

```angelscript
class UGA_MyAbility : UAngelscriptGASAbility
{
    // Use NonInstanced for early/stub phase — activation returns = auto-end
    default InstancingPolicy = EGameplayAbilityInstancingPolicy::NonInstanced;
    default NetExecutionPolicy = EGameplayAbilityNetExecutionPolicy::LocalPredicted;

    UFUNCTION(BlueprintOverride)
    void ActivateAbility()  // Note: NO K2_ prefix!
    {
        Print(f"[GA_MyAbility] Activated");
        // NonInstanced: function return = ability ends automatically
    }
}
```

## 3. ASC Resolution Chain

Standard path from any context to AbilitySystemComponent:

```angelscript
APlayerController PC = Gameplay::GetPlayerController(0);
// C++ static helper:
//   PC → GetPlayerState<APlayerState>()
//   → Cast<IAbilitySystemInterface>(PS)
//   → GetAbilitySystemComponent()
UAbilitySystemComponent ASC = MyGASStatics::GetASCFromPC(PC);
```

**Prerequisites**:
- GameMode.PlayerStateClass → custom base with IAbilitySystemInterface
- PlayerState constructs and owns the UAbilitySystemComponent
- PIE must have a local player (menu/empty map → PC is null → returns nullptr)

## 4. C++ Static Library Design for AS

### Rule: Explicit Parameters, No WorldContext
```cpp
// ❌ Don't — WorldContext hidden in AS, breaks resolution
UFUNCTION(BlueprintCallable, meta=(WorldContext="WCO"))
static bool GrantAbility(const UObject* WCO, FString AssetPath);

// ✅ Do — explicit, works everywhere in AS
UFUNCTION(BlueprintCallable)
static bool GrantAbility(UAbilitySystemComponent* ASC, FString AssetPath);
```

### AS Namespace Convention
```cpp
// C++ class name:
class UMyGASStatics : public UBlueprintFunctionLibrary { ... };

// AS call: MyGAS::GrantAbility(ASC, Path)
// (Strip U + Statics → MyGAS::)

// Always add header comment:
// AngelScript namespace: MyGAS::
```

## 5. Known Blind Spots

### protected UFUNCTION Not Visible
`K2_EndAbility`, `K2_CancelAbility` are protected — AS can't call them.
- **Workaround (early)**: Use NonInstanced, function return = auto-end
- **Workaround (advanced)**: C++ base class with `public EndAbilityFromAS()` wrapper

### FGameplayAbilitySpecHandle Instability
Using Spec handles as function parameters/return values in AS can be unstable.
Prefer Tag-based addressing over Handle-based.

### DynamicSpecSourceTags vs Static AssetTags
`ASC->TryActivateAbilitiesByTag(Container)` only matches Ability's static
AssetTags (AbilityTags), **not** `Spec.GetDynamicSpecSourceTags()`.

If routing keys are stored in DynamicSpecSourceTags (injected at grant time from DA),
you must scan Specs manually by DynamicSpecSourceTags to find the matching Handle,
then call `TryActivateAbility(Handle)`.

## 6. GAS Pipeline Spike Checklist

1. ✅ C++ static library with explicit ASC parameter (no WorldContext)
2. ✅ Header comment: `// AngelScript namespace: Xxx::`
3. ✅ AS GA class inherits `UAngelscriptGASAbility`
4. ✅ Override `ActivateAbility` (no K2_ prefix)
5. ✅ NonInstanced policy for stub phase
6. ✅ Grant/Fire/Revoke GM commands registered
7. ✅ Three-Step Strong Sync after any C++ change
8. ✅ Acceptance matrix: 3 positive + 4 negative paths
9. ✅ Verify DynamicSpecSourceTags routing if using DA-injected tags
