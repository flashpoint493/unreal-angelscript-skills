# Community Wisdom — Distilled Consensus

## 1. Executive Decision Summary

| Dimension | Community Consensus |
|-----------|---------------------|
| **Maturity** | Production-grade; adopted in multiple shipped UE titles |
| **Iteration Speed** | #1 advantage. Save → instant. Repeatedly cited as the biggest win |
| **Engine Version** | `angelscript-master` branch. Build from source is recommended |
| **UInterface** | Not supported. Workaround: component + Cast |
| **Hot Reload Cost** | Stable runtime. But changing AS class triggers BP "dirty" state (can check-out many BPs) |
| **Plugin Compat** | Source plugins OK. Marketplace binary plugins **never compatible** |
| **Repository Access** | Requires Epic GitHub access (EULA) + access to the UE-AS fork |
| **Rollback** | AS→C++ transpile works but **still needs UE-AS runtime**. Not "back to pure UE" |
| **Debugging** | VSCode breakpoint debugging mature. C++ and AS breakpoints can relay (not simultaneous) |
| **Async/Coroutine** | No coroutine, no async/await, no inline Delay. Timer + Capability state machine only |
| **Performance** | Transpile + JIT approaches native C++ for typical workloads |
| **Console Support** | Windows/PS5/XSX continuously tested. Switch / Android / iOS limited or unsupported |
| **Team Engineering** | Perforce + UGS + RoboMerge for large teams. Git works for small teams |

## 2. One-Line Verdict

> AS is worth adopting, but budget 1 engine programmer for branch maintenance, abandon
> all Marketplace binary plugin dependencies, accept UInterface/async architecture
> compromises, and include engine upgrade costs in project milestones. Best ROI for
> iteration-sensitive games (MOBA, roguelike, co-op, ARPG). Use caution for
> third-party-ecosystem-heavy or Android/iOS-primary projects.

## 3. Version Cadence (General Pattern)

| Phase | UE-AS Status |
|-------|--------------|
| Earlier UE 5.x | Mainstream, tag-based releases, occasional pre-built binaries |
| Mid UE 5.x | Community ports for new UE releases on day-one |
| Recent | Pre-built binaries discontinued; build-from-source becomes the norm |
| Recent | Tags removed from public repo (EULA-driven). `master` / `release` branches only |

**Key Change**: Pre-built binaries are no longer published upstream.
All teams must build from source.

## 4. Project Adoption Decision Matrix

| Dimension | Good Fit | Caution |
|-----------|----------|---------|
| Project Type | Single-player, local co-op, content-driven, fast iteration | MMO, server-authoritative at scale |
| Team | Has dedicated engine programmer | No engine programmer, pure-BP team |
| Code Scale | Small-medium AS codebase | Very large (evaluate compile/load time) |
| Platform | PC / PS5 / Xbox Series X | Switch / Mobile (insufficient validation) |
| Third-Party | Self-developed plugins | Heavy Marketplace binary dependencies |
| Release Cycle | Long iteration (can lock AS version) | Emergency releases (need Epic same-day support) |
| Engine Lock | Can lock specific version | Must track latest Epic releases |

## 5. Risk Mitigation Strategies

### Engine Branch Maintenance
- Assign 1 engineer for branch maintenance (merge upstream, fix conflicts)
- Lock to specific tag/commit for stability
- Upgrade proactively (don't let gap grow beyond 2 minor versions)

### Plugin Compatibility
- All Marketplace binary plugins **will not work** with the UE-AS fork
- Source plugins generally work (may need minor fixes)
- Evaluate all plugin dependencies before adopting AS

### Team Onboarding
- C++ developers: 1-2 days to learn AS syntax
- VSCode + the official AngelScript extension is the standard toolchain
- Recommend: read pitfall diagnostics on day one

### Official Stance (paraphrased from public maintainer statements)

- No guarantee of support or bug fixes is provided.
- Building from source is the recommended path.
- Shipping with any third-party scripting solution requires technical
  expertise on the team.

This is an **open-source self-service tool**, not a plug-and-play product.

## 6. High-Frequency Pitfalls

1. **Repository 404** — Need Epic GitHub access first, then UE-AS fork access
2. **Hot reload "dirty" BPs** — Changing AS class marks BP children dirty even without real changes
3. **No Marketplace plugins** — Binary distribution incompatible with AS fork
4. **UInterface workarounds** — Component-based design + Cast is the community standard
5. **No async/await** — Timer + Capability state machine is the only path
6. **Build from source** — No more pre-built binaries
7. **AS transpile ≠ pure UE** — Transpiled C++ still depends on UE-AS runtime

---
*Ecosystem signals, version timelines, and official stances may evolve.
Always cross-check with the latest official documentation and public community
channels.*
