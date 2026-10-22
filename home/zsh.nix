{ config, pkgs, ... }:
{
  home.file.".local/bin/tmux-sessionizer" = {
    source = ./scripts/tmux-sessionizer;
    executable = true;
  };
  home.sessionPath = [ "$HOME/.local/bin" ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      findNoDups = true;
      saveNoDups = true;
      share = true;
      extended = true;
    };

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };

    shellAliases = {
      vim = "nvim";
      v = "nvim";
      ls = "eza -l --icons --no-permissions --no-user --git";
      la = "eza -la --icons --no-permissions --no-user --git";
      cd = "z";
      gspush = "git stash push";
      gspop = "git stash pop";
      gco = "git checkout";
      gbpurge = ''git branch --merged | grep -Ev "(\*|master|main|develop|staging)" | xargs -n 1 git branch -d'';
      myip = "curl http://ipecho.net/plain && echo";
    };

    envExtra = ''
      if [ -z "''${DOTFILES:-}" ] && [ -r "''${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/repository" ]; then
        IFS= read -r DOTFILES < "''${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/repository"
      fi
      export DOTFILES="''${DOTFILES:-$HOME/dotfiles}"
      export GIT_EDITOR=nvim
      export PATH="$HOME/.local/bin:$PATH"

      # TODO: silences "zoxide doctor" warning that fires when other tools
      # (fnm, fzf-tab, etc.) initialise after zoxide. The proper fix is to
      # move `eval "$(zoxide init zsh)"` to the very end of the rc chain
      # using lib.mkAfter; revisit once we audit init order.
      export _ZO_DOCTOR=0
    '';

    initContent = ''
      eval "$(fnm env --use-on-cd --shell zsh)"

      bindkey -s ^f "tmux-sessionizer\n"

      # machine-local env (not in git): API keys, work creds, etc.
      if [ -d "$HOME/.config/personal" ]; then
        [ -f "$HOME/.config/personal/env" ] && source "$HOME/.config/personal/env"
        for f in "$HOME/.config/personal"/*; do
          [ -f "$f" ] && source "$f"
        done
      fi

      source ${./zsh/functions.zsh}
    '';
  };

  programs.zsh.plugins = [
    {
      name = "fzf-tab";
      src = pkgs.zsh-fzf-tab;
      file = "share/fzf-tab/fzf-tab.plugin.zsh";
    }
    {
      name = "zsh-history-substring-search";
      src = pkgs.zsh-history-substring-search;
      file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
    }
    {
      name = "zsh-completions";
      src = pkgs.zsh-completions;
      file = "share/zsh-completions/zsh-completions.plugin.zsh";
    }
  ];
}
