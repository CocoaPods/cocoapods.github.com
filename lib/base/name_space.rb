module Pod
  module Doc

    # Provides support for generating the developer documentation for a name
    # space of a Gem.
    #
    class NameSpace < Base

      # @return [YARD::CodeObjects::NamespaceObject] the name space of this generator.
      #
      attr_reader :yard_object

      # @return [Gem] the name space of this generator.
      #
      attr_reader :gem_generator

      # @param [YARD::CodeObjects::NamespaceObject] yard_object
      # @param [Gem] gem_generator
      #
      def initialize(yard_object, gem_generator)
        @yard_object = yard_object
        @gem_generator = gem_generator
      end

      #-----------------------------------------------------------------------#

      # @!group Base overrides

      # @return [String]
      #
      def output_file
        File.expand_path(DOC_ROOT + "../developer/#{url_relative_to_gem}", __FILE__)
      end

      # @return [String]
      #
      def template_path
        File.expand_path(DOC_ROOT + "name_space_template.erb", __FILE__)
      end

      #-----------------------------------------------------------------------#

      require 'yard'
      include YARD::Templates::Helpers::BaseHelper
      include YARD::Templates::Helpers::HtmlHelper
      include YARD::Templates::Helpers::MethodHelper

      def options
        @options ||= YARD::Templates::TemplateOptions.new
      end

      def signature(*args)
        result = super
        result.gsub!(%r{</?[^>]+?>}, '')
        CGI.unescapeHTML(result)
      end


      #-----------------------------------------------------------------------#

      def url_relative_to_gem
        "#{gem_generator.name.underscore}/#{name.underscore}.html"
      end

      def name
        yard_object.name.to_s
      end

      def description
        yard_object.docstring
      end

      def root_less_name
        name_as_list[1..-1] * '::'
      end

      def children_names
        children.map(&:name)
      end

      def parent_name
        yard_object.parent.name
      end

      def root?
        yard_object.parent.is_a?(YARD::CodeObjects::RootObject)
      end

      def children
        yard_object.children.select{ |c| c.is_a?(YARD::CodeObjects::NamespaceObject) }
      end

      #-----------------------------------------------------------------------#

      def inheritance_tree
        return unless yard_object.is_a?(YARD::CodeObjects::ClassObject)
        @inheritance_tree ||= yard_object.inheritance_tree.map(&:name) * " < "
      end

      #-----------------------------------------------------------------------#

      # @return [Hash{String=>YARD::CodeObjects::MethodObject}]
      #
      def methods_by_group
        result = {}
        methods.each do |method|
          group = method.group ? method.group.lines.first : :no_group
          result[group] ||= []
          result[group] << method
        end
        result
      end

      # @return [Array<String>]
      #
      def groups
        methods_by_group.keys.reject{ |k| k == :no_group }
      end

      # All the methods of the namespace rejecting attributes setters.
      #
      # @return [Array<YARD::CodeObjects::MethodObject>] the methods of the
      #         namespace
      #
      def methods(included = false)
        all_methods = yard_object.meths(:visibility => :public, :scope => :instance, :included => included)
        method_names = all_methods.map { |m| m.name.to_s }
        # Attributes
        methods = all_methods.reject do |method|
          if method.name.to_s.match(/=$/)
            to_reader_name = method.name.to_s.gsub(/=$/,'')
            method_names.include?(to_reader_name)
          else
            false
          end
        end
        methods
      end

      # @return [Array<Array<String, YARD::CodeObjects::MethodObject>>]
      #
      def columns(group_height = 22, method_height = 22)
        max_columns      = 4
        groups_height    = groups.count * group_height
        methods_height   = methods_by_group.values.flatten.count * method_height
        total_height     = groups_height + methods_height
        height_percolumn = total_height / max_columns
        # height_percolumn = 44 unless height_percolumn > 44

        groups_and_methods = []
        methods_by_group.each do |group, methods|
          groups_and_methods << group
          groups_and_methods.concat(methods)
        end

        columns = []
        current_column = 0
        column_height = 0
        columns[0] = []
        groups_and_methods.each do |entry|
          next if entry == :no_group
          if column_height >= height_percolumn
            column_height = 0
            current_column += 1
            columns[current_column] = []
          end
          columns[current_column] << entry
          column_height += group?(entry) ? group_height : method_height
        end
        columns
      end

      # @return [Bool] whether a column value is a group name or a method.
      #
      def group?(value)
        value.is_a?(String)
      end

      def to_s
        yard_object.to_s
      end

      def name_as_list
        yard_object.to_s.split('::')
      end

      def parent_names
        name_as_list[0..-1]
      end
    end
  end
end
