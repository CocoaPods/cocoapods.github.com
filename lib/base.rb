module Pod
  module Doc

    class Base
      TEMPLATE = File.expand_path('../template.erb', __FILE__)

      attr_reader :source_file

      def initialize(source_file)
        @source_file = source_file
      end

      def output_file
        File.expand_path("../../#{name.underscore}.html", __FILE__)
      end

      def sections
        %w{ Podfile Specification Commands }
      end

      def name
        self.class.name.split('::').last
      end

      #--------------------#

      # @!group YARD information

      # @return [YARD::CodeObjects::Base]
      #
      def yard_object
        yard_registry.at("Pod::#{name}")
      end

      # @return [String]
      #
      def description
        yard_object.docstring
      end

      def groups
        [] # TODO
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

      def template_path
        TEMPLATE
      end

      def render
        require 'erb'
        template = ERB.new(File.read(template_path))
        File.open(output_file, 'w') { |f| f.puts(template.result(binding)) }
      end

      #--------------------#

      # @!group ERB Helpers

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

      #--------------------#

      # @!group YARD Registry

      private

      def source_files
        [@source_file]
      end


      def yard_registry
        @registry ||= begin
          YARD::Registry.load(source_files, true)
          YARD::Registry
        end
      end
    end
  end
end
