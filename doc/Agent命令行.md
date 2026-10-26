# Agent 命令行

这份说明讲终端里的 `agent` 程序，对应本机 CLI `2026.10.19`。Vim 窗口的 `:Agent`、`:AgentTab`、`:AgentHide` 在 `Agent使用文档.md`，用 `:help Agent` 打开。命令行部分用 `:help agent-cli`。

版本更新后，以本机 `agent --help` 和界面里的 `/help` 为准。官方说明：<https://cursor.com/docs/cli/overview>。

## 启动

不写子命令就进入交互界面。当前目录是工作区。

```bash
agent
agent "看 scan.c 里扫描超时是怎么处理的"
agent --mode ask "这个函数会改寄存器吗"
agent --plan "给关联失败补一条日志，先出方案"
```

| 命令 | 作用 |
| --- | --- |
| `agent --help` | 总帮助 |
| `agent help 子命令` | 某一条的帮助，例如 `agent help mcp` |
| `agent -v` | 版本号 |

## 登录和账号

```bash
# Linux 安装
curl https://cursor.com/install -fsS | bash
```

装好后一般在 `~/.local/bin/agent`。

| 命令 | 作用 |
| --- | --- |
| `agent login` | 浏览器登录 |
| `NO_OPEN_BROWSER=1 agent login` | 不弹浏览器 |
| `agent logout` | 退出并清掉本机保存的登录 |
| `agent status` | 当前账号。`whoami` 相同 |
| `agent status --format json` | 同上，JSON |
| `agent about` | 版本、系统、当前模型、账号 |
| `agent about --format json` | 同上，JSON |
| `agent update` | 升级 CLI |
| `agent models` | 这个账号能用的模型 |
| `agent --list-models` | 列出模型后退出 |
| `agent team list` | 账号所属团队 |
| `agent team switch` | 交互式切换团队 |
| `agent team switch 团队名或id` | 直接切换 |

脚本里用环境变量，不要把 key 写进仓库：

```bash
export CURSOR_API_KEY=...
agent -p "这个仓库的扫描入口在哪"
```

`--api-key` 与 `CURSOR_API_KEY` 相同。换服务地址用 `--endpoint` 或 `CURSOR_API_ENDPOINT`。`-H 'Name: Value'` 可重复，给请求加头。

换团队后，模型和设置按该团队计算。

## 交互按键

这些键打在 Agent 自己的界面里。包在 Vim 终端里时，状态栏不能有 `(Terminal)`，否则键会先被 Vim 吃掉。

| 按键 | 作用 |
| --- | --- |
| 回车 | 发送 |
| `Ctrl-J` | 换行，不发送。tmux 里用这个 |
| `Shift-Enter` | 部分终端的换行。tmux 里通常无效 |
| 向上 | 翻出以前输入过的问题，不含回答 |
| `Shift-Tab` | 在 Agent、Plan、Ask 之间轮换 |
| `Ctrl-R` | 查看这轮改过的文件。上下翻内容，左右换文件，`i` 补充要求 |
| `Ctrl-C` | 打断当前这一轮 |
| `Ctrl-D` | 连按两次退出 |
| `/quit`、`/exit` | 退出 |
| `!` | 在空行上进入 Shell 模式，跑本机命令 |
| `@路径` | 把文件或目录放进上下文 |
| `&` | 写在一条消息开头，交给云端 Agent。之后到 cursor.com/agents 看 |

终端命令默认要确认：`y` 允许，`n` 拒绝。

## 三种模式

| 模式 | 行为 | 怎么进 |
| --- | --- | --- |
| Agent | 搜代码、改文件、跑命令 | 默认 |
| Plan | 先出方案，会追问 | `/plan`、`--plan`、`--mode plan`、`Shift-Tab` |
| Ask | 只问答。不改文件，也不跑命令 | `/ask`、`--mode ask` |
| Debug | 调试 | `/debug`，可带问题 |

```bash
agent --mode ask "mlme 里认证失败会走到哪"
agent --plan "只读，先列出要改的函数"
```

