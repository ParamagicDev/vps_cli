# frozen_string_literal: true

require 'rake'

require 'vps_cli/helpers/file_helper'

module VpsCli
  # Copies config from /vps_cli/config_files/dotfiles
  #   & vps_cli/config_files/miscfiles to your home dir
  class Copy
    extend FileHelper

    # Top level method for copying all files
    # Will use the configurations set by VpsCli.configuration
    #   unless passed a different config
    # @raise [RuntimeError]
    #   Will raise this error if you run this method as root or sudo
    def self.all(config = VpsCli.configuration)
      # raises an error if the script is run as root
      return unless root? == false

      # fills in options that are not explicitly filled in
      FileHelper.mkdirs(config.local_dir, config.backup_dir)

      # copies dotfiles
      dotfiles(config)

      # copies gnome_settings
      gnome_settings(config)

      # copies sshd_config
      sshd_config(config)

      puts "dotfiles copied to #{config.local_dir}"
      puts "backups created @ #{config.backup_dir}"
    end

    # Copy files from 'config_files/dotfiles' directory via the copy_all method
    # Defaults are provided in the VpsCli.create_options method
    # @see VpsCli::Configuration
    def self.dotfiles(config = VpsCli.configuration)
      Dir.each_child(config.dotfiles) do |file|
        config_file = File.join(config.dotfiles, file)
        local = File.join(config.local_dir, ".#{file}")
        backup = File.join(config.backup_dir, "#{file}.orig")

        files_and_dirs(config_file: config_file,
                       local_file: local,
                       backup_file: backup,
                       verbose: config.verbose,
                       interactive: config.interactive)
      end
    end

    # Checks that sshd_config is able to be copied
    # @param sshd_config [File] File containing your original sshd_config
    #   Defaults to /etc/ssh/sshd_config
    # @return [Boolean] Returns true if the sshd_config exists
    def self.sshd_copyable?(sshd_config = nil)
      sshd_config ||= '/etc/ssh/sshd_config'

      no_sshd_config = 'No sshd_config found. sshd_config not copied'

      return true if File.exist?(sshd_config)

      VpsCli.errors << Exception.new(no_sshd_config)
    end

    # Copies sshd_config to the VpsCli.configuration.local_sshd_config
    #   location
    #   Defaults to [/etc/ssh/sshd_config] if not set
    #   This is slightly different from other copy methods in this file
    #   It uses Rake.sh("sudo cp")
    #   Due to copying to /etc/ssh/sshd_config requiring root permissions
    def self.sshd_config(config = VpsCli.configuration)

      config.local_sshd_config ||= File.join('/etc', 'ssh', 'sshd_config')
      return unless sshd_copyable?(config.local_sshd_config)

      config.sshd_backup ||= File.join(config.backup_dir, 'sshd_config.orig')

      misc_sshd_path = File.join(config.misc_files, 'sshd_config')

      if File.exist?(config.local_sshd_config) && !File.exist?(config.sshd_backup)
        Rake.cp(config.local_sshd_config, config.sshd_backup)
      else
        puts "#{config.sshd_backup} already exists. no backup created"
      end

      return Rake.cp(misc_sshd_path, config.local_sshd_config) if config.testing

      # This method must be run this way due to it requiring root privileges
      unless FileHelper.overwrite?(config.local_sshd_config, config.interactive)
        return
      end

      return unless File.identical?(misc_sshd_path, config.local_sshd_config)

      Rake.sh("sudo cp #{misc_sshd_path} #{config.local_sshd_config}")
    end

    # Deciphers between files & directories
    # Also utilizes the settings from your configuration to properly
    #   copy things
    # @see VpsCli::FileHelper#copy_dirs
    # @see VpsCli::FileHelper#copy_files
    def self.files_and_dirs(opts = {})
      if File.directory?(opts[:config_file])
        FileHelper.copy_dirs(opts)
      else
        FileHelper.copy_files(opts)
      end
    end

    # Copies gnome terminal via dconf
    # @see https://wiki.gnome.org/Projects/dconf dconf wiki
    # @param config [VpsCli::Configuration] Where to save the current gnome terminal settings
    # @note This method will raise an error if dconf errors out
    #   The error will be saved to VpsCli.errors
    def self.gnome_settings(config = VpsCli.configuration)
      backup = "#{config.backup_dir}/gnome_terminal_settings.orig"

      # This is the ONLY spot for gnome terminal
      gnome_path = '/org/gnome/terminal/'
      gnome_file = File.join(config.misc_files, 'gnome_terminal_settings')

      raise RuntimeError if config.testing
      raise RuntimeError unless File.exists?(gnome_file)

      overwrite = proc { |file| FileHelper.overwrite?(file, config.interactive) }
      Rake.sh("dconf dump #{gnome_path} > #{backup}") if overwrite.call(backup)

      dconf_load = "dconf load #{gnome_path} < #{config.misc_files}/gnome_terminal_settings"
      Rake.sh(dconf_load) if overwrite.call(gnome_path)
    rescue RuntimeError => error
      puts 'something went wrong with gnome, continuing on' if config.verbose
      VpsCli.errors << error.exception("Unable to copy gnome settings")
    end

    def self.root?
      root = (Process.uid.zero? || Dir.home == '/root')
      root_msg = 'Do not run this as root or sudo. Run as a normal user'
      raise root_msg if root == true

      false
    end
  end
end
