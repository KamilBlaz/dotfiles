{ pkgs, ... }: {
  # Basic system configuration
  system.defaults.dock.autohide = true;
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;

  # Add system packages
  environment.systemPackages = with pkgs; [
    # Add your packages here
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  # Used for backwards compatibility
  system.stateVersion = 4;
} 