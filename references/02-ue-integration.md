# UE Integration — Actor, Networking, Subsystems, Blueprints

## 1. Actor & Component System

### DefaultComponent Declaration
```angelscript
class AMyCharacter : ACharacter
{
    UPROPERTY(DefaultComponent, RootComponent)
    UCapsuleComponent Capsule;

    UPROPERTY(DefaultComponent, Attach = Capsule)
    USpringArmComponent SpringArm;

    UPROPERTY(DefaultComponent, Attach = SpringArm)
    UCameraComponent Camera;
}
```

### Dynamic Component Creation
```angelscript
UFUNCTION(BlueprintOverride)
void BeginPlay()
{
    UStaticMeshComponent Mesh = UStaticMeshComponent::Create(this);
    Mesh.AttachToComponent(RootComponent);
}
```

## 2. Networking / Multiplayer

### Property Replication
```angelscript
// Replicated property
UPROPERTY(Replicated)
int32 Health = 100;

// With replication condition
UPROPERTY(ReplicatedUsing = OnRep_Score)
int32 Score = 0;

UFUNCTION()
void OnRep_Score() { UpdateScoreUI(); }

// Replication condition
UPROPERTY(Replicated, ReplicationCondition = COND_SkipOwner)
FVector ServerPosition;
```

### RPC (Remote Procedure Calls)
```angelscript
// Server RPC — called on client, executed on server
UFUNCTION(Server, Reliable)
void ServerFireWeapon(FVector Direction) { }

// Client RPC — called on server, executed on owning client
UFUNCTION(Client, Reliable)
void ClientShowDamageNumber(float Damage) { }

// NetMulticast — called on server, executed on all clients
UFUNCTION(NetMulticast, Unreliable)
void MulticastPlayHitEffect(FVector Location) { }
```

**Key Difference from C++**: AS RPCs default to `Reliable`. In C++, you must
explicitly specify. For frequent updates (movement), use `Unreliable`.

### BlueprintAuthorityOnly
```angelscript
UFUNCTION(BlueprintAuthorityOnly)
void ServerOnlyLogic() { /* Only runs on server */ }
```

## 3. Subsystems

### Creating a Subsystem
```angelscript
// World Subsystem — one per UWorld, good for game-mode-scoped logic
class UMyWorldSubsystem : UScriptWorldSubsystem
{
    UFUNCTION(BlueprintOverride)
    void Initialize(FSubsystemCollectionBase& Collection) { }

    UFUNCTION(BlueprintOverride)
    void Deinitialize() { }
}

// Game Instance Subsystem — one per game instance, persists across levels
class UMyGameSubsystem : UScriptGameInstanceSubsystem
{
    UFUNCTION(BlueprintOverride)
    void Initialize(FSubsystemCollectionBase& Collection) { }
}

// Local Player Subsystem
class UMyLocalPlayerSubsystem : UScriptLocalPlayerSubsystem { }
```

### Accessing Subsystems (Correct AS Syntax)
```angelscript
// ✅ Correct — use generic Get<T>()
UMyWorldSubsystem Sub = GetWorld().GetSubsystem<UMyWorldSubsystem>();
UMyGameSubsystem GISub = GameInstance.GetSubsystem<UMyGameSubsystem>();
UMyLocalPlayerSubsystem LPSub = PlayerController.GetLocalPlayerSubsystem<UMyLocalPlayerSubsystem>();

// ❌ Wrong — C++ style, doesn't work in AS
UMySubsystem Sub = GameInstance.GetSubsystemByClass(UMySubsystem::StaticClass()); // ERROR!
```

**Rule**: In AS, always use `GetSubsystem<T>()` generic form. Never use
`GetSubsystemByClass()` + `StaticClass()` — both will error.

## 4. Blueprint Interop

### AS as Blueprint Parent
AS classes automatically become available as parent classes for Blueprints:
1. Create AS class (e.g., `class UMyWidget : UUserWidget`)
2. In Editor, create Blueprint with Parent Class = the AS class
3. Blueprint can override `BlueprintEvent` functions declared in AS
4. Blueprint can access `BlueprintCallable`/`BlueprintReadWrite` members

### Event Dispatchers
```angelscript
// Declare in AS
event void FOnItemCollected(FName ItemId, int32 Count);

UPROPERTY(BlueprintAssignable)
FOnItemCollected OnItemCollected;

// Broadcast
OnItemCollected.Broadcast(n"gold_coin", 5);
```

### Blueprint Function Library (AS side)
```angelscript
// Creates a "MyUtils::" namespace in AS
class UMyUtilsStatics : UBlueprintFunctionLibrary
{
    UFUNCTION(BlueprintCallable, Category = "MyUtils")
    static FString FormatCurrency(int32 Amount)
    {
        return f"{Amount} Gold";
    }
}
// Usage: MyUtils::FormatCurrency(100)
```

## 5. Editor Scripting

```angelscript
#if EDITOR

class UMyEditorSubsystem : UScriptEditorSubsystem
{
    UFUNCTION(BlueprintOverride)
    void Initialize(FSubsystemCollectionBase& Collection)
    {
        // Editor-only initialization
    }

    UFUNCTION(CallInEditor)
    void BatchProcessAssets()
    {
        // Asset processing logic
    }
}

#endif // EDITOR
```

Editor scripts save-and-run instantly — no compile wait.

## 6. Data Management

### DataTable Access Pattern
```angelscript
class UItemRegistry : UScriptGameInstanceSubsystem
{
    private const FString DT_PATH = "/Game/<Project>/Data/Items/DT_Item.DT_Item";
    private UDataTable DataTable = nullptr;

    UFUNCTION(BlueprintOverride)
    void Initialize(FSubsystemCollectionBase& Collection)
    {
        DataTable = Cast<UDataTable>(
            StaticLoadObject(UDataTable::StaticClass(), nullptr, FName(DT_PATH)));
        if (DataTable != nullptr)
            Print(f"[ItemRegistry] Initialize: rowCount={DataTable.GetRowNames().Num()}");
    }

    bool Find(FName Id, FItemRow& OutRow)
    {
        if (DataTable == nullptr) return false;
        return DataTable.FindRow(Id, OutRow);
    }

    TArray<FName> GetAllIds()
    {
        if (DataTable == nullptr) return TArray<FName>();
        return DataTable.GetRowNames();
    }
}
```

### Resource Path Convention
- Always use project namespace prefix: `/Game/<ProjectName>/...`
- Path in AS constant must exactly match Content directory structure
- After any path change, grep `/Game/` across the project to verify consistency
