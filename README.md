# Introduction
A simple shell script for setting up a basic Linux development environment. Tested on a Debian Jessie box.

Java development tools:
* Open JDK
* Maven

Ruby development tools:
* rbenv
* ruby-build
* bundler

Python development tools:
* pip
* virtualenv
* virtualenvwrapper

Utility tools:
* git
* ctags
* vim
* oh-my-zsh shell

# Install
`bash <(wget -qO- https://raw.githubusercontent.com/yuczhou/init/master/init.sh)
2>&1 | tee ~/init.log`
