# Unreal AngelScript — AI Coding Skill Package

> A comprehensive, project-agnostic knowledge base for AI coding assistants working on Unreal Engine + AngelScript projects.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## What Is This?

This is a **CodeBuddy / AI Coding Assistant Skill** — a structured knowledge package that transforms a general-purpose AI into a specialized UE-AngelScript pair programmer. It contains:

- **10 reference documents** (~2,500 lines) covering the full UE-AS development stack
- **12+ pitfall diagnostics** with symptom → root-cause → fix decision trees
- **9 workflow SOPs** (Standard Operating Procedures) for common development tasks
- **20 sub-skill taxonomy** with dependency graphs and team role matrices

All content is distilled from:
- [Hazelight Studios](https://angelscript.hazelight.se/) public documentation
- Public community discussions and Q&A archives
- General production experience reported by teams using UE-AngelScript
- Chinese AS community wiki, knowledge base, and blog posts

## Quick Start

### Install as CodeBuddy Skill

1. Download `unreal-angelscript.zip`
2. In CodeBuddy, install from the `.zip` file  
   - **User scope** (all projects): `~/.codebuddy/skills/unreal-angelscript/`
   - **Project scope** (shared with team): `.codebuddy/skills/unreal-angelscript/`

### Manual Use

Browse the `references/` directory directly — each document is self-contained Markdown.

## Knowledge Map

```
references/
├── 01-language-and-setup.md      — AS syntax, C++ differences, environment setup
├── 02-ue-integration.md          — Actor/Component, networking, subsystems, blueprints
├── 03-pitfall-diagnostics.md     — 12+ pitfalls with diagnostic decision trees
├── 04-architecture-patterns.md   — Data-driven, strategy pattern, naming conventions
├── 05-workflow-sops.md           — 9 standardized workflows for UE+AS development
├── 06-performance-and-build.md   — Benchmarks, precompile, transpile, JIT, shipping
├── 07-ui-and-commonui.md         — UMG + CommonUI + AS-native logic, BindWidget, ListView
├── 08-gas-integration.md         — GAS plugin pitfalls and patterns
├── 09-community-wisdom.md        — Distilled community consensus, decision matrix
└── 10-skill-tree-and-learning.md — 20 sub-skills, dependency graph, learning paths
```

## Who Is This For?

| Audience | Use Case |
|----------|----------|
| **AI Coding Assistants** | Install as skill → get UE-AS domain expertise on demand |
| **UE-AS Developers** | Browse as reference docs → pitfall lookup, architecture patterns |
| **Tech Leads** | Read `09-community-wisdom.md` → AS adoption decision matrix |
| **New Team Members** | Follow `10-skill-tree-and-learning.md` → structured onboarding path |

## Key Highlights

- **Zero project-specific content** — fully generic, usable in any UE-AS project
- **Diagnostic decision tree** — paste an AS error message, get a step-by-step fix
- **7 core rules** always in context (Three-Step Strong Sync, ScriptName normalization, etc.)
- **Production-proven** — patterns validated in real shipped UE-AngelScript projects
- **Bilingual community** — includes Chinese AS community resources

## Data Freshness

UE-AngelScript and its plugin/tooling ecosystem evolve continuously. Version timelines, plugin compatibility, and community consensus may change. Always cross-check with:
- [Hazelight Official Docs](https://angelscript.hazelight.se/)
- The official UE-AngelScript community channels

## Contributing

PRs welcome! Each reference file is independent — you can update a single topic without touching others. Please:
1. Keep content project-agnostic (no proprietary code or asset paths)
2. Cite sources (Discord thread date, official doc URL, or shipped game evidence)
3. Use the established format (## sections, ```angelscript code blocks, ✅/❌ markers)

## License

[MIT](LICENSE) — see also the Attribution section in the LICENSE file.

---

# Unreal AngelScript — AI 编程技能包

> 面向 AI 编程助手的 UE+AngelScript 全栈知识库，项目无关、可独立发布。

## 这是什么？

这是一个 **CodeBuddy / AI 编程助手技能包**（Skill），可以让通用 AI 变成专业的 UE-AngelScript 结对编程伙伴。包含：

- **10 份参考文档**（约 2,500 行），覆盖 UE-AS 开发全链路
- **12+ 踩坑诊断**，每个都有"症状 → 根因 → 修复"决策树
- **9 套标准化工作流 SOP**，覆盖 Registry 扩展、Spike 验证、Bug 修复等
- **20 个子技能分类**，含依赖图和团队角色矩阵

知识来源：
- [Hazelight Studios](https://angelscript.hazelight.se/) 公开文档
- 社区公开讨论与问答归档
- UE-AngelScript 团队公开分享的工程经验
- 中文 AS 社区 Wiki、知识库、博客文章

## 快速使用

### 安装为 CodeBuddy 技能

1. 下载 `unreal-angelscript.zip`
2. 在 CodeBuddy 中安装
   - **用户级**（所有项目可用）：`~/.codebuddy/skills/unreal-angelscript/`
   - **项目级**（团队共享）：`.codebuddy/skills/unreal-angelscript/`

### 直接浏览

`references/` 目录下每个文档都是独立的 Markdown，可直接阅读。

## 知识地图

```
references/
├── 01-language-and-setup.md      — AS 语法、与 C++ 差异、环境搭建
├── 02-ue-integration.md          — Actor/Component、网络复制、子系统、蓝图交互
├── 03-pitfall-diagnostics.md     — 12+ 踩坑录 + 统一诊断决策树
├── 04-architecture-patterns.md   — 数据驱动、策略模式、命名规范、Spike 方法论
├── 05-workflow-sops.md           — 9 套标准化工作流（Registry 扩展、Bug 修复等）
├── 06-performance-and-build.md   — 性能基准、预编译、C++ 转译、JIT、发行构建
├── 07-ui-and-commonui.md         — UMG + CommonUI + AS 原生逻辑、BindWidget、ListView
├── 08-gas-integration.md         — AngelscriptGAS 插件集成模式与陷阱
├── 09-community-wisdom.md        — 社区经验蒸馏、立项决策矩阵
└── 10-skill-tree-and-learning.md — 20 个子技能、依赖图、团队角色矩阵、学习路径
```

## 适用人群

| 受众 | 用法 |
|------|------|
| **AI 编程助手** | 安装为 Skill → 按需获取 UE-AS 领域专业知识 |
| **UE-AS 开发者** | 当参考文档用 → 踩坑速查、架构模式参考 |
| **技术负责人** | 读 `09-community-wisdom.md` → AS 立项决策矩阵 |
| **新入职成员** | 按 `10-skill-tree-and-learning.md` → 结构化入门路径 |

## 核心亮点

- **零项目耦合** — 完全通用，适用于任何 UE-AS 项目
- **诊断决策树** — 粘贴 AS 报错信息，获得逐步修复指引
- **7 条核心规则** 常驻上下文（三步强同步、ScriptName 规范化等）
- **生产验证** — 模式来自真实 UE-AS 项目的工程实践
- **中英双语社区** — 包含中文 AS 社区资源

## 数据时效

UE-AngelScript 及其插件/工具生态持续演进，版本时间线、插件兼容性和社区共识可能持续变化。请以下列渠道为准：
- [Hazelight 官方文档](https://angelscript.hazelight.se/)
- UE-AngelScript 官方社区渠道

## 贡献指南

欢迎 PR！每个 reference 文件独立维护，更新单一话题无需修改其他文件。请遵循：
1. 保持项目无关（不包含私有代码或资产路径）
2. 标注来源（社区讨论链接、官方文档 URL 或其他公开证据）
3. 使用现有格式（## 分节、\`\`\`angelscript 代码块、✅/❌ 标记）

## 许可证

[MIT](LICENSE) — 详见 LICENSE 文件中的 Attribution 部分。
