# Workflow SOPs for UE + AngelScript Projects

## 1. Session Onboarding SOP

Every new session should follow this sequence:

1. **Read core docs**: Project context file + contributing guide + key insights
2. **State restore**: Extract current version, phase, last checkpoint, backlog
3. **Workflow routing**: Match user intent to appropriate workflow
4. **Guard check**: Verify target directories are writable, no conflicts

## 2. Context Closure SOP

After any phase verification pass or design decision lock:

1. **Update context**: current_task, progress, pending_issues, next_steps
2. **Update changelog**: Add accepted/decided change entries
3. **Update QA**: Mark test cases as pass/fail, sync statistics
4. **Insight capture**: If the method is reusable, create or update insight

Quality gates:
- Every "pass" must map to specific log output or command result
- Context/changelog/QA must not contradict each other
- Design non-goals must be explicitly documented

## 3. Registry Expansion SOP

Standard flow for adding a new data type (Row Struct + DataTable + Registry + GM):

### Step 1: Pre-check
- Verify row struct doesn't already exist
- Plan DataTable path with three-consistent naming
- Review ScriptName normalization rules

### Step 2: C++ Row Struct
```cpp
USTRUCT(BlueprintType)
struct FMyRow : public FTableRowBase
{
    GENERATED_BODY()
    UPROPERTY(EditAnywhere, BlueprintReadOnly)
    FName Id;
    // ... other fields
};
```
Then: Three-Step Strong Sync (Build → Close Editor → Reopen)

### Step 3: CSV Data
- First column = `Name` (UE DataTable primary key)
- Other columns match struct field names exactly
- FName fields: `snake_case`
- TSoftObjectPtr fields: leave empty initially

### Step 4: Import & Verify
- Import CSV in Content Browser at `/Game/<Project>/Data/<PluralDir>/`
- Double-click asset to verify row count matches CSV

### Step 5: AS Registry
```angelscript
class UMyRegistry : UScriptGameInstanceSubsystem
{
    private const FString DT_PATH = "/Game/<Project>/Data/.../DT_My.DT_My";
    private UDataTable mDataTable = nullptr;

    UFUNCTION(BlueprintOverride)
    void Initialize(FSubsystemCollectionBase& Collection) { LoadDataTable(); }

    bool Find(FName Id, FMyRow& OutRow) { ... }
    TArray<FName> GetAllIds() { ... }
    private void LoadDataTable() { ... }
}
```

### Step 6: GM Commands
Register `<prefix>.query <id>`, `<prefix>.list`, optional `<prefix>.count`.
Each with proper log format: `"[GM] <prefix>.query: id=X name=Y"`

### Step 7: Two-Stage Acceptance
- Stage 1 (Log-level): Editor startup logs show Registry initialization + rowCount
- Stage 2 (GM E2E): Positive paths (query valid id) + Negative paths (query unknown id)

## 4. Feature Spike SOP

For first-time pipeline validation (GAS / items / events / quests):

1. **Placeholder decision**: Check 3 conditions for placeholder reuse
2. **Naming plan**: Three-consistent DA naming
3. **Stub executor**: Log-only, NonInstanced if GA
4. **DA assets**: Create N DAs with unique keys, shared executor
5. **GM three-piece**: grant / fire / revoke commands
6. **Acceptance matrix**: 7 test cases (3 positive + 4 negative)
7. **Upgrade plan**: Document per-instance upgrade path

## 5. Bug Fix SOP

When encountering errors in UE+AS:

1. **Classify symptom** against diagnostic decision tree
2. **Check zero-cost rules first**: FAMILY-1/3 naming (free to fix)
3. **Then check build pipeline**: Three-Step Strong Sync
4. **Then check design issues**: WorldContext, protected UFUNCTION, etc.
5. **Fix with minimal scope**: Only change necessary files
6. **Regression verify**: Run related GM commands, check for new issues
7. **Capture insight**: If the bug reveals a new pattern, document it

## 6. HTML-to-UE Migration SOP

From HTML/Web prototype to UE+AngelScript:

1. **Deep read**: Extract rules, state machines, data models, UI interactions
2. **Scope confirmation**: What migrates, what doesn't, what defers
3. **8-doc skeleton**: Build all 8 documents before any code
4. **C++ baseline**: Enums, row structs, base classes (thin layer)
5. **AS registries**: Data layer with DataTables + GM commands
6. **Two-stage acceptance**: Log-level → GM E2E
7. **Doc sync + commit**: Layer commits (docs → code → verification)

## 7. Branch Isolation SOP

For single-agent development with build safety:

```
main (clean) → git checkout -b step/<id>-<name>
  → AI delivers code on branch
  → Human: Build + PIE acceptance
  → PASS → merge to main (--no-ff) + tag
  → FAIL → fix on branch, re-verify
```

Branch naming: `step/<step-id>-<feature-name>`

## 8. Multi-Agent Parallel SOP

For parallel development of independent modules:

### Prerequisites (Three Questions)
1. Are tasks independent? (no dependency → can parallel)
2. Do agents modify the same files? (no overlap → can parallel)
3. Do decisions depend on other agents' results? (no → can parallel)

### Execution
1. Define shared interfaces on main first
2. Create Git Worktrees for each agent
3. Each agent works on independent branch
4. Conflict detection after all complete
5. Sequential merge with per-merge build verification
6. Full acceptance after all merged

Recommended: 2-3 agents. Maximum: 4.

## 9. Code Review SOP

For structured review with review files:

1. Dev Agent self-checks against coding standards
2. Creates review request YAML file
3. Review Agent reads diff in independent worktree
4. Outputs review result YAML (APPROVED / CHANGES_REQUESTED / REJECTED)
5. Dev Agent fixes BLOCKER + MAJOR issues
6. Round increments until APPROVED
7. Merge with `--no-ff` preserving review history

Review severity: BLOCKER > MAJOR > MINOR > SUGGESTION
