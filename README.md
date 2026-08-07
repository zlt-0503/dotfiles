# dotfiles

个人 Linux 桌面配置，包含 Hyprland、Zsh、Tmux、Fcitx5 和 Kitty。

## 目录

- `config/hypr`：Hyprland 0.56+ Lua 配置和辅助脚本
- `config/zsh`：模块化 Zsh 配置
- `config/kitty`：Kitty 配置
- `config/fcitx5`：Fcitx5 的可移植配置（不包含缓存和用户词库）
- `data/fcitx5/themes`：Fcitx5 Classic UI 主题
- `home`：需要放在 home 目录中的 `.zshrc`、`.zshenv` 和 `.tmux.conf`

## 安装

先预览将发生的操作：

```sh
./install.sh --dry-run
```

确认后安装：

```sh
./install.sh
```

脚本可以重复运行。已有目标不会被删除，而会先移动到
`~/.local/state/dotfiles/backups/<时间戳>/`，然后创建绝对符号链接。

## 本机配置

Hyprland 的显示器、自启动程序和壁纸通常不可直接移植，因此不提交到 Git：

```sh
cp config/hypr/machine.lua.example config/hypr/machine.lua
cp config/hypr/hyprpaper.conf.example config/hypr/hyprpaper.conf
```

编辑这两个文件以匹配当前机器。缺少 `machine.lua` 时，Hyprland 会使用自动检测显示器的通用配置。

Zsh 的私有或临时设置放入 `~/.zshrc.local`；该文件不由本仓库管理。

## 主要依赖

- Hyprland 0.56+、UWSM、Kitty、Fcitx5、Tmux、Zsh
- Oh My Zsh、TPM，以及配置中列出的对应插件
- Hyprland 脚本使用 `jq`；截图快捷键使用 `grim` 和 `slurp`
- 当前字体配置使用 `Maple Mono Normal NF CN`

安装插件和应用仍由系统包管理器负责，本仓库只管理配置与链接。

## 推送到 GitHub

在 GitHub 创建一个空仓库后执行：

```sh
git remote add origin git@github.com:<用户名>/<仓库名>.git
git branch -M main
git push -u origin main
```

仓库中包含第三方 Catppuccin Fcitx5 主题，其许可证保留在主题目录的 `LICENSE` 中。
