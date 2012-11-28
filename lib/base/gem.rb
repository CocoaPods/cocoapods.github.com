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

      # @return [NameSpace] all the namespaces descrbied by the source files of the gem.
      #
      def all_name_spaces
        @all_name_spaces ||= yard_registry.all(:class, :module).sort_by(&:to_s).map { |obj| NameSpace.new(obj, self) }
      end

      # @return [NameSpace] all the namespaces that contains methods.
      #
      def name_spaces
        @name_spaces ||= all_name_spaces.reject do |name_space|
          name_space.methods.empty? || (!root_module.nil? && name_space.name_as_list.first != root_module)
        end
      end

      # @return [NameSpace] all the namespaces that contain children namespaces.
      #
      def name_spaces_with_children
        @name_spaces_with_children ||= all_name_spaces.reject do |name_space|
          name_space.children.empty?
        end
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
        name_spaces.each { |ns| ns.render }
        super
      end
    end
  end
end
