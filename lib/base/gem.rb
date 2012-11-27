module Pod
  module Doc

    # Provides support for generating the developer documentation of a Gem.
    #
    class Gem < Base

      require 'rubygems'

      attr_reader :gem_spec_file

      attr_reader :root_module

      # @param [Pathname] gem_spec_file
      #
      def initialize(gem_spec_file, root_module = nil)
        @gem_spec_file = gem_spec_file
        @root_module = root_module
      end

      # @return [Gem::Specification]
      #
      def gem
        @gem ||= ::Gem::Specification.load(gem_spec_file.to_s)
      end

      #-----------------------------------------------------------------------#

      # @return [String]
      #
      def name
        gem.name
      end

      # @return [String]
      #
      def version
        gem.version
      end

      # @return [String]
      #
      def authors
        gem.authors.to_sentence
      end

      # @return [String]
      #
      def description
        gem.description
      end

      # @return [String]
      #
      def readme
        readme = gem_spec_file + '../README.md'
        markdown(readme.read)
      end

      # @return [YARD::CodeObjects::NamespaceObject]
      #
      def name_spaces
        unless @name_spaces
          yard_objects = yard_registry.all(:class, :module).sort_by(&:to_s)
          name_spaces = yard_objects.map { |o| NameSpace.new(o) }
          @name_spaces = name_spaces.reject do |name_space|
            name_space.methods.empty? || (!root_module.nil? && name_space.name_as_list.first != root_module)
          end
        end
          @name_spaces
      end

      def name_spaces_as_list
        name_spaces.map(&:parent_name)
      end

      def name_spaces_tree
        result = {}
        name_spaces.each do |name_space|
          if name_space.root?
            result[name_space.name] ||= {}
          else
            parent_hash = result
            name_space.name_as_list.each do |name|
              parent_hash[name] ||= {}
              parent_hash =  parent_hash[name]
            end
          end
        end
        result
      end

      # HELPER
      def tree_to_html(hash)
        r = ''
        hash.each do |key, subhash|
          r << "<li><p>#{key}</p>"
          r << "<ul>#{tree_to_html(subhash)}</ul>" unless subhash.empty?
          r << "</li>"
        end
        r
      end

      #-----------------------------------------------------------------------#

      # @!group Base overrides

      # @return [Array<Pathname>]
      #
      def source_files
        gem.files.select { |f| f.end_with?('.rb') }
      end

      # @return [YARD::CodeObjects::Base]
      #
      def yard_object
        yard_registry.at("Pod")
      end

      # @return [String]
      #
      def output_file
        File.expand_path(DOC_ROOT + "../developer/#{name.underscore}.html", __FILE__)
      end

      # @return [String]
      #
      def template_path
        File.expand_path(DOC_ROOT + "gem_template.erb", __FILE__)
      end

      def render
        super
      end

      #-----------------------------------------------------------------------#

      class NameSpace

        # @return [YARD::CodeObjects::NamespaceObject]
        #
        attr_reader :yard_object

        # @param [YARD::CodeObjects::NamespaceObject] yard_object
        #
        def initialize(yard_object)
          @yard_object = yard_object
        end

        def name
          yard_object.name
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
        def columns
          max_columns      = 4
          group_height     = 22 #40 #px
          method_height    = 22 #px
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
end
