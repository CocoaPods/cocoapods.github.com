module Pod
  module Doc
    module Generators

      # Provides support for describing executable commands and options.
      #
      class Commands < Base

        def initialize(*args)
          $:.unshift((DOC_GEM_ROOT + 'core/lib').to_s)
          $:.unshift((DOC_GEM_ROOT + 'cocoapods/lib').to_s)
          require 'cocoapods'
          super
        end

        def name
          'Commands'
        end

        def claide_command
          Pod::Command
        end

        def generate_code_object
          namespace = CodeObjects::NameSpace.new
          namespace.name = name
          namespace.html_description = description(claide_command)
          namespace.groups = claide_commands
          namespace
        end

        private

        def description(claide_command)
          instance = claide_command.parse([])
          "<pre>#{instance.formatted_usage_description}</pre>"
        end

        def claide_commands
          claide_command.subcommands.map do |claide_command|
            group = CodeObjects::Group.new
            group.name = claide_command.command
            group.html_description = description(claide_command)
            group.meths = claide_command.subcommands.map do |claide_subcommands|
              subcommand = create_subcommand(claide_subcommands)
              subcommand.group = group
              subcommand
            end
            group
          end
        end

        def create_subcommand(claide_subcommand)
          subcommand = CodeObjects::Entry.new
          subcommand.name = claide_subcommand.command
          subcommand.html_description = description(claide_subcommand)
          subcommand.examples = []
          subcommand
        end
      end

    end
  end
end
