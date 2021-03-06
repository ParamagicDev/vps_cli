# frozen_string_literal: true

module VpsCli
  class Packages
    LANGUAGES = %w[python3 python3-pip python-dev
                   python3-dev python-pip python3-neovim
                   nodejs golang ruby ruby-dev php].freeze

    TOOLS = %w[curl tmux git vim zsh sqlite3 ctags rdoc libsqlite3-dev
               openssh-client openssh-server dconf-cli gnome-terminal
               postgresql pry rubygems fail2ban
               neovim asciinema docker mosh yarn
               silversearcher-ag virtualbox].freeze

    LIBS = %w[libssl-dev libcurl4-openssl-dev libxml2-dev
              re2c libbz2-dev libjpeg-turbo8-dev libpng-dev
              libzip-dev libtidy-dev libxslt-dev automake libtool autoconf
              flex bison libkrb5-dev libonig-dev].freeze

    GEMS = %w[colorls neovim rake pry
              rubocop gem-ctags rails yard
              thor bundler solargraph].freeze

    UBUNTU = LANGUAGES.dup.concat(TOOLS).concat(LIBS)
  end
end
