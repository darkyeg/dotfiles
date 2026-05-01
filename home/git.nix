{ config, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Youssef Khalil";
      user.email = "me@darky.dev";
      user.signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";

      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;

      gpg.format = "ssh";
      commit.gpgsign = true;
      tag.gpgsign = true;
    };
  };

  programs.gh.enable = true;
}
