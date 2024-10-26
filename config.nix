{
  packageOverrides = pkgs: with pkgs; {
    myPackages = pkgs.buildEnv {
      name = "joris-tools";
      paths = [
        zsh-completions
        neovim
        python3
        nodejs_22
        rustup
        cargo
        pure-prompt
        fd
        ripgrep
        fzf
        lazygit
        fluxcd
      ];
    };
  };
}
