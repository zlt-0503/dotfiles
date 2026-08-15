{
  config,
  lib,
  pkgs,
  ...
}:
let
  tmuxSource = builtins.readFile ../../home/.tmux.conf;
  tmuxManagedLinePrefixes = [
    "# List of plugins"
    "set -g @plugin "
    "# Initialize TMUX plugin manager"
    "run '~/.tmux/plugins/tpm/tpm'"
  ];
  isHomeManagerPluginLine = line:
    lib.any (prefix: lib.hasPrefix prefix line) tmuxManagedLinePrefixes;
  tmuxConfig = lib.concatStringsSep "\n" (
    lib.filter (line: !isHomeManagerPluginLine line) (lib.splitString "\n" tmuxSource)
  );
in
{
  xdg.configFile = {
    "zsh/common.zsh".source = ../../config/zsh/common.zsh;
    "zsh/user-home-manager.zsh".source = ../files/zsh-user.zsh;
    "zsh/aliases.zsh".source = ../../config/zsh/aliases.zsh;
  };

  programs.zsh = {
    enable = true;

    # Keep ~/.zshrc and ~/.zshenv as the public entrypoints. Home Manager 26.05
    # otherwise defaults to placing all Zsh dotfiles below XDG_CONFIG_HOME.
    dotDir = config.home.homeDirectory;
    enableCompletion = false;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "fzf"
        "z"
        "sudo"
        "extract"
        "colored-man-pages"
        "command-not-found"
        "docker"
        "docker-compose"
        "npm"
        "node"
        "python"
        "pip"
        "kubectl"
        "history"
        "common-aliases"
      ];
    };

    envExtra = ''
      [[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
    '';

    initContent = lib.mkMerge [
      (lib.mkOrder 500 ''
        source "$HOME/.config/zsh/common.zsh"
      '')
      (lib.mkOrder 900 ''
        source ${pkgs.spaceship-prompt}/share/zsh/themes/spaceship.zsh-theme
      '')
      (lib.mkOrder 1000 ''
        source "$HOME/.config/zsh/user-home-manager.zsh"
      '')
      (lib.mkOrder 1100 ''
        # Load personal aliases after Oh My Zsh and common-aliases.
        source "$HOME/.config/zsh/aliases.zsh"
      '')
    ];
  };

  programs.tmux = {
    enable = true;
    # Preserve the current /tmp socket behavior so a tmux server remains
    # reachable across graphical-session restarts.
    secureSocket = false;
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    terminal = "tmux-256color";
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      resurrect
      continuum
    ];
    extraConfig = tmuxConfig;
  };
}
