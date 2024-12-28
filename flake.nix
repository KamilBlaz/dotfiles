{
  description = "Blaze nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs}:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
          pkgs.vim
          pkgs.git
          pkgs.zsh
          pkgs.oh-my-zsh
          pkgs.zsh-autosuggestions
          pkgs.zsh-syntax-highlighting
          pkgs.zsh-completions
          pkgs.tmux
          pkgs.neovim
          pkgs.fzf
          pkgs.fd
          pkgs.bat
          pkgs.direnv
          pkgs.atuin
          pkgs.go
          pkgs.tenv
          pkgs.aws-vault
          pkgs.jq
          pkgs.yq
          pkgs.kubectl
          pkgs.k9s
          pkgs.krew
          pkgs.kubectx
          pkgs.nmap
          pkgs.ncdu
          pkgs.zoxide
        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      security.pam.enableSudoTouchIdAuth = true;

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#blaze
    darwinConfigurations."blaze" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
