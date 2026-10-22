{
  # Bootstrap configures the invoking account; personal identity is selected explicitly.
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
}
