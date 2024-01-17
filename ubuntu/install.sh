#!/bin/bash
# {{{ Usefull URLs

# Useful documentation.
#   https://miktex.org/howto/install-miktex-unx
#   https://linuxize.com/post/how-to-install-ruby-on-debian-9/

# -------------------------------------------------------------------------- }}}
# {{{ Main function

main() {
  loadConfig
  updateOS
  installDefaultPackages

  installMikTeX
  installTexLive
  installXWindows
  installRbEnv
  installRubyBuild

  updateBashRc

  installRuby
  installRubyGems
  installRust
  installRustPrograms
  installPipPackages
  installJavaJre
  installMutt

  cloneMyRepos

  # Setup symlinks.
  deleteSymLinks
  createSymLinks
}

# -------------------------------------------------------------------------- }}}
# {{{ Load configuraiton options.

loadConfig() {
  missingFile=0

  files=(config repos )
  for f in "${files[@]}"
  do
    source "$f"
  done

  [[ $missingFile == 1 ]] && say 'Missing file(s) program exiting.' && exit


# -------------------------------------------------------------------------- }}}
# {{{ Update OS

updateOS() {
  if [[ $osUpdateFlag == 1 ]]; then
    sudo apt-get -y update
    sudo apt-get -y upgrade
    sudo apt-get -y autoremove
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install my default packages.

installDefaultPackages() {
  if [[ $osUpdateFlag == 1 ]]; then
    sudo apt-get install -y \
                batcat \
                curl \
                dirmngr \
                exa \
                fdfind \
                fzf \
                gcc \
                git \
                golang \
                make \
                neovim \
                npm \
                python3-venv \
                ripgrep
  fi
}


# -------------------------------------------------------------------------- }}}
# {{{ MiKTeX

installMikTeX() {
  if [[ $miktexFlag == 1 ]]; then

    # Register GPG key for Ubuntu and Linux Mint.
    sudo apt-key adv \
         --keyserver hkp://keyserver.ubuntu.com:80 \
         --recv-keys $miktexGpgKey

    # Installation source: Ubuntu 18.04, Linux Mint 19.
    echo "deb http://miktex.org/download/${miktexSource}" \
      | sudo tee /etc/apt/sources.list.d/miktex.list

    # Update database
    sudo apt-get update

    # MiKTeX
    sudo apt-get -y install \
                    miktex \
                    latexmk

    # Finish MikTeX shared installation setup.
    sudo miktexsetup --shared=yes finish
    sudo initexmf --admin --set-config-value [MPM]AutoInstall=1

    # The MiXTeX team told me to update the package database twice.  See:
    # https://github.com/MiKTeX/miktex/issues/724
    sudo mpm --admin --update
    mpm --update
    sudo mpm --admin --update
    mpm --update

  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ TexLive

installTexLive() {
  if [[ $texliveFlag == 1 ]]; then

    # TexLive compnents
    sudo apt-get -y install \
                    texlive \
                    texlive-latex-extra \
                    texlive-publishers \
                    texlive-science \
                    texlive-pstricks \
                    texlive-pictures \
                    texlive-metapost \
                    texlive-music \
                    latexmk

    # Create ls-R databases
    sudo mktexlsr

    # Init suer tree.
    tlmgr init-usertree

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
  [[ $xWindowsFlag == 1 ]] \
    && sudo sudo apt-get install -y vim-gtk xsel \
    && echo "X Windows support installed."
}

# -------------------------------------------------------------------------- }}}
# {{{ Install rbenv

installRbEnv() {
  if [[ $rbenvFlag == 1 ]]; then

    # Install rbenv dependencies.
    sudo apt-get -y install \
                    autoconf \
                    bison \
                    build-essential \
                    curl \
                    git \
                    libgdbm-dev \
                    libncurses5-dev \
                    libffi-dev \
                    libreadline-dev \
                    libreadline-dev \
                    libssl-dev \
                    libyaml-dev \
                    ruby-bundler \
                    zlib1g-dev

    git clone https://github.com/rbenv/rbenv.git $HOME/.rbenv

    echo "RbEnv installed."

  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install Ruby Build

installRubyBuild() {
  if [[ $rbenvFlag == 1 ]]; then

    git clone https://github.com/rbenv/ruby-build.git \
        $HOME/.rbenv/plugins/ruby-build

    echo "ruby-build installed."

  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Update .bashrc

updateBashRc() {
  if [[ $rbenvFlag == 1 ]]; then

    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> $HOME/.bashrc
    echo 'eval "$(rbenv init -)"' >> $HOME/.bashrc
    echo ".bashrc updated."

    # Update path, rbenv, and shell
    export PATH=$HOME/.rbenv/bin:$PATH
    eval "$(rbenv init -)"
    source $HOME/.bashrc
    echo "Path and rbenv loaded with new shell."

  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ InstgallBashGitPrompt

installBashGitPrompt() {
  if [[ $gitBashPromptFlag == 1 ]]; then
    say 'Instgall bash-git-prompt.'
    rm -rf ~/.bash-git-prompt
    src=https://github.com/magicmonty/bash-git-prompt
    dst=~/.bash-git-prompt
    git clone "$src" "$dst"
  fi
}

# {{{ Install Ruby

installRuby() {
  if [[ $rbenvFlag == 1 ]]; then

    rbenv init
    rbenv install $rubyVersion
    rbenv global $rubyVersion

    echo "Ruby installed."
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install Ruby Gems

installRubyGems() {
  if [[ $rbenvFlag == 1 ]]; then

    # Install Ruby Gems
    gem install \
        bundler \
        rake \
        rspec

    echo "Ruby Gems installed."
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install Rust

installRust() {
  if [[ $rustFlag == 1 ]]; then

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

    cargo install exa

  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install Mutt

installMutt() {
  if [[ $muttFlag == 1 ]]; then

    sudo apt-get install -y \
         neomutt \
         curl \
         isync \
         msmtp \
         pass

    git clone https://github.com/LukeSmithxyz/mutt-wizard

    cd mutt-wizard

    sudo make install

    echo "neomutt and mutt-wizzard are installed."
    echo "You must run the mutt-wizzard manually."

  fi
}


# -------------------------------------------------------------------------- }}}
# {{{ Install JavaJre

installJavaJre() {
  if [[ $javaJreFlag == 1 ]]; then
    sudo apt-get install -y default-jdk
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install pip packages.

installPipPackages() {
  if [[ $pipPackagesFlag == 1 ]]; then
    say 'Installing pip packages.'
    pip install "${pip_packages[@]}"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneMyRepos

cloneMyRepos() {
  if [[ $myReposFlag == 1 ]]; then
    say 'Cloning my repositories.'
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
    say 'Creating symbolic links.'
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
# {{{ Kick start this script.

main "$@"

# -------------------------------------------------------------------------- }}}