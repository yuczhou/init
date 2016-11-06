#!/usr/bin/env bash

fancy_echo() {
  local fmt="$1"; shift
  printf "\n$fmt\n" "$@"
}

install_if_needed() {
  local package="$1"

  if [ $(dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    sudo aptitude install -y "$package";
  fi
}

append_to_zshrc() {
  local text="$1" zshrc
  local skip_new_line="${2:-0}"

  if [ -w "$HOME/.zshrc.local" ]; then
    zshrc="$HOME/.zshrc.local"
  else
    zshrc="$HOME/.zshrc"
  fi

  if ! grep -Fqs "$text" "$zshrc"; then
    if [ "$skip_new_line" -eq 1 ]; then
      printf "%s\n" "$text" >> "$zshrc"
    else
      printf "\n%s\n" "$text" >> "$zshrc"
    fi
  fi
}

find_latest_ruby() {
  rbenv install -l | grep -v - | tail -1 | sed -e 's/^ *//'
}

gem_install_or_update() {
  if gem list "$1" --installed > /dev/null; then
    gem update "$@"
  else
    gem install "$@"
    rbenv rehash
  fi
}

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT
set -e

if [[ ! -d "$HOME/.bin/" ]]; then
  mkdir "$HOME/.bin"
fi

if [ ! -f "$HOME/.zshrc" ]; then
  touch "$HOME/.zshrc"
fi

fancy_echo "Updating system packages ..."
  if command -v aptitude >/dev/null; then
    fancy_echo "Using aptitude ..."
  else
    fancy_echo "Installing aptitude ..."
    sudo apt-get install -y aptitude
  fi

sudo aptitude update

fancy_echo "Installing git, for source control management ..."
install_if_needed git

fancy_echo "Installing libraries for common gem dependencies ..."
sudo aptitude install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev

fancy_echo "Installing ctags, to index files for vim tab completion of methods, classes, variables ..."
install_if_needed exuberant-ctags

fancy_echo "Installing vim ..."
install_if_needed vim
sh <(curl https://j.mp/spf13-vim3 -L)

fancy_echo "Installing tmux, to save project state and switch between projects ..."
install_if_needed tmux

fancy_echo "Installing watch, to execute a program periodically and show the output ..."
install_if_needed watch

fancy_echo "Installing curl ..."
install_if_needed curl

fancy_echo "Installing zsh ..."
install_if_needed zsh

fancy_echo "Installing The Silver Searcher (better than ack or grep) to search the contents of files ..."
install_if_needed silversearcher-ag

fancy_echo "Installing default JDK ..."
install_if_needed default-jdk

fancy_echo "Installing maven ..."
install_if_needed mvn

fancy_echo "Installing node, to render the rails asset pipeline ..."
install_if_needed nodejs

fancy_echo "Installing pip ..."
install_if_needed python-pip

fancy_echo "Installing oh-my-zsh ..."
rm -rf "$HOME/.oh-my-zsh"
git clone git://github.com/robbyrussell/oh-my-zsh.git "$HOME/.oh-my-zsh"
cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc"

fancy_echo "Changing your shell to zsh ..."
chsh -s $(which zsh)

fancy_echo "Configuring Python ..."
sudo pip install --upgrade pip
pip install --user virtualenv
pip install --user virtualenvwrapper
append_to_zshrc 'export PATH="$HOME/.local/bin:$PATH"'
append_to_zshrc 'export WORKON_HOME="$HOME/.virtualenvs"'
append_to_zshrc 'source "$HOME/.local/bin/virtualenvwrapper.sh"'

fancy_echo "Configuring Ruby ..."
rm -rf "$HOME/.rbenv"
git clone https://github.com/rbenv/rbenv.git "$HOME/.rbenv"

append_to_zshrc 'export PATH="$HOME/.rbenv/bin:$PATH"'
append_to_zshrc 'eval "$(rbenv init - zsh)"' 1

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - zsh)"

if [[ ! -d "$HOME/.rbenv/plugins/ruby-build" ]]; then
  fancy_echo "Installing ruby-build, to install Rubies ..."
  git clone https://github.com/rbenv/ruby-build.git "$HOME/.rbenv/plugins/ruby-build"
fi

ruby_version="$(find_latest_ruby)"
if ! rbenv versions | grep -Fq "$ruby_version"; then
  rbenv install -s "$ruby_version"
  rbenv rehash
fi
  
rbenv global "$ruby_version"
rbenv shell "$ruby_version"
gem update --system

gem_install_or_update 'bundler'