`/ask` 再打一次就关掉。`/goal 目标` 给一个要一直做到完的目标。

## 斜杠命令

输入 `/` 弹出列表，方向键选择，回车执行。`/help` 看总表，`/help 命令名` 看一条。

### 模型

| 命令 | 作用 |
| --- | --- |
| `/model [过滤词]` | 选模型。`Tab` 可编辑 |
| `/fast` | 开关当前模型的 fast |
| `/max-mode` | 旧的按请求计费方案里开关 Max Mode |

```bash
agent --model gpt-5 "看一下编译选项"
agent --model 'claude-opus-4-8[context=1m,effort=high,fast=false]'
```

### 对话

| 命令 | 作用 |
| --- | --- |
| `/clear` | 新开一轮。`/new`、`/new-chat`、`/newchat` 相同 |
| `/resume` | 列出最近的对话并选一个接着聊 |
| `/fork` | 从当前对话分出一轮新的 |
| `/rename 名字` | 给当前对话改名 |
| `/summarize` | 把前文压短。`/compress`、`/compact` 相同 |
| `/rewind` | 退回到以前某一条消息。用来撤销，不是用来浏览 |
| `/copy` | 把以前某条消息复制出来。`/clipboard`、`/paste` 相同 |
| `/btw 问题` | 旁边问一句。回答不写入这轮历史 |
| `/full-conversation` | 画面被截断后，重新把整段对话画出来 |

`/full-conversation` 只影响画面，不减少上下文。上下文太长时用 `/summarize`。

### 执行和权限

| 命令 | 作用 |
| --- | --- |
| `/run-everything [on\|off\|status]` | 命令不再逐条确认。`/auto-run` 相同 |
| `/auto-review [on\|off\|status]` | 安全的工具调用自动放行，其余仍要确认。`/smart-auto` 相同 |
| `/shell [命令]` | Shell 模式。`/sh`、`/run` 相同 |
| `/sandbox` | 看或改沙箱和网络访问 |

启动时对应的参数：

| 参数 | 作用 |
| --- | --- |
| `-f`、`--force`、`--yolo` | 命令不必逐条确认。明确拒绝的除外 |
| `--auto-review` | 服务端分类后，安全的直接跑，其余仍询问 |
| `--sandbox enabled\|disabled` | 强制开关沙箱，盖过配置 |

### 界面和其它

| 命令 | 作用 |
| --- | --- |
| `/vim` | 输入框里用 `hjkl`、`dd`、`cw`。不管输出区翻页 |
| `/zen-mode` | 工具调用收成一行。`/zen` 相同 |
| `/line-numbers` | 代码块行号 |
| `/show-thinking` | 思考过程 |
| `/status-indicators` | 终端标题里的状态 |
| `/static-indicator [on\|off\|toggle\|status]` | 静态分隔 |
| `/setup-terminal` | 配置换行键 |
| `/config` | 交互式改 CLI 设置 |
| `/about` | 版本、系统和账号，并复制到剪贴板 |
| `/logs` | 调试日志路径 |
| `/update` | 升级 CLI |
| `/feedback 内容` | 把反馈发给 Cursor |
| `/open` | 用 Cursor 打开仓库根目录。`/cursor` 相同 |
| `/logout` | 退出登录 |
| `/mcp list` | MCP 服务器状态 |
| `/mcp list-tools 名字` | 某个 MCP 的工具 |
| `/plugin list` | 已安装插件 |

在 `/` 列表里选中一条技能后回车，只挂到这一条消息。`Option-Enter`（Linux 上常是 `Alt-Enter`）会把它收成自定义模式，直到退出该模式。

## 上下文和规则

用 `@` 把范围收窄：

```text
@hal_apollo/mac80211/scan.c 看隐藏 ssid 的匹配
@hal_apollo/mac80211 关联失败时日志从哪打
```

图片和补丁写路径即可，它会自己去读：

```bash
agent -p "对照 ./screenshot.png 和 scan.c 里的打印"
```

和编辑器同一套规则，有就自动带上：

