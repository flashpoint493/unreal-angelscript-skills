# Unreal AngelScript — AI Coding Skill Package

> A vendor-neutral, project-agnostic AI agent skill for Unreal Engine + AngelScript projects.
> Works with CodeBuddy, Claude Code, Cursor, Windsurf, Cline, Roo Code, Trae, Kiro, OpenCode, and any AGENTS.md-compliant agent.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/flashpoint493/unreal-angelscript-skills?display_name=tag)](https://github.com/flashpoint493/unreal-angelscript-skills/releases)

---

## What Is This?

A structured **AI agent skill package** that turns a general-purpose AI coding assistant into a specialized UE-AngelScript pair programmer.

- **10 reference documents** covering the full UE-AS development stack
- **12+ pitfall diagnostics** with symptom → root-cause → fix decision trees
- **9 workflow SOPs** (Standard Operating Procedures) for common development tasks
- **20 sub-skill taxonomy** with dependency graph and team role matrix
- **Vendor-neutral**: one skill source, fans out to every major AI agent

## Repository Layout

```
.
├── skills/
│   └── unreal-angelscript/      ← canonical source (single source of truth)
│       ├── SKILL.md
│       └── references/01..10.md
├── install.sh                   ← Linux / macOS installer
├── install.ps1                  ← Windows / PowerShell installer
├── .github/workflows/
│   ├── release.yml              ← tag → build multi-agent zip → GitHub Release
│   └── release-please.yml       ← conventional commits → release PR + tag
├── release-please-config.json
├── .release-please-manifest.json
└── CHANGELOG.md
```

## Install

### Option A — Auto-installer (recommended)

The installers download the latest GitHub Release, detect AI agent directories already present in your project (or prompt you to choose one), and copy the skill into place.

**Linux / macOS**

```bash
# Auto-detect agent dirs in current project
curl -fsSL https://raw.githubusercontent.com/flashpoint493/unreal-angelscript-skills/main/install.sh | bash

# Pin to a specific agent and version
curl -fsSL https://raw.githubusercontent.com/flashpoint493/unreal-angelscript-skills/main/install.sh \
  | bash -s -- --agent codebuddy --version 0.1.0

# Install for every supported agent at once
curl -fsSL https://raw.githubusercontent.com/flashpoint493/unreal-angelscript-skills/main/install.sh \
  | bash -s -- --agent all
```

**Windows (PowerShell)**

```powershell
# Auto-detect
iwr -useb https://raw.githubusercontent.com/flashpoint493/unreal-angelscript-skills/main/install.ps1 | iex

# With parameters: download once, then invoke as a script
$src = (iwr -useb https://raw.githubusercontent.com/flashpoint493/unreal-angelscript-skills/main/install.ps1).Content
& ([scriptblock]::Create($src)) -Agent cursor -Version 0.1.0
```

### Option B — Manual install from GitHub Release

1. Grab `unreal-angelscript-skill-<version>.zip` from the [Releases page](https://github.com/flashpoint493/unreal-angelscript-skills/releases).
2. Extract it to your agent's skills directory:

| AI agent      | Path (project scope)                            | Path (user scope)                                  |
|---------------|-------------------------------------------------|----------------------------------------------------|
| CodeBuddy     | `<project>/.codebuddy/skills/unreal-angelscript/` | `~/.codebuddy/skills/unreal-angelscript/`        |
| Claude Code   | `<project>/.claude/skills/unreal-angelscript/`    | `~/.claude/skills/unreal-angelscript/`           |
| Cursor        | `<project>/.cursor/skills/unreal-angelscript/`    | `~/.cursor/skills/unreal-angelscript/`           |
| Windsurf      | `<project>/.windsurf/skills/unreal-angelscript/`  | `~/.windsurf/skills/unreal-angelscript/`         |
| Cline         | `<project>/.cline/skills/unreal-angelscript/`     | —                                                  |
| Roo Code      | `<project>/.roo/skills/unreal-angelscript/`       | —                                                  |
| Trae          | `<project>/.trae/skills/unreal-angelscript/`      | —                                                  |
| Kiro          | `<project>/.kiro/skills/unreal-angelscript/`      | —                                                  |
| OpenCode      | `<project>/.opencode/skills/unreal-angelscript/`  | —                                                  |
| AGENTS.md spec| `<project>/.agents/skills/unreal-angelscript/` or `<project>/skills/unreal-angelscript/` | — |

> The `unreal-angelscript-multi-agent-<version>.zip` artifact ships pre-fanned-out copies for every directory above — extract it into your project root and you're done.

### Option C — Git submodule / clone

```bash
git clone https://github.com/flashpoint493/unreal-angelscript-skills.git
cp -R unreal-angelscript-skills/skills/unreal-angelscript ./.codebuddy/skills/
```

## How the Skill Works

When activated, the skill provides:

| Trigger | What the AI agent does |
|---------|------------------------|
| User pastes an AS error message | Walks the unified diagnostic decision tree in `references/03-pitfall-diagnostics.md` |
| User asks to set up a new UE-AS project | Loads `references/01-language-and-setup.md` |
| User starts implementing networking / UI / GAS | Loads the matching topic-specific reference |
| User asks for an architectural review | Cross-checks against the 7 core rules in `SKILL.md` |

See [`skills/unreal-angelscript/SKILL.md`](skills/unreal-angelscript/SKILL.md) for the full activation contract.

## Knowledge Map

```
skills/unreal-angelscript/references/
├── 01-language-and-setup.md       — AS syntax, C++ differences, environment setup
├── 02-ue-integration.md           — Actor/Component, networking, subsystems, blueprints
├── 03-pitfall-diagnostics.md      — 12+ pitfalls with diagnostic decision trees
├── 04-architecture-patterns.md    — Data-driven, strategy pattern, naming conventions
├── 05-workflow-sops.md            — 9 standardized workflows for UE+AS development
├── 06-performance-and-build.md    — Benchmarks, precompile, transpile, JIT, shipping
├── 07-ui-and-commonui.md          — UMG + CommonUI + AS-native logic, BindWidget, ListView
├── 08-gas-integration.md          — GAS plugin pitfalls and patterns
├── 09-community-wisdom.md         — Distilled community consensus, decision matrix
└── 10-skill-tree-and-learning.md  — 20 sub-skills, dependency graph, learning paths
```

## Releasing (maintainer notes)

Releases are automated via [release-please](https://github.com/googleapis/release-please-action) and a `release.yml` workflow.

1. Land commits on `main` using [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, …).
2. release-please opens / updates a `chore: release vX.Y.Z` PR with the proposed CHANGELOG.
3. Merge that PR. release-please then:
   - creates the git tag `vX.Y.Z`,
   - creates a GitHub Release,
   - dispatches `release.yml`, which builds and uploads the skill archives + `SHA256SUMS`.

To cut a release manually, push a tag (e.g. `git tag v0.1.0 && git push origin v0.1.0`) or run the `Release` workflow with a tag input.

## Contributing

PRs welcome. To keep the skill vendor-neutral and maintainable:

1. Edit only files under `skills/unreal-angelscript/` — multi-agent fan-out is generated by CI.
2. Keep content project-agnostic (no proprietary code, asset paths, or company-internal tooling).
3. Cite sources for non-obvious claims (community discussion link, official docs URL, or other public evidence).
4. Use Conventional Commits so release-please can compute the next version.

## License

[MIT](LICENSE) — see also the Attribution section in the LICENSE file.

---

# Unreal AngelScript — AI 编程技能包（中文）

> 厂商中立、项目无关的 UE+AngelScript AI agent 技能包。
> 兼容 CodeBuddy、Claude Code、Cursor、Windsurf、Cline、Roo Code、Trae、Kiro、OpenCode 以及任何遵循 AGENTS.md 规范的 agent。

## 这是什么？

一份结构化的 **AI agent skill 包**，把通用 AI 编程助手变成专业的 UE-AngelScript 结对编程伙伴。

- **10 份参考文档**，覆盖 UE-AS 全栈
- **12+ 踩坑诊断**，每个都有"症状 → 根因 → 修复"决策树
- **9 套标准化工作流 SOP**
- **20 个子技能**，含依赖图和团队角色矩阵
- **厂商中立**：单一源 + 自动分发到所有主流 AI agent

## 仓库结构

```
.
├── skills/
│   └── unreal-angelscript/      ← 单一真实源
│       ├── SKILL.md
│       └── references/01..10.md
├── install.sh                   ← Linux / macOS 安装脚本
├── install.ps1                  ← Windows / PowerShell 安装脚本
├── .github/workflows/
│   ├── release.yml              ← 打 tag → 构建多 agent zip → 发布 Release
│   └── release-please.yml       ← Conventional Commits → release PR + tag
├── release-please-config.json
├── .release-please-manifest.json
└── CHANGELOG.md
```

## 安装方式

### 方式 A — 一键脚本（推荐）

安装脚本会从 GitHub Release 下载最新版本，自动检测项目里已有的 AI agent 目录（或交互式询问），然后把 skill 复制到位。

**Linux / macOS**

```bash
# 自动检测当前项目里的 agent 目录
curl -fsSL https://raw.githubusercontent.com/flashpoint493/unreal-angelscript-skills/main/install.sh | bash

# 指定 agent 与版本
curl -fsSL https://raw.githubusercontent.com/flashpoint493/unreal-angelscript-skills/main/install.sh \
  | bash -s -- --agent codebuddy --version 0.1.0

# 一次性安装到所有受支持的 agent
curl -fsSL https://raw.githubusercontent.com/flashpoint493/unreal-angelscript-skills/main/install.sh \
  | bash -s -- --agent all
```

**Windows（PowerShell）**

```powershell
# 自动检测
iwr -useb https://raw.githubusercontent.com/flashpoint493/unreal-angelscript-skills/main/install.ps1 | iex

# 带参数：先下载内容，再以脚本块方式调用
$src = (iwr -useb https://raw.githubusercontent.com/flashpoint493/unreal-angelscript-skills/main/install.ps1).Content
& ([scriptblock]::Create($src)) -Agent cursor -Version 0.1.0
```

### 方式 B — 从 GitHub Release 手动安装

1. 从 [Releases 页面](https://github.com/flashpoint493/unreal-angelscript-skills/releases) 下载 `unreal-angelscript-skill-<版本>.zip`
2. 解压到对应 agent 的 skills 目录：

| AI agent      | 项目级路径                                          | 用户级路径                                        |
|---------------|-----------------------------------------------------|---------------------------------------------------|
| CodeBuddy     | `<project>/.codebuddy/skills/unreal-angelscript/`   | `~/.codebuddy/skills/unreal-angelscript/`         |
| Claude Code   | `<project>/.claude/skills/unreal-angelscript/`      | `~/.claude/skills/unreal-angelscript/`            |
| Cursor        | `<project>/.cursor/skills/unreal-angelscript/`      | `~/.cursor/skills/unreal-angelscript/`            |
| Windsurf      | `<project>/.windsurf/skills/unreal-angelscript/`    | `~/.windsurf/skills/unreal-angelscript/`          |
| Cline         | `<project>/.cline/skills/unreal-angelscript/`       | —                                                 |
| Roo Code      | `<project>/.roo/skills/unreal-angelscript/`         | —                                                 |
| Trae          | `<project>/.trae/skills/unreal-angelscript/`        | —                                                 |
| Claude            | `<project>/.Claude/skills/unreal-angelscript/`        | —                                                 |
| OpenCode      | `<project>/.opencode/skills/unreal-angelscript/`    | —                                                 |
| AGENTS.md 规范| `<project>/.agents/skills/unreal-angelscript/` 或 `<project>/skills/unreal-angelscript/` | — |

> `unreal-angelscript-multi-agent-<版本>.zip` 已经把上面所有目录预先展开好——解压到项目根目录即开即用。

### 方式 C — Git 子模块 / clone

```bash
git clone https://github.com/flashpoint493/unreal-angelscript-skills.git
cp -R unreal-angelscript-skills/skills/unreal-angelscript ./.codebuddy/skills/
```

## Skill 工作机制

技能激活后，AI agent 会按以下方式调用：

| 触发场景 | AI agent 的动作 |
|----------|-----------------|
| 用户粘贴 AS 报错信息 | 走 `references/03-pitfall-diagnostics.md` 里的统一诊断决策树 |
| 用户要新建 UE-AS 项目 | 加载 `references/01-language-and-setup.md` |
| 用户开始写网络 / UI / GAS | 加载对应主题的专项参考文档 |
| 用户要求架构评审 | 用 `SKILL.md` 中的 7 条核心规则交叉校验 |

完整激活契约见 [`skills/unreal-angelscript/SKILL.md`](skills/unreal-angelscript/SKILL.md)。

## 知识地图

```
skills/unreal-angelscript/references/
├── 01-language-and-setup.md       — AS 语法、与 C++ 差异、环境搭建
├── 02-ue-integration.md           — Actor/Component、网络复制、子系统、蓝图交互
├── 03-pitfall-diagnostics.md      — 12+ 踩坑录 + 统一诊断决策树
├── 04-architecture-patterns.md    — 数据驱动、策略模式、命名规范
├── 05-workflow-sops.md            — 9 套标准化工作流
├── 06-performance-and-build.md    — 性能基准、预编译、C++ 转译、JIT、发行构建
├── 07-ui-and-commonui.md          — UMG + CommonUI + AS 原生逻辑、BindWidget、ListView
├── 08-gas-integration.md          — GAS 插件集成模式与陷阱
├── 09-community-wisdom.md         — 社区经验蒸馏、立项决策矩阵
└── 10-skill-tree-and-learning.md  — 20 个子技能、依赖图、学习路径
```

## 发布流程（维护者）

发布通过 [release-please](https://github.com/googleapis/release-please-action) 与 `release.yml` 工作流自动化。

1. 在 `main` 上提交时使用 [Conventional Commits](https://www.conventionalcommits.org/)（`feat:`、`fix:`、`docs:` …）
2. release-please 会维护一个 `chore: release vX.Y.Z` PR，并自动更新 CHANGELOG
3. 合并该 PR 后，release-please 会：
   - 创建 git tag `vX.Y.Z`
   - 创建 GitHub Release
   - 触发 `release.yml`，构建并上传 skill 压缩包 + `SHA256SUMS`

如需手动发版，直接打 tag（`git tag v0.1.0 && git push origin v0.1.0`），或在 GitHub 网页上以 `tag` 输入参数手动运行 `Release` workflow。

## 贡献指南

欢迎 PR！为保持厂商中立和可维护性：

1. 只编辑 `skills/unreal-angelscript/` 目录下的内容——多 agent 分发由 CI 自动展开
2. 内容保持项目无关（不含私有代码、资产路径或公司内部工具）
3. 非显而易见的技术结论需标注来源（社区讨论链接、官方文档 URL 或其他公开证据）
4. 使用 Conventional Commits，便于 release-please 自动计算下一版本号

## 许可证

[MIT](LICENSE) — 同时参见 LICENSE 文件中的 Attribution（出处声明）部分。

