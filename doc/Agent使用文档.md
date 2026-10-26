# Vim 里使用 Agent

这份只讲 Vim 窗口。终端程序 `agent` 的登录、斜杠命令、脚本模式见 `Agent命令行.md`，或在 Vim 里执行 `:help agent-cli`。

在 Vim 里执行 `:help Agent` 可以打开同一份说明。插件是 `~/.vim/plugin/agent.vim`。改过插件后重新打开 Vim，已打开的 Agent 窗口要关掉再开一次，新命令才会作用到新进程。可执行文件默认为 `~/.local/bin/agent`，可在 vimrc 里用 `let g:agent_exe = '路径'` 指定。

Agent 窗口有两种状态：

| 状态 | 怎么认 | 按键给谁 |
| --- | --- | --- |
| Terminal-Job | 状态栏没有 `(Terminal)` | 全部交给 Agent，用来对话 |
| Terminal-Normal | 状态栏显示 `(Terminal)` | 交给 Vim，用来翻页、复制 |

刚打开时是 Terminal-Job，可以直接打字。从 Terminal-Job 进入 Terminal-Normal：按一次 `Ctrl-\`。回到 Terminal-Job：按 `i` 或 `a`。

`Esc` 不会退出这个窗口，它会送给 Agent。

## 打开方式

| 命令 | 效果 |
| --- | --- |
| `:Agent` | 当前标签右侧分屏，宽度大约三分之一 |
| 空格 `a` | 与 `:Agent` 相同。只在编辑区和 Terminal-Normal 里有效 |
| `:AgentTab` | 放到一个新建标签里，占满该标签 |
| `:AgentHide` | 在代码窗口隐藏 Agent，进程继续跑 |

第一次启动可以带参数，窗口已经存在时再写参数不会另开一个：

| 命令 | 效果 |
| --- | --- |
| `:Agent --continue` | 接着最近一次对话 |
| `:Agent ls` | 列出历史对话再选 |
| `:AgentTab --continue` | 同上，但是在新标签里打开 |

已经有 Agent 时，`:AgentTab` 会把现有窗口挪进标签，或直接切到已有的 Agent 标签，不会再启动一个。

## 分屏时来回切换

Agent 在右边，代码在左边。Agent 正在输出时不用等它结束。

| 在哪 | 按键 | 到哪 |
| --- | --- | --- |
| 代码窗口 | `Ctrl-w` 然后 `l`，或空格 `a` | Agent |
| Agent（正在工作时） | `Ctrl-w` 然后 `h` | 左边代码 |
| Agent（正在工作时） | `Ctrl-w` 然后 `p` | 打开 Agent 之前的那个窗口 |
| 只有这两个窗口 | `Ctrl-w` 按两次 | 左右对调 |

`Ctrl-w` 由 Vim 截下来，后面的字母不会打进 Agent。

回到代码窗口后是普通模式。Agent 改过的文件，在代码窗口执行 `:e` 重新读入。

注意自己 vimrc 里的这几个键，它们不是用来切窗口的：

- `H` 和 `L` 是行首、行尾。
- 空格 `q` 会关掉当前窗口。Agent 还在跑时，这会结束进程。
- 空格 `o` 只留当前窗口，另一侧会被关掉。

## 标签时来回切换

Agent 正在工作时，单独按 `gt` 会打给 Agent，切不了标签。

| 按键 | 结果 |
| --- | --- |
| `Ctrl-w` 然后 `gt` | 下一个标签 |
| `Ctrl-w` 然后 `gT` | 上一个标签 |
| `1` 然后 `Ctrl-w` `gt` | 第 1 个标签。数字换成几就去第几个 |

只有编辑和 Agent 两个标签时，在 Agent 里按一次 `Ctrl-w` `gt` 就回到编辑。Agent 继续在原来的标签里跑。

从编辑标签回去：普通模式下按 `gt` 或 `gT`，或执行 `:AgentTab`。

## 隐藏和恢复

| 操作 | 结果 |
| --- | --- |
| 代码窗口里 `:AgentHide` | 分屏或标签消失，Agent 继续在后台跑 |
| Agent 窗口里 `Ctrl-w`，再输入 `:hide` 回车 | 同上 |
| 编辑区 `:Agent` | 右侧再打开同一次对话 |
| 编辑区 `:AgentTab` | 新建标签打开同一次对话 |
| `:q`、空格 `q`、`Ctrl-w` 然后 `Ctrl-c` | 结束 Agent 进程，不是隐藏 |

Agent 如果已经是当前标签里最后一个窗口，`:hide` 不会把它关掉。

## 把代码发给 Agent

在代码窗口选中后按 `y`。切到 Agent（Terminal-Job）后按 `Ctrl-w` `"` 再按 `"`，贴进输入框。

从 Agent 的输出里复制：先按一次 `Ctrl-\` 进入 Terminal-Normal，用 `v` 选中再 `y`，回到代码窗口后 `p`。看完要继续对话，在 Agent 窗口按 `i`。

## 回看当前这次输出

长对话默认只画最近几轮。在 Agent 输入框输入下面这行并回车，更早的内容会重新画出来：

```text
/full-conversation
```

然后按一次 `Ctrl-\`，状态栏出现 `(Terminal)` 后翻页：

| 按键 | 作用 |
| --- | --- |
| `Ctrl-b` | 上一页 |
| `Ctrl-f` | 下一页 |
| `Ctrl-u` / `Ctrl-d` | 半页 |
| `gg` | 到保留内容的最上面 |
| `G` | 回到最下面 |

看完按 `i`，回到 Agent 当前这一屏。Vim 默认保留滚出顶部的 10000 行，再早的会被丢掉。

输入框里的向上方向键只翻出你以前输入过的问题，不含 Agent 的回答。

`Ctrl-l` 会清掉屏幕和回滚内容。这次对话还在，但刚才能翻的记录没了。

Agent 是整屏重画。正在生成时，回滚区里有时会叠上重复画面。等这轮输出结束再翻，会清楚一些。

## 以前的会话

| 在哪输入 | 命令 | 作用 |
| --- | --- | --- |
| Agent 输入框 | `/resume` | 从列表里选一次旧对话，载入当前窗口 |
| 还没开 Agent | `:Agent --continue` | 打开最近一次 |
| 还没开 Agent | `:Agent ls` | 先列出再选 |
| 还没开 Agent | `:AgentTab --continue` | 在新标签里打开最近一次 |

`/rewind` 会把对话和文件退回到以前某一轮，只是查看时不要用。

## 光标和鼠标

Agent 窗口里的鼠标是单独打开的，点底部输入框会把点击交给 Agent。回到代码窗口后，鼠标恢复为 vimrc 里原来的关闭状态。

这个窗口看起来像插入模式，是因为按键整段交给 Agent。光标应在底部输入框。若仍停在左上角：按一次 `Ctrl-\`，再按 `G`，再按 `i`。

## 不要按错的键

| 按键 | 结果 |
| --- | --- |
| Terminal-Job 里的 `Ctrl-c` | 发给 Agent，由它处理中断 |
| `Ctrl-w` 然后 `Ctrl-c` | Vim 强制结束 Agent |
| `Ctrl-w` 然后 `.` | 把一个 `Ctrl-w` 发给 Agent。平时切窗口不用这条 |
| `/quit` | Agent 自己退出 |
