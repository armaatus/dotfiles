{
  packageOverrides = pkgs: with pkgs; {
    myPackages = pkgs.buildEnv {
      name = "joris-tools";
      paths = [
        zsh-completions
        neovim
        python3
        nodejs_22
        cargo
        rustc
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
