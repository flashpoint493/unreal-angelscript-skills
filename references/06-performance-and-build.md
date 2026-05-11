# Performance Optimization & Build Pipeline

## 1. Performance Benchmarks

### AS vs Other Solutions
| Solution | Relative to C++ | Hot Reload | Text-based |
|----------|-----------------|------------|------------|
| C++ | 100% | ❌ (5-15 min) | ✅ |
| AS Bytecode (dev) | ~65-70% | ✅ (<1s) | ✅ |
| AS Precompiled | ~65-70% | ❌ | ✅ |
| AS Transpiled C++ (ship) | ~95%+ | ❌ | ✅ |
| Blueprint | ~30-40% | Partial | ❌ (binary) |
| Lua (third-party) | ~50-60% | ✅ | ✅ |

**Key Fact**: In shipping builds, AS code can be transpiled to C++ and compiled back
into the engine, achieving near-native performance. No performance compromise needed.

### Production Observations
- Large UE-AS codebases routinely run with hot reload measured in seconds
- Hot reload: typically <1 second for non-structural edits
- PIE changes: non-structural edits take effect instantly during play

## 2. Coding-Level Optimization

### Use FName Literals
```angelscript
// ✅ Compile-time FName — zero runtime lookup
FName Tag = n"Player.Health";

// ❌ Runtime FName construction — table lookup every call
FName Tag = FName("Player.Health");
```

### Cache Expensive Lookups
```angelscript
// ❌ Bad: Subsystem lookup every frame
UFUNCTION(BlueprintOverride)
void Tick(float DeltaTime)
{
    UMySubsystem Sub = GetWorld().GetSubsystem<UMySubsystem>();
    Sub.Update(DeltaTime);
}

// ✅ Better: Cache reference (if subsystem lifetime is guaranteed)
private UMySubsystem CachedSub;
UFUNCTION(BlueprintOverride)
void BeginPlay()
{
    CachedSub = GetWorld().GetSubsystem<UMySubsystem>();
}
```

### Event-Driven Over Polling
```angelscript
// ❌ Bad: Check every frame
void Tick(float DeltaTime)
{
    if (Health != LastHealth) { UpdateUI(); LastHealth = Health; }
}

// ✅ Better: React to change
UPROPERTY(ReplicatedUsing = OnRep_Health)
float Health;
UFUNCTION()
void OnRep_Health() { UpdateUI(); }
```

### Minimize DataTable Queries in Hot Paths
- Cache DataTable query results during initialization
- Don't call `FindRow` every frame
- Build lookup maps (TMap) at load time

## 3. Precompiled Cache

### How It Works
`PrecompiledScript.Cache` contains pre-parsed bytecode with hardcoded C++ property
offsets and struct sizes. Skips parsing and compilation at startup.

### Critical Constraints
- Cache is **binary-bound**: must be paired with the exact same C++ binary
- Adding `AS_JITTED_CODE/` requires recompiling the exe
- Hot reload is **disabled** when using precompiled cache
- Debugging is **disabled** in precompiled mode
- Use `-as-development-mode` to bypass in dev builds

### Generation
```
Editor Console: Angelscript.PrecompileScripts
→ Generates Script/PrecompiledScript.Cache
```

## 4. C++ Transpilation (Shipping)

### How It Works
AS code is transpiled to C++ source files, then compiled with the engine binary.
Result: near-native C++ performance (~95%+).

### Process
1. Editor Console: `Angelscript.TranspileToNative`
2. Generated C++ goes to `AS_JITTED_CODE/` directory
3. Rebuild engine with transpiled code included
4. Ship the resulting binary

### Important Notes
- Transpiled C++ **still depends on UE-AS runtime** — not a "back to pure UE" escape
- Transpilation has been used in shipped UE-AS titles for years

## 5. JIT Compilation

### Available Projects
| Project | Type | Status | Performance Gain |
|---------|------|--------|-----------------|
| asaot | AOT (Ahead-of-Time) | Stable | Compile-time optimization |
| asllvm | JIT (LLVM-based) | Alpha | +0-40% runtime |
| angelsea | JIT (community) | Alpha | Varies |

### Considerations
- JIT is opt-in and experimental
- Most projects use precompiled cache (dev) + transpilation (ship)
- JIT primarily benefits compute-heavy AS code paths

## 6. Shipping Build Checklist

1. ✅ All AS code compiles without errors
2. ✅ PrecompiledScript.Cache generated and validated
3. ✅ (Optional) Transpile to C++ for maximum performance
4. ✅ Test with `-as-development-mode` disabled
5. ✅ Verify debug features are stripped
6. ✅ Platform-specific testing (PC/PS5/XSX validated by community/production)
7. ⚠️ Android/iOS: no official hot-reload channel
8. ⚠️ Switch: community attempts exist, no official support

## 7. Build Configuration

### BuildConfiguration.xml Recommendations
```xml
<Configuration>
    <ParallelExecutor>
        <MaxProcessorCount>12</MaxProcessorCount>
        <ProcessorCountMultiplier>1.0</ProcessorCountMultiplier>
    </ParallelExecutor>
</Configuration>
```

### Installed Build Note
Pre-built binaries are no longer published by upstream. Projects should build the
engine from source. The `angelscript-master` branch is the recommended target.

---
*Performance benchmarks, engine version support, and JIT project statuses evolve
continuously. Always verify against the latest official documentation and
community sources.*
