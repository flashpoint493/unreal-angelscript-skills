# UI Development — UMG + CommonUI + AngelScript

## 1. Architecture: UMG-Pure-Layout + AS-Native-Logic

### Core Principle
Widget Blueprint (WBP) handles **layout only**. All logic lives in AngelScript.

### WBP Responsibilities (ALLOWED)
- ✅ Designer: Widget Tree (CanvasPanel, Border, Image, Text, Button...)
- ✅ Designer: Named BindWidget controls (name must match AS field exactly)
- ✅ Animation: Widget Animation assets
- ✅ Class Settings: Parent Class → corresponding AS class
- ✅ Class Settings: Implemented Interfaces → only for ListView entry (see below)
- ❌ Event Graph: **Zero business logic** (no if/for/Cast/branch/field access)
- ❌ Functions: No custom functions
- ❌ Variables: No blueprint variables

### Allowed Event Graph Exceptions (Protocol Thunks Only)
1. **Animation nodes**: PlayAnimation / StopAnimation (zero business parameters)
2. **ListView entry**: OnListItemObjectSet with single node forwarding to AS function
   (This is a widely adopted UE-AS production pattern, not a project-specific exception)

### AS Widget Responsibilities (ALL LOGIC)
```angelscript
class UMyWidget : UCommonActivatableWidget
{
    // BindWidget fields — names must match WBP controls exactly
    UPROPERTY(BindWidget) UTextBlock Txt_Title;
    UPROPERTY(BindWidget) UCommonButtonBase Btn_Start;
    UPROPERTY(BindWidget) UListView List_Items;

    // Lifecycle
    UFUNCTION(BlueprintOverride) void Construct() { /* subscribe events */ }
    UFUNCTION(BlueprintOverride) void Destruct() { /* unsubscribe events */ }

    // All rendering logic
    void RenderItems(TArray<FItemData> Items) { ... }
}
```

### Rules
1. AS Widget must override Construct/Destruct pair for event subscription cleanup
2. Don't cache ViewModel or Subsystem pointers as members — use `::Get(this)` per access
3. Screen switching only through a central UIDispatcher, never direct widget cross-creation
4. List item payload classes carry snapshot structs only, never Subsystem references

## 2. BindWidget Naming Convention (PREFIX Table)

| Prefix | UE Widget Type |
|--------|---------------|
| `Txt_*` | UTextBlock |
| `Btn_*` | UCommonButtonBase / UButton |
| `Img_*` | UImage |
| `List_*` | UListView |
| `Tile_*` | UTileView |
| `Tree_*` | UTreeView |
| `Vertical_*` | UVerticalBox |
| `Horizontal_*` | UHorizontalBox |
| `Grid_*` | UUniformGridPanel / UGridPanel |
| `Border_*` | UBorder |
| `Stack_*` | UCommonActivatableWidgetStack |
| `Sw_*` | UWidgetSwitcher |
| `Sl_*` | USlider |
| `Bar_*` | UProgressBar |

### Three-Way Name Contract
```
05-ui-layout.json node "name" == WidgetTree control FName == AS UPROPERTY field name
```
Any change in one must be synchronized to all three.

## 3. ListView / TileView Integration

### The UInterface Problem
**AS does not support `class X : Base, IFoo`** — this is an upstream design choice,
not a configuration issue. Multiple independent evidence chains confirm this:
1. Official docs: "Unreal Interfaces are not supported for use in angelscript"
2. Language level: AngelScript core syntax doesn't support multiple inheritance
3. Community Q&A: Repeatedly confirmed across many threads
4. UE-AS preprocessor source: MatchClass regex only accepts single base token

### Standard Solution (Common Production Pattern)
AS holds `UListView` and calls `SetListItems(TArray<UObject>)`. Entry widget
implements IUserObjectListEntry **entirely in WBP** with a 1-node Event Graph thunk:

**AS Side** — List item widget:
```angelscript
class UMyItemWidget : UCommonUserWidget
{
    UPROPERTY(BindWidget) UTextBlock Txt_Name;
    UPROPERTY(BindWidget) UImage Img_Icon;

    UFUNCTION(BlueprintCallable)
    void ApplySnapshotFromObject(UObject ListItemObject)
    {
        UMyItemPayload Payload = Cast<UMyItemPayload>(ListItemObject);
        if (Payload == nullptr) return;
        Txt_Name.SetText(Payload.Snapshot.DisplayName);
    }
}
```

**WBP Side** — Class Settings:
- Implemented Interfaces: add `UserObjectListEntry`
- Event Graph: Override `OnListItemObjectSet`, single node calling
  `self.ApplySnapshotFromObject(ListItemObject)`

**Payload Class**:
```angelscript
class UMyItemPayload : UObject
{
    UPROPERTY() FMyItemSnapshot Snapshot;
}
```

**Parent Screen**:
```angelscript
void RenderItems(TArray<FMyItemSnapshot> Items)
{
    TArray<UObject> Payloads;
    for (auto& Item : Items)
    {
        UMyItemPayload P = NewObject<UMyItemPayload>(this);
        P.Snapshot = Item;
        Payloads.Add(P);
    }
    List_Items.SetListItems(Payloads);
}
```

### Key Notes
- List item AS class inherits `UCommonUserWidget`, NOT `UCommonActivatableWidget`
- Entry widget WBP is the **only** place where Event Graph has a node (protocol thunk)
- When AS upstream supports interfaces, the WBP thunk can be eliminated

## 4. CommonUI Integration

### Widget Hierarchy
```
UCommonActivatableWidget — for screens (push/pop stack)
UCommonUserWidget — for list items, sub-components
UCommonButtonBase — for interactive buttons (abstract, need concrete subclass)
```

### Screen Switching via UIDispatcher
```angelscript
class UMyUIDispatcher : UScriptGameInstanceSubsystem
{
    UPROPERTY(EditDefaultsOnly) TSubclassOf<UCommonActivatableWidget> MainMenuClass;
    UPROPERTY(EditDefaultsOnly) TSubclassOf<UCommonActivatableWidget> GameplayClass;

    void PushScreen(TSubclassOf<UCommonActivatableWidget> WidgetClass) { ... }
    void PopTop() { ... }
    void GoToMainMenu() { PushScreen(MainMenuClass); }
}
```

### CommonButton Abstract Class Gotcha
`UCommonButtonBase` is abstract — you cannot instantiate it directly in a Baker
or WidgetTree builder. Create a concrete WBP subclass (e.g., `WBP_CommonButton`
with parent = `UCommonButtonBase`) and use it as the concrete fallback.

## 5. AS Known Limitation: BindWidgetOptional

AS reflection does not support `BindWidgetOptional` specifier ("Unknown property
specifier"). All declared controls must exist in WBP. For conditional visibility,
use `SetVisibility(Hidden)` instead of omitting the control.
