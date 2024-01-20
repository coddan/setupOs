#!/bin/bash
# {{{ Usefull URLs

# Useful documentation.
#   https://miktex.org/howto/install-miktex-unx
#   https://linuxize.com/post/how-to-install-ruby-on-debian-9/

# -------------------------------------------------------------------------- }}}
# {{{ Main function

main() {
  # Save current working directory.
  cwd=$(pwd)
  loadConfig
  updateOS
  installDefaultPackages
  installXWindows
  installRust
  installRustPrograms
  installPipPackages
  installJavaJre
  cloneMyRepos

  # Setup symlinks.
  deleteSymLinks
  createSymLinks

  [[ -f $HOME/.bashrc ]] && source "$HOME/.bashrc"
}

# -------------------------------------------------------------------------- }}}
# {{{ Load configuraiton options.

loadConfig() {
  missingFile=0

  files=(config ../repos packages)
  for f in "${files[@]}"
  do
    source "$f"
  done

  [[ $missingFile == 1 ]] && echo 'Missing file(s) program exiting.' && exit

}
# -------------------------------------------------------------------------- }}}
# {{{ Update OS

updateOS() {
  if [[ $osUpdateFlag == 1 ]]; then
    echo 'Updating OS.'
    sudo apt-get -y update
    sudo apt-get -y upgrade
    sudo apt-get -y autoremove
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install my default packages.

installDefaultPackages() {
  if [[ $installDefaultPackages == 1 ]]; then
    echo 'Installing default packages.'
    sudo apt-get install -y "${Default_Packages[@]}"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ xWindows Suppport
#
# Note: Use PowerShell with Administrator rights.  I use VcXsrv to support
# X-windows clients when needed.  I use choco to install packages on Windoz.
# The powershell command is listed for reference only.
# choco install -y vcxsrv
#
# X Windoz support.

installXWindows() {
  [[ $xWindowsFlag == 1 ]]
    echo 'Installing xWindows.'
    sudo sudo apt-get install -y "${XWindows_Packages[@]}"
    echo "X Windows support installed."
}

# -------------------------------------------------------------------------- }}}
# {{{ InstgallBashGitPrompt

installBashGitPrompt() {
  if [[ $gitBashPromptFlag == 1 ]]; then
    echo 'Instgall bash-git-prompt.'
    rm -rf ~/.bash-git-prompt
    src=https://github.com/magicmonty/bash-git-prompt
    dst=~/.bash-git-prompt
    git clone "$src" "$dst"
  fi
}



# -------------------------------------------------------------------------- }}}
# {{{ Install Rust

installRust() {
  if [[ $rustFlag == 1 ]]; then
    echo 'Installing rust.'
    echo "Install rust from a subshell."
    (
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    )

  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install RustPrograms

installRustPrograms() {
  if [[ $rustProgramsFlag == 1 ]]; then
    echo 'Installing rust programs.'
    cargo install exa

  fi
}


# -------------------------------------------------------------------------- }}}
# {{{ Install JavaJre

installJavaJre() {
  if [[ $javaJreFlag == 1 ]]; then
    echo 'Installing java jre.'
    sudo apt-get install -y "${JavaJre_Packages[@]}"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install pip packages.

installPipPackages() {
  if [[ $pipPackagesFlag == 1 ]]; then
    echo 'Installing pip packages.'
    pip install "${pip_packages[@]}"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneMyRepos

cloneMyRepos() {
  if [[ $myReposFlag == 1 ]]; then
    echo 'Cloning my repositories.'
    for r in "${repos[@]}"
    do
      src=https://github.com/coddan/$r.git
      dst=$cloneRoot/$r
      git clone "$src" "$dst"
      echo ""
    done
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ deleteSymLinks

deleteSymLinks() {
  if [[ $symlinksFlag == 1 ]]; then
    echo "Deleting symbolic links."

    # Symlinks at .config
    rm -rfv ~/.config/nvim

    # Symlinks at $HOME
    rm -rfv ~/.bashrc
    rm -rfv ~/.gitconfig
    rm -rfv ~/.gitignore_global
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ createSymLinks

createSymLinks() {
  if [[ $symlinksFlag == 1 ]]; then
    echo 'Creating symbolic links.'
    mkdir -p ~/.config

    # Symlinks at .config
    ln -fsv ~/git/nvim                     ~/.config/nvim

    # Symlinks at $HOME
    ln -fsv ~/git/dotfiles/bash/bashrc           ~/.bashrc
    ln -fsv ~/git/dotfiles/git/gitconfig         ~/.gitconfig
    ln -fsv ~/git/dotfiles/git/gitignore_global  ~/.gitignore_global
 fi
}

# -------------------------------------------------------------------------- }}}
# {{{ The stage is set ... start the show!!!

main "$@"

# -------------------------------------------------------------------------- }}}
