# dotfiles

使用 Nix Flakes 和 standalone Home Manager 管理的 Fedora 用户配置。配置面向
Fedora 44、`x86_64-linux`，可由同一仓库为任意普通用户生成独立的 Home Manager
generation，并为增加其他 Linux 主机保留了模块化结构。

## 管理边界

Home Manager 负责：

- Zsh、Oh My Zsh、Spaceship、Zsh 插件和模块化 shell 配置
- Tmux 及 sensible、yank、resurrect、continuum 插件
- Neovim、Python provider、LSP、核心 CLI，以及作为 submodule 的编辑器配置
- Bat、Fzf、Yazi、Btop、Jq、Grim、Slurp、Wofi、Pamixer、Brightnessctl、Wl-clipboard
- Kitty 配置（Kitty 程序本身仍使用 Fedora 包）
- Hyprland Lua 配置和带固定运行依赖的辅助脚本
- Fcitx5 的可移植配置、Rime 定制和 Catppuccin 主题
- Maple Mono Normal NF CN 字体和用户 fontconfig

Fedora 继续负责与系统或图形会话紧密集成的软件：Hyprland/Hyprctl、UWSM、
Fcitx5、PipeWire/Wpctl、Kitty、Hyprlock，以及 Zen、Mattermost、VS Code 等桌面
应用。NVM、Cargo 和其他语言工具链暂不迁移到 Nix。

本机专属文件不进入 Git 或 Nix store：

- `~/.config/hypr/machine.lua`
- `~/.config/hypr/hyprpaper.conf`
- `~/.config/uwsm/env` 和 `env-hyprland`
- `~/.zshrc.local`
- Fcitx5 缓存、构建产物和用户词库

## 仓库结构

- `flake.nix`：固定 Nixpkgs/Home Manager 稳定分支并导出可复用配置工厂
- `nix/hosts/fedora.nix`：接收用户名和 home 路径的 Fedora 主机入口
- `nix/modules/`：软件包、shell 和桌面配置模块
- `nix/files/`：由 Home Manager 组合进生成配置的 shell 片段
- `config/nvim/`：固定到独立 `nvim-config` 仓库提交的 Git submodule
- `config/`、`data/`：保持原生格式的应用配置与资源
- `home/`：首次 Home Manager 激活前仍在使用的旧软链接来源，兼作迁移回退
- `install.sh`：构建、预览、备份并激活 Home Manager generation

## 第一阶段：尚未安装 Nix

仓库改造可以先完成，但没有 Nix 时只能运行普通语法和应用配置检查。此时
不要删除 `home/` 下的旧文件；当前 `~/.zshrc`、`~/.zshenv` 和
`~/.tmux.conf` 仍链接到它们。

`flake.lock` 有意在安装 Nix 后由真实的 26.05 inputs 生成，不手写锁文件。

## 第二阶段：安装 Nix

Fedora 44 已在官方仓库提供 Nix，并包含适配 Fedora systemd/SELinux 的多用户
daemon 配置。使用发行版包安装：

```sh
sudo dnf install nix nix-daemon
sudo systemctl enable --now nix-daemon
```

Fedora 包会创建 `/nix`、构建用户和 `nix-daemon` systemd 服务，并默认支持
flakes。安装后验证：

```sh
nix --version
systemctl is-active nix-daemon
```

只有两个命令分别输出版本号和 `active` 后才进行下一阶段。参考 Fedora 44
Nix 变更说明：<https://fedoraproject.org/wiki/Changes/Nix_package_tool>。

不要在 Fedora 上改用上游 `nixos.org/nix/install --daemon` 脚本：只要内核
SELinux 接口处于启用状态，该脚本就会拒绝安装，即使当前没有加载 SELinux
策略。也不要为了安装 Nix 向内核参数添加 `selinux=0`。

## 第三阶段：锁定、构建和激活

首次 clone 必须同时初始化 submodule：

```sh
git clone --recurse-submodules <dotfiles-url> ~/.config/dotfiles
```

如果仓库已经 clone：

```sh
git submodule update --init --recursive
```

首次使用先生成锁文件：

```sh
cd ~/.config/dotfiles
nix --extra-experimental-features 'nix-command flakes' flake lock
```

先进行不会修改 home 的构建和迁移预览：

```sh
./install.sh --dry-run
```

确认输出后才正式激活：

```sh
./install.sh
```

安装器使用 `id -un` 和当前 `$HOME` 生成目标配置，因此每个用户都应以自己的
身份运行，不能使用 `sudo ./install.sh`。同一台机器上的其他用户可以读取或
clone 此仓库，然后分别执行上述 dry-run 和正式激活命令；各用户的 generation、
配置文件和备份彼此独立。

flake 仍保留 `sorasuka@fedora` 作为兼容的静态输出。安装器不会依赖该名称，
而是调用 `lib.mkFedoraHome` 为当前用户创建配置，所以增加用户时不需要复制或
修改 `nix/hosts/fedora.nix`。

安装器会先执行 `nix flake check` 并构建 activation package。构建成功后，才把
冲突目标移动到：

```text
${XDG_STATE_HOME:-~/.local/state}/dotfiles/backups/<时间戳>/
```

首次从旧安装器迁移时，Hyprland 的本机文件会被单独保存并复制回新的可写
`~/.config/hypr/`。如果 Home Manager 激活失败，安装器会恢复本轮备份，并把
失败期间创建的目标保留在备份目录的 `failed-activation/` 中。

以后日常应用配置可以继续使用：

```sh
./install.sh --dry-run
./install.sh
```

更新固定依赖时显式执行：

```sh
nix --extra-experimental-features 'nix-command flakes' flake update nixpkgs home-manager
./install.sh --dry-run
```

不要因为更新 inputs 而自动修改 `home.stateVersion = "26.05"`。

## 更新 Neovim submodule

Neovim 本体、Python provider、核心工具和已配置的 LSP 由 Nix 管理。
`lazy.nvim` 启动器也由 Nix 提供，其余插件继续由 `lazy.nvim` 按
`config/nvim/lazy-lock.json` 固定版本和保持原有懒加载语义。

在子仓库中修改并推送配置后，更新 dotfiles 固定的提交：

```sh
git -C config/nvim pull --ff-only origin master
git add config/nvim
git commit -m "chore: update Neovim submodule"
./install.sh --dry-run
./install.sh
```

## 回滚

Home Manager 激活成功后，可以查看和切换 generation：

```sh
home-manager generations
```

每个旧 generation 会显示对应的 `activate` 路径。运行所需 generation 的
`activate` 即可回滚。首次迁移前的非 Home Manager 文件则保存在上述
`dotfiles/backups/<时间戳>/` 目录中。
