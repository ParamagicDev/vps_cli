#!/usr/bin/env ruby

require 'vps_cli'

VpsCli.configure do |config|
  # Where items will be copied to
  # For example, the local dir is where you would your dotfiles
  # saved to
  config.local_dir = Dir.home
  config.backup_dir = File.join(Dir.home, 'backup_files')
  config.local_sshd_config = File.join('/etc', 'ssh', 'sshd_config')

  # You must set these values yourself

  # Location of your config files
  # config.config_files = File.join(Dir.home, 'config_files')
  # This is just used for easier git pulling and git pushing

  config.config_files = File.join(Dir.home, 'vps_setup')

  # Location of your dotfiles
  # config.dotfiles = File.join(Dir.home, 'vps_setup', 'dotfiles')
  config.dotfiles = File.join(config.config_files, 'dotfiles')

  # Location of your dotfiles
  # config.dotfiles = File.join(Dir.home, 'config_files', 'dotfiles')
  config.misc_files = File.join(config.config_files, 'misc_files')

  # credentials.yaml file, wherever its located, for me I have it in the home dir
  config.credentials = File.join(Dir.home, '.credentials.yaml')

  # location of your .netrc file, usually ~/.netrc
  config.netrc = File.join(Dir.home, '.netrc')

  config.verbose = false

  # Change to false if you dont want to be prompted
  # about file creations / overwrites
  config.interactive = true

  # this is merely for testing purposes, dont worry about this
  config.testing = false
end

