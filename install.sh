#!/bin/bash
# {{{ Notes

# Disable variable referenced but not assigned.
#shellcheck disable=SC2154

# Disable cant follow non-constant source.
#shellcheck disable=SC1090

# Disable not following file.  file does not exist.
#shellcheck disable=SC1091

# -- ----------------------------------------------------------------------- }}}
# {{{ main

main() {
  # Save current working directory.
  cwd=$(pwd)

  # Source configuration files and clean when necessary.
  sourceFiles

  # Update operating system and keys.
  updateOSKeys
  updateOS

  # Install packages.
  installPacmanPackages
  installYayPackages
  installPipPackages
  installLuarocksPackages
  installTexPackages

  # Setup symlinks.
  deleteSymLinks
  createSymLinks

  # Clone different repositories needed for personalization.
  cloneBashGitPrompt
  cloneMyRepos
  

  # Build applications from source code.
  buildNeovim
  addProgramsNeoVimInterfacesWith

  # Install editors and terminal multiplexers.
  installLunarVim
  loadNeovimPlugins

  # Install desktop applications.
  installOtherApps

}

# -------------------------------------------------------------------------- }}}
# {{{ Tell them what is about to happen.

say() {
  echo '********************'
  echo "${1}"
}

# -------------------------------------------------------------------------- }}}
# {{{ Source all configuration files

sourceFiles() {
  missingFile=0

  files=(config repos packages)
  for f in "${files[@]}"
  do
    source "$f"
  done

  [[ $missingFile == 1 ]] && say 'Missing file(s) program exiting.' && exit

}

# -------------------------------------------------------------------------- }}}
# {{{ Update OS Keys

updateOSKeys() {
  if [[ $osUpdateKeysFlag == 1 ]]; then
    say 'Update keys'
    sudo pacman-key --init
    sudo pacman-key --populate
    sudo pacman-key --refresh-keys
    sudo pacman -Sy archlinux-keyring --noconfirm
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Update OS

updateOS() {
  [[ $osUpdateFlag == 1 ]] && sayAndDo 'sudo pacman -Syyu --noconfirm'
}


# -------------------------------------------------------------------------- }}}
# {{{ Install pacman packages.

installPacmanPackages() {
  if [[ $pacmanPackagesFlag == 1 ]]; then
    say 'Installing pacman packages.'
    sudo pacman -Syyu --noconfirm "${pacman_packages[@]}"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install other applications.

installOtherApps() {
  if [[ $otherAppsFlag == 1 ]]; then
    say 'Installing other applications.'
    sudo yay -Syyu --noconfirm "${other_packages[@]}"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install yay packages.

installYayPackages() {
  if [[ $yayPackagesFlag == 1 ]]; then
    say 'Installing yay packages.'

    git clone https://aur.archlinux.org/yay.git
    cd yay || exit
    makepkg -si
    cd ..

    yay -Syu --noconfirm "${yay_packages[@]}"
    libtool --finish /usr/lib/libfakeroot
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
# {{{ Install luarocks packages.

installLuarocksPackages() {
  if [[ $luarocksPackagesFlag == 1 ]]; then
    say 'Installing luarocks packages.'
    pip install "${luarocks_packages[@]}"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install tex packages.

installTexPackages() {
  if [[ $texPackagesFlag == 1 ]]; then
    say 'Installing tex packages.'
    yay -S --noconfirm "${tex_packages[@]}"
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
# {{{ cloneBashGitPrompt

cloneBashGitPrompt() {
  if [[ $gitBashPromptFlag == 1 ]]; then
    say 'Cloning bash-git-prompt.'
    rm -rf ~/.bash-git-prompt
    src=https://github.com/magicmonty/bash-git-prompt
    dst=~/.bash-git-prompt
    git clone "$src" "$dst"
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
    #rm -rfv ~/.bash_logout
    #rm -rfv ~/.bash_profile
    #rm -rfv ~/.bashrc
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ createSymLinks

createSymLinks() {
  if [[ $symlinksFlag == 1 ]]; then
    say 'Creating symbolic links.'
    mkdir -p ~/.config

    # Symlinks at .config
    ln -fsv ~/git/nvim.coddan                     ~/.config/nvim

    # Symlinks at $HOME
    #ln -fsv ~/git/dotfiles/bash/bash_logout      ~/.bash_logout
    #ln -fsv ~/git/dotfiles/bash/bash_profile     ~/.bash_profile
    #ln -fsv ~/git/dotfiles/bash/bashrc           ~/.bashrc

 fi
}


# -------------------------------------------------------------------------- }}}
# {{{ Build Neovim

buildNeovim() {
  if [[ $neovimBuildFlag == 1 ]]; then
    say 'Acquire neovim dependencies.'
    sudo pacman -Syu --noconfirm \
      base-devel \
      cmake \
      ninja \
      tree-sitter \
      unzip

    say 'Building neovim.'
    src=https://github.com/neovim/neovim
    dst=$cloneRoot/neovim

    if [[ -d ${dst} ]]; then
      echo 'Update neovim sources.'
      cd "${dst}" || exit
      git pull
    else
      echo 'Clone neovim sources.'
      git clone "$src" "$dst"
    fi

    echo 'Build neovim.'
    cd "${dst}" || exit
    sudo make CMANE_BUILD=Release install

    echo
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Add programs Neovim interfaces with.

addProgramsNeoVimInterfacesWith() {
  if [[ $neovimBuildFlag == 1 ]]; then
    say 'Add programs Neovim interfaces with.'
    gem install neovim
    sudo npm install -g neovim
    yarn global add neovim
    yay -S --noconfirm python-pip
    python3 -m pip install --user --upgrade pynvim
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install LunarVim

installLunarVim() {
  if [[ $lunarVimFlag == 1 ]]; then
    say 'Install LunarVim.'
    local release='release-1.2/neovim-0.8'
    local cmdUrl='https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh'
    LV_BRANCH=$release bash <(curl -s $cmdUrl)
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ loadNeovimluginsconf

loadNeovimPlugins() {
  if [[ $neovimPluginsFlag == 1 ]]; then
    say 'Loading neovim plugins.'
    nvim
  fi
}


# -------------------------------------------------------------------------- }}}
# {{{ Echo something with a separator line.

say() {
  echo '**********************'
  echo "$@"
}

# -------------------------------------------------------------------------- }}}
# {{{ Echo a command and then execute it.

sayAndDo() {
  say "$@"
  $@
  echo
}

# -------------------------------------------------------------------------- }}}
# {{{ The stage is set ... start the show!!!

main "$@"

# -------------------------------------------------------------------------- }}}