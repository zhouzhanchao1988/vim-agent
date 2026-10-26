# vim-agent

在 Vim 里打开 Cursor Agent 终端。

## 安装

把本仓库放到 Vim 的 runtimepath 下，例如：

```text
~/.vim/pack/plugins/start/vim-agent
```

或用插件管理器安装本仓库。Vim 启动后会加载 `plugin/agent.vim`。

可执行文件默认为 `~/.local/bin/agent`，也可在 vimrc 里指定：

```vim
let g:agent_exe = '/path/to/agent'
```

## 说明文档

原说明已全部放在 `doc/`，没有删减：

| 文件 | 内容 |
| --- | --- |
| `doc/Agent使用文档.md` | Vim 窗口用法 |
| `doc/Agent命令行.md` | 终端 `agent` 命令行 |
| `doc/agent.txt` | Vim help（`:help Agent`、`:help agent-cli`） |

把 `doc/` 链到 `~/.vim/doc/` 后执行 `:helptags ~/.vim/doc`，即可用 `:help Agent`。
