{
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  programs.gh.enable = true;
  # GitHub CLI writes this file during login and configuration changes.
  xdg.configFile."gh/config.yml".enable = false;
}