| 位置 | 作用 |
| --- | --- |
| `.cursor/rules` | 按规则文件自己的配置生效 |
| 仓库根目录 `AGENTS.md` | 有就用 |
| 仓库根目录 `CLAUDE.md` | 有就用 |

一条消息开头加 `&`，把任务交给云端 Agent，本机可以关掉。之后到 <https://cursor.com/agents> 继续。

## 会话

| 命令 | 作用 |
| --- | --- |
| `agent` | 新的交互会话 |
| `agent resume` | 打开最近一次 |
| `agent --continue` | 同上 |
| `agent ls` | 先列出，再选一次旧的 |
| `agent --resume 会话id` | 指定某一次 |
| `/resume` | 已经在界面里时用 |
| `agent create-chat` | 只创建空会话并打印 id，不进入界面 |

终端或 SSH 断开后还要继续跑：

```bash
agent persist "把扫描超时的日志补全"
agent persist list
agent persist attach 会话
agent persist stop 会话
```

界面里 `/detach` 是离开，但保持这个持久会话继续跑。

`/rewind` 会回到以前某一条消息，适合撤销走错的一轮。只想再看内容时用 `/full-conversation`。

## 脚本和打印

`-p` / `--print` 不进入界面，把结果打到标准输出。本机帮助写明：这种模式可以使用写文件和 shell。

```bash
agent -p "这个驱动的扫描入口在哪个文件"
agent -p --mode ask "只解释，不要改文件"
agent -p --force "给 scan.c 的超时路径补一行日志"
agent -p --output-format json "列出和隐藏 ssid 相关的函数"
```

脚本里要直接改仓库时加 `--force`。只想要回答时用 `--mode ask`，不要加 `--force`。

`--output-format` 只能和 `--print` 一起用：

| 值 | 结果 |
| --- | --- |
| `text` | 默认。最后的回答 |
| `json` | 一整段结构化结果 |
| `stream-json` | 按事件往外吐 |

`stream-json` 再加 `--stream-partial-output`，会把未完成的文本也一段段打出。

`--trust` 跳过工作区信任提示，只适合无界面。`--approve-mcps` 自动批准已配置的 MCP。

## 工作区

```bash
agent --workspace /path/to/repo
agent --workspace 已保存的工作区名
agent --add-dir /path/to/other
```

`--add-dir` 可重复。

在单独的 git worktree 里改，不动当前检出。目录在 `~/.cursor/worktrees/<仓库名>/<名字>`，省略名字时自动生成。

```bash
agent --worktree "修扫描超时"
agent --worktree scan-timeout "同上，目录名固定"
agent --worktree-base 分支名 --worktree fix "从该分支拉 worktree"
agent --skip-worktree-setup --worktree "跳过 .cursor/worktrees.json"
```

`--plugin-dir 路径` 可重复，加载本地插件目录。

## 其它子命令

MCP 配置在项目或 `~/.cursor/mcp.json`：

```bash
agent mcp list
agent mcp list-tools 名字
agent mcp enable 名字
agent mcp disable 名字
agent mcp login 名字
```

插件市场：

```bash
agent plugin marketplace list
agent plugin marketplace add git地址
agent plugin marketplace update 名字或地址
agent plugin marketplace remove 名字或地址
```

| 命令 | 作用 |
| --- | --- |
| `agent generate-rule`、`agent rule` | 按提示生成一条 Cursor rule |
| `agent install-shell-integration` | 写进 `~/.zshrc` |
| `agent uninstall-shell-integration` | 从 `~/.zshrc` 去掉 |
| `agent bedrock status` | 看 Bedrock。未启用不必管 |
| `agent bedrock configure` | 配置 Bedrock |
| `agent worker start` | 本机作为个人 Cloud Agent 机器 |
| `agent worker --help` | 团队池和其它 worker 参数 |
| `agent acp` | 给自定义客户端的 ACP 服务，普通对话不用 |

`agent worker --pool` 需要 Enterprise 和服务账号。个人使用 `agent worker start` 即可。
