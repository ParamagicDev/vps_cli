# frozen_string_literal: true

require 'vps_cli/configuration'
require 'vps_cli/access'
require 'vps_cli/helpers/access_helper'
require 'vps_cli/cli'
require 'vps_cli/copy'
require 'vps_cli/helpers/file_helper'
require 'vps_cli/install'
require 'vps_cli/packages'
require 'vps_cli/pull'
require 'vps_cli/setup'
require 'vps_cli/version'
require 'vps_cli/helpers/github_http'

# Used for setting up a ubuntu environment
module VpsCli
  # @!group Top Level Constants

  # Project's Root Directory
  ROOT = File.expand_path(File.expand_path('../', __dir__))

  # Projects config_files directory
  FILES_DIR = File.join(ROOT, 'config_files')

  # Projects Dotfiles directory
  DOTFILES_DIR = File.join(FILES_DIR, 'dotfiles')

  # Miscellaneous files like sshd_config
  MISC_FILES_DIR = File.join(FILES_DIR, 'misc_files')

  # Directory of backup files
  BACKUP_FILES_DIR = File.join(Dir.home, 'backup_files')

  # @!endgroup

  # all following methods will be module wide
  class << self
    # Used for loggings errors
    # same as self.errors && self.errors=(errors)
    # VpsCli.errors now accessible module wide
    attr_accessor :errors

    # Allows the user to be able to set global configurations
    # @example
    #   VpsCli.configure do |config|
    #     config.local_dir = Dir.home
    #     config.backup_dir = File.join(Dir.home, 'backup_files')
    #     config.verbose = true
    #   end
    # This will set the local dir to the value of $HOME
    #   The local dir is where files are copied to
    attr_writer :configuration

    # Base set of options, will set the defaults for the various options
    # Take a hash due to people being able to set their own directories
    # @param [Hash] Takes the hash to modify
    # @return [Hash] Returns the options hash with the various options
    # Possible options:
    #   :backup_dir
    #   :local_dir
    #   :dotfiles_dir
    #   :misc_files_dir
    #   :local_sshd_config
    #   :verbose
    #   :testing
    # def create_options(opts = {})
    #   opts[:backup_dir] ||= BACKUP_FILES_DIR
    #   opts[:local_dir] ||= Dir.home
    #   opts[:dotfiles_dir] ||= DOTFILES_DIR
    #   opts[:misc_files_dir] ||= MISC_FILES_DIR
    #   opts[:local_sshd_config] ||= '/etc/ssh/sshd_config'

    #   opts[:verbose] = false if opts[:verbose].nil?
    #   opts[:interactive] = true if opts[:interactive].nil?

    #   opts
    # end

    def full_install(options = {})
      VpsCli::Setup.full
      VpsCli::Install.full
      VpsCli::Access.provide_credentials(options)
      VpsCli::Copy.all(options)
    end
  end

  # Creates an empty array of errors to push to
  @errors ||= []
end
