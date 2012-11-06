require 'yard'
require 'redcarpet'
require 'pygments'

module Pod
  module Doc
    class Base
      TEMPLATE = File.expand_path('../template.erb', __FILE__)

      attr_reader :source_file

      def initialize(source_file)
        @source_file = source_file
      end

      def sections
        %w{ Podfile Specification Commands }
      end

      def name
        self.class.name.split('::').last
      end

      def render(output_file)
        require 'erb'
        template = ERB.new(File.read(ROOT + 'doc/template.erb'))
        File.open(output_file, 'w') { |f| f.puts(template.result(binding)) }
      end

      # Helpers

      def markdown(input)
        @markdown ||= Redcarpet::Markdown.new(Class.new(Redcarpet::Render::HTML) do
          def block_code(code, lang)
            lang ||= 'ruby'
            Pod::Doc::DSL.syntax_highlight(code, lang)
          end
        end)
        @markdown.render(input)
      end

      def syntax_highlight(code)
        self.class.syntax_highlight(code)
      end

      def self.syntax_highlight(code, lang = 'ruby')
        Pygments.highlight(code, :lexer => lang, :options => { :encoding => 'utf-8' })
      end
    end

    class DSL < Base

      #------------------------------------------------------------------------#

      class Group
        attr_reader :methods

        def initialize(yard_group)
          @yard_group = yard_group
          @methods = []
        end

        def name
          @name ||= @yard_group.lines.first.chomp.gsub('DSL: ','')
        end

        def to_param
          "#{name.parameterize}-group"
        end

        def description
          @yard_group.lines.drop(1).join
        end

        def add_method(yard_method)
          method = Method.new(self, yard_method)
          @methods << method unless @methods.find { |m| m.name == method.name }
        end
      end

      #------------------------------------------------------------------------#

      class Method
        attr_accessor :group

        def initialize(group, yard_method)
          @group, @yard_method = group, yard_method
        end

        def name
          @name ||= @yard_method.name.to_s.sub('=','')
        end

        def to_param
          name
        end

        def description
          @yard_method.docstring
        end

        def examples
          @yard_method.docstring.tags(:example).map { |e| e.text.strip }
        end

        def default_values
          return [] unless attribute
          r = []
          r << "spec.#{attribute.writer_name.gsub('=',' =')} #{attribute.default_value.inspect}" if attribute.default_value
          r << "spec.ios.#{attribute.writer_name.gsub('=',' =')} #{attribute.ios_default.inspect}" if attribute.ios_default
          r << "spec.osx.#{attribute.writer_name.gsub('=',' =')} #{attribute.osx_default.inspect}" if attribute.osx_default
          r
        end

        def keys
          keys = attribute.keys if attribute
          keys ||= []
          if keys.is_a?(Hash)
            new_keys = []
            keys.each do |key, subkeys|
              if subkeys && !subkeys.empty?
                subkeys = subkeys.map { |key| "`:#{key.to_s}`" }
                new_keys << "`:#{key.to_s}` #{subkeys * " "}"
              else
                new_keys << "`:#{key.to_s}`"
              end
            end
            keys = new_keys
          else
            keys = keys.map { |key| "`:#{key.to_s}`" }
          end
          keys
        end

        def required?
          attribute.required? if attribute
        end

        def multi_platform?
          attribute.multi_platform? if attribute
        end

        # Might return `nil` in case this is a normal method, not an attribute.
        #
        # TODO fix for Podfile
        def attribute
          @attribute ||= Pod::Specification.attributes.find { |attr| attr.reader_name.to_s == name }
        end
      end

      #------------------------------------------------------------------------#

      def description
        yard_registry.at("Pod::#{name}").docstring
      end

      def group_sort_order
        []
      end

      def columns
        group_sort_order.map do |column|
          column.map do |group_name|
            if group = groups.find { |g| g.name == group_name }
              group
            else
              raise "Unable to find group with name: #{group_name}"
            end
          end
        end
      end

      def groups
        unless @groups
          @groups = []

          yard_registry.all(:method).each do |yard_method|
            group = Group.new(yard_method.group)
            if existing = @groups.find { |g| g.name == group.name }
              group = existing
            else
              @groups << group
            end
            method = group.add_method(yard_method)
          end
        end
        @groups
      end

      private

      def yard_registry
        @registry ||= begin
          YARD::Registry.load([@source_file], true)
          YARD::Registry
        end
      end
    end

    class Podfile < DSL
    end

    class Specification < DSL
      def group_sort_order
        [
          ['Root specification'],
          ['File patterns', 'Dependencies'],
          ['Build configuration'],
          ['Platform', 'Multi-Platform support', 'Hooks']
        ]
      end
    end

    class Commands < Base
    end
  end
end

