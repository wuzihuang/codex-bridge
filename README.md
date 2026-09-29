<div align="center">

# codex-bridge

**让 Claude Code 直接用上 Codex 的图像能力：生图、改图、透明底、看图。自动跟随 Codex 最新模型，不需要 OpenAI API Key。**

**Let Claude Code use Codex's image features — generate, edit, transparent PNGs, vision — always on the newest Codex model. No OpenAI API key.**

[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-D97757)](https://code.claude.com/docs/en/plugins)
[![Version](https://img.shields.io/badge/version-1.2.0-blue)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![No API key required](https://img.shields.io/badge/OpenAI%20API%20key-not%20required-brightgreen)](#为什么不需要-api-key)

[中文](#中文) · [English](#english)

</div>

<div align="center">
<img src="assets/demo-fox.png" width="260" alt="透明底狐狸吉祥物"> &nbsp;&nbsp; <img src="assets/demo-fox-scarf.png" width="260" alt="同一只狐狸加上蓝色围巾">

<sub>左：<code>--transparent</code> 一次生成的原生透明底 PNG。右：把左图作为 <code>--ref</code>，只加一条围巾，其余像素级保持不变。两张都由本插件在 gpt-6-astra 上生成。</sub>
</div>

---

<a id="中文"></a>

## 这是什么

Claude Code 自己不能画图。Codex CLI 可以：它内置 **gpt-image-2** 图像工具，走的是你的 **ChatGPT 会员额度**，跟 Claude 的额度完全分开。

这个插件把两边接起来：

- **生图**：你说「做一个 App 图标」「来张首页 Banner」，Claude 负责写好提示词、调 Codex 出图，然后**自己打开图片检查**，不对就重画。
- **改图**：给一张现有图片，只改你说的地方，其他保持不变。
- **透明底**：原生 alpha 通道，一步出 PNG，不用抠绿幕。
- **风格参考**：拿一张图当风格样板，画一张新的、风格一致的图。
- **让 Codex 看图**：截图对比设计稿、检查生成图是否符合要求、读图表数据。
- **Codex 子代理**：代码审查、排查 bug、批量改代码，也可以交给 Codex 做，省 Claude 的上下文。

### 永远用最新模型

插件不写死任何模型名。每次调用前它都会读 Codex 的**实时模型目录**（`codex debug models`），自动选出最新的模型。OpenAI 一发新模型，你 `codex update` 一下就能用上，插件不用改。

```console
$ codex-models
MODEL          NAME           REASONING                        INPUT
gpt-6-astra    GPT-6-Astra    low,medium,high,xhigh,max,ultra  text+image
gpt-6-sol      GPT-6-Sol      low,medium,high,xhigh,max,ultra  text+image
gpt-6-luna     GPT-6-Luna     low,medium,high,xhigh,max        text+image
...
$ codex-models --latest
gpt-6-astra
```

<a id="为什么不需要-api-key"></a>
> **为什么不需要 API Key？** 所有调用都走 `codex login` 的 ChatGPT 登录态，消耗的是 ChatGPT Plus / Pro / Team 的额度，不是 API 余额。

## 安装

**前置条件**

| | |
| :-- | :-- |
| Codex CLI | `npm i -g @openai/codex` 或 `brew install codex`（建议 ≥ 0.158） |
| 已登录 | `codex login`，然后 `codex login status` 应显示 *Logged in using ChatGPT* |
| ChatGPT 会员 | Plus、Pro 或 Team |
| Claude Code | 当前任意版本 |
| python3 | 读取模型目录用（macOS 自带） |

**在 Claude Code 里运行：**

```
/plugin marketplace add wuzihuang/codex-bridge
/plugin install codex-bridge@codex-bridge
```

或者在终端：

```bash
claude plugin marketplace add wuzihuang/codex-bridge
claude plugin install codex-bridge@codex-bridge
```

装好后执行 `/reload-plugins`，或重开一个会话。

**升级：**

```bash
claude plugin marketplace update codex-bridge
codex update
```

第一行更新插件，第二行更新 Codex 本身（新模型随 Codex 更新而来）。

## 快速上手

装好之后直接用自然语言说就行，Claude 会自己选对应的技能：

> 帮我生成一个透明底的狐狸吉祥物，扁平贴纸风格，存到 assets/fox.png

> 把 assets/hero.png 的天空改成黄昏橙色，其他别动

> 照着 icons/home.png 的风格，再画一个设置齿轮图标

> 给这个项目做一整套 favicon 和 OG 分享图

> 让 Codex 看看 shots/login.png 和设计稿 design/login.png 有哪些差异

也可以在终端里直接调用：

```bash
# 生成
codex-imagegen "扁平矢量纸飞机图标，单色 #2563EB，白底，居中留白" ./send.png

# 透明底（原生 alpha）
codex-imagegen "圆滚滚的橙色小狐狸，贴纸风格，粗描边" ./fox.png --transparent

# 改图：--ref 是要修改的图
codex-imagegen "给狐狸加一条蓝色围巾，其他保持完全一致" ./fox-scarf.png --ref ./fox.png --transparent

# 风格参考：--style-ref 只借风格，不改原图
codex-imagegen "设置齿轮图标" ./settings.png --style-ref ./home.png

# 大尺寸
codex-imagegen "赛博朋克城市夜景，电影感" ./city.png --size 3840x2160

# 让 Codex 看图
codex-run -e low -i ./shot.png -i ./mock.png "图1是实现截图，图2是设计稿，列出所有视觉差异"
```

## 功能一览

### 技能（Claude 自动触发）

| 技能 | 什么时候用 |
| :-- | :-- |
| `generate-image` | 需要一张新图：图标、Logo、Banner、插画、产品图、纹理 |
| `edit-image` | 修改现有图片：换背景、改颜色、改文字、出变体 |
| `asset-set` | 一整套风格统一的素材：favicon、App 图标、OG 卡片、图标族 |
| `codex-vision` | 让 Codex 看图：截图对比设计稿、检查生成结果、读图表 |
| `ask-codex` | 就当前仓库问 Codex 一个问题 |
| `codex-review` | 让 Codex 审查一份 diff / 分支 / PR |
| `codex-delegate` | 判断一项工作是否值得交给 Codex 做，并负责编排 |

### 子代理

| 子代理 | 职责 |
| :-- | :-- |
| `codex-artist` | 批量出图，先出一张锚定风格给你确认，再出其余 |
| `codex-reviewer` | 代码审查，每条问题都回到代码里核实 |
| `codex-debugger` | 定位失败原因并给出补丁（只读） |
| `codex-implementer` | 大批量机械改动（需你同意，要求工作区干净） |
| `codex-second-opinion` | 就设计取舍给出独立意见 |

### 命令行工具

插件启用后，下面三个命令会在 Claude 的 `PATH` 里：

**`codex-imagegen "<提示词>" <输出.png> [选项]`**

| 选项 | 说明 |
| :-- | :-- |
| `--size WxH` | 默认 1024x1024。常用：`1536x1024` `1024x1536` `2048x2048` `2048x1152` `3840x2160` `2160x3840` |
| `--ref <文件>` | 要**修改**的图，可重复 |
| `--style-ref <文件>` | 只作**风格参考**，生成新图，可重复（与 `--ref` 合计最多 4 张） |
| `--transparent` | 原生透明底，并校验 PNG 确实带 alpha 通道 |
| `--model <名称>` | 默认 `latest`（自动选最新）；`default` 表示用你 `~/.codex/config.toml` 里的模型 |
| `--effort <档位>` | 推理强度，默认 `medium`。出图主要靠图像模型，调高只会更慢 |
| `--timeout <秒>` | 默认 600 |

自定义尺寸需同时满足：最长边 ≤ 3840，两边都是 16 的倍数，长宽比 ≤ 3:1，总像素在 655,360 到 8,294,400 之间。

**`codex-run [选项] "<任务>"`**：把一个任务交给 Codex，只返回最终回答。

| 选项 | 说明 |
| :-- | :-- |
| `-C <目录>` | 工作目录 |
| `-s <模式>` | `read-only`（默认）/ `workspace-write` / `danger-full-access` |
| `-m <模型>` | 默认 `latest` |
| `-e <档位>` | 推理强度，默认沿用你的 Codex 配置 |
| `-i <图片>` | 附图给 Codex 看，可重复 |
| `-r` | 接着上一次会话继续问 |
| `--schema <文件>` | 用 JSON Schema 约束回答格式 |
| `--timeout <秒>` | 默认 900 |

**`codex-models [--latest | --json]`**：列出你账号可用的模型，或只打印最新的那个。

### 环境变量

| 变量 | 作用 |
| :-- | :-- |
| `CODEX_BRIDGE_MODEL` | 两个命令的默认模型（默认 `latest`） |
| `CODEX_BRIDGE_IMAGE_EFFORT` | 出图时的推理强度（默认 `medium`） |
| `CODEX_BRIDGE_EFFORT` | `codex-run` 的推理强度（默认沿用 Codex 配置） |

想固定用某个模型，比如 `gpt-6-sol`：在 shell 配置里加 `export CODEX_BRIDGE_MODEL=gpt-6-sol`。

## 工作原理

```
你 ──▶ Claude  写提示词 / 拆任务 / 检查结果
          │
          ▼
   codex-imagegen / codex-run
          │   先用 codex-models 从实时目录里选出最新模型
          ▼
   codex exec -m <最新模型> ──▶ 内置 $imagegen 工具 ──▶ gpt-image-2
                                  （走你的 ChatGPT 额度）
```

出图时，wrapper 在输出目录里以 `workspace-write` 沙箱运行 `codex exec`，让 Codex 调用内置的 `$imagegen` 技能，并把 PNG 存到指定路径。之后 wrapper 会检查文件是否真的是 PNG（校验文件头），如果 Codex 存成了 `out-v2.png` 或存到了 `~/.codex/generated_images/<会话>/`，也会找回来，最后打印真实的绝对路径，Claude 再读图验收。

## 注意事项

- **消耗额度。** 一次出图大约相当于 3 到 5 次文字对话的 ChatGPT 额度。批量出图前 Claude 会先告诉你数量。
- **比较慢。** 每张图约 1 到 2 分钟（实测 gpt-6-astra 生成约 80 秒，改图约 85 秒）。
- **Codex 看不到你和 Claude 的对话。** 所有提示词都必须自成一体，所以子代理都会在汇报前核实结果。
- **平台。** macOS 和 Linux，Windows 未测试。

## 常见问题

| 现象 | 解决办法 |
| :-- | :-- |
| `codex CLI not found on PATH` | 安装 Codex CLI 后重开终端 |
| `codex is not logged in` | 运行 `codex login`，用 `codex login status` 确认 |
| `could not resolve the latest model` | `codex debug models` 读不到目录，会自动退回你配置里的默认模型；可运行 `codex update` 后重试 |
| 用的不是最新模型 | 先 `codex update`，再 `codex-models` 看看目录里有什么；检查是否设置了 `CODEX_BRIDGE_MODEL` |
| `--transparent was requested but the PNG has no alpha channel` | 重试一次；仍不行就用 `generate-image` 技能里的绿幕抠图备选方案 |
| 得到的是 `out-v2.png` 而不是 `out.png` | 正常现象，Codex 不愿覆盖已有文件；以 wrapper 打印的路径为准 |
| 出图很慢 | 你的 Codex 全局推理强度可能是 `xhigh`；出图默认已压到 `medium`，也可以 `--effort low` |
| Codex 输出里一堆 MCP / hook 报错 | 这是你 Codex 配置里的，不影响出图；精简 `~/.codex/config.toml` 里不用的 MCP 可以加快速度 |
| 技能没出现 | `/reload-plugins`，或新开一个会话 |
| `Operation not permitted` | `~/.codex` 权限问题：`sudo chown -R $(whoami) ~/.codex` |

---

<a id="english"></a>

## English

Claude Code can't draw. The Codex CLI can — its built-in image tool runs **gpt-image-2** on your **ChatGPT plan**, a budget separate from Claude. This plugin connects them.

**What you get**

- **Generate** images: Claude writes the prompt, drives Codex, then opens the PNG and checks it before calling it done.
- **Edit** an existing image (`--ref`), changing only what you describe.
- **Native transparent PNGs** (`--transparent`), verified to carry a real alpha channel.
- **Style references** (`--style-ref`): a new image in the style of an existing one.
- **Codex vision** (`codex-run -i`): screenshot vs mock diffs, checking an asset against its brief, reading charts.
- **Codex subagents** for review, debugging, and bulk implementation.

**Always the newest model.** Nothing is hard-coded. Before every call the wrappers read Codex's live model catalog (`codex debug models`) and pick the newest model, so when OpenAI ships one, `codex update` is all it takes. Run `codex-models` to see what your account has. Override with `--model <slug>`, `--model default` (your `~/.codex/config.toml`), or `CODEX_BRIDGE_MODEL`.

**Install**

```bash
claude plugin marketplace add wuzihuang/codex-bridge
claude plugin install codex-bridge@codex-bridge
```

Requires the Codex CLI (`npm i -g @openai/codex`), `codex login` with a ChatGPT Plus/Pro/Team plan, and `python3`.

**Examples**

```bash
codex-imagegen "flat vector paper-plane icon, #2563EB on white" ./send.png
codex-imagegen "round orange fox mascot, sticker style" ./fox.png --transparent
codex-imagegen "add a small blue scarf, keep everything else identical" ./fox-scarf.png --ref ./fox.png --transparent
codex-imagegen "a settings gear icon" ./settings.png --style-ref ./home.png
codex-run -e low -i ./shot.png -i ./mock.png "Image 1 is the build, image 2 the mock. List every visual difference."
codex-models --latest
```

See the Chinese sections above for the full option tables, environment variables, and troubleshooting — the commands and flags are the same.

## 开发 / Contributing

```bash
claude plugin validate .
bash test/smoke.sh
```

`test/smoke.sh` 不消耗额度，发布前跑一遍。/ `test/smoke.sh` spends no quota; run it before every release.

## 致谢 / Credits

- 原作者 / Original author: [Sateezg/codex-bridge](https://github.com/Sateezg/codex-bridge) — 1.1.2 及之前的全部工作 / everything through 1.1.2
- [openai/codex](https://github.com/openai/codex) — Codex CLI 及其 `$imagegen` 技能

## License

MIT，见 [LICENSE](LICENSE)。
