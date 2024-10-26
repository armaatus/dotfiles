{
  packageOverrides = pkgs: with pkgs; {
    myPackages = pkgs.buildEnv {
      name = "joris-tools";
      paths = [
        zsh-completions
        neovim
        cargo
        nodejs_22
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
