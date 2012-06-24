require 'thor'
require 'dotify'
require 'fileutils'

Dotify::Config.load_config!

module Dotify
  class CLI < Thor
    include Thor::Actions
    default_task :help

    map "-l" => "link"
    map "-u" => "unlink"
    map "-b" => "backup"
    map "-r" => "restore"

    def self.source_root
      Config.home
    end

    desc :setup, "Setup your system for Dotify to manage your dotfiles"
    def setup
      empty_directory Config.path unless Dir.exists?(Config.path)
    end

    desc :link, "Link up all of your dotfiles"
    method_option :all, :default => false, :type => :boolean, :aliases => '-a', :desc => "Link dotfiles without confirmation"
    def link
      Files.dots do |file, dot|
        if File.template? file
          template file, dotfile_location(no_extension(dot))
        else
          if options.all?
            replace_link dotfile_location(file), file
          else
            create_link dotfile_location(file), file
          end
        end
      end
    end

    desc :unlink, "Unlink all of your dotfiles"
    method_option :all, :default => false, :type => :boolean, :aliases => '-a', :desc => 'Remove all installed dotfiles without confirmation'
    def unlink
      Files.installed do |file, dot|
        if options.all? || yes?("Are you sure you want to remove ~/#{dot}? [Yn]", :blue)
          remove_file dotfile_location(file), :verbose => true
        end
      end
    end

    no_tasks do

      def dotfile_location(file)
        "#{home}/#{Files.file_name(file)}"
      end

      def no_extension(file)
        file = file.split('.')
        file.pop
        file.join('.')
      end

      def home
        Thor::Util.user_home
      end

      def replace_link(dotfile, file)
        remove_file dotfile
        create_link dotfile, file
      end

    end

  end
end
