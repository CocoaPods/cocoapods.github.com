module Pod
  module Doc
    module Generators

      class Gem < Base

        # @param [Pathname] gem_spec_file
        #
        def initialize(gem_spec_file, root_module = nil)
          require 'rubygems'
          @gem_spec_file = gem_spec_file
          gem_dir = File.dirname(gem_spec_file)
          Dir.chdir(gem_dir) do
            @ruby_gem = ::Gem::Specification.load(gem_spec_file.to_s)
          end
          gem_files = @ruby_gem.files.map { |file| "#{gem_dir}/#{file}" }
          source_files = gem_files.select { |f| f.end_with?('.rb') }
          super(source_files)
        end

        #
        #
        attr_reader :gem_spec_file

        #
        #
        attr_reader :ruby_gem

        #
        #
        attr_accessor :github_name

        # Optional
        #
        attr_accessor :root_module

        #---------------------------------------------------------------------#

        #
        #
        def generate_code_object
          gem             = Doc::CodeObjects::Gem.new
          gem.name        = name
          gem.github_name = github_name
          gem.version     = ruby_gem.version.to_s
          gem.authors     = ruby_gem.authors.to_sentence
          gem.description = ruby_gem.description
          gem.name_spaces = generate_name_spaces(yard_registry, gem)
          set_name_spaces_parents(gem)
          # readme_file = gem_spec_file + '../README.md'
          # @readme markdown_h(readme.read)
          gem
        end

        # http://rubydoc.info/docs/yard/YARD/CodeObjects/ModuleObject
        # http://rubydoc.info/docs/yard/YARD/CodeObjects/ClassObject
        #
        def generate_name_spaces(yard_registry, gem)
          yard_name_spaces = yard_registry.all(:class, :module).sort_by(&:to_s)
          yard_name_spaces.map do |yard_name_space|
            namespace             = Doc::CodeObjects::NameSpace.new
            namespace.name        = yard_name_space.name
            namespace.gem         = gem
            namespace.full_name   = yard_name_space.to_s
            namespace.visibility  = yard_name_space.visibility
            namespace.groups      = generate_groups(yard_name_space, namespace)
            namespace.html_description = markdown_h(yard_name_space.docstring.to_s)

            if yard_name_space.is_a?(YARD::CodeObjects::ClassObject)
              namespace.is_class  = true
              # namespace.inherited_constants = yard_name_space.inherited_constants
              # namespace.inherited_meths     = yard_name_space.inherited_meths
              namespace.is_exception        = yard_name_space.is_exception?
              namespace.superclass          = yard_name_space.superclass.to_s
            end
            namespace
          end
        end

        #
        #
        def set_name_spaces_parents(gem)
          gem.name_spaces.each do |namespace|
            segments = namespace.full_name.split('::')
            if segments.count == 1
              namespace.parent = gem
            else
              parent = gem.name_spaces.find { |ns| ns.full_name == segments[0..-2] * '::' }
              raise 'Unable to find a parent' unless parent
              namespace.parent = parent
            end
          end

        end

        #
        #
        def generate_groups(yard_name_space, namespace)
          methods_by_group = {}
          yard_name_space.meths.each do |yard_method|
            methods_by_group[yard_method.group] ||= []
            methods_by_group[yard_method.group] << yard_method
          end

          groups = []
          methods_by_group.each do |yard_group, yard_method|
            group                  = Doc::CodeObjects::Group.new
            group.parent           = namespace
            group.name             = yard_group ? yard_group.lines.first.chomp : nil
            group.html_description = yard_group ? markdown_h(yard_group.lines.drop(1).join) : nil
            group.meths            = yard_method.map { |m| generate_method(m, yard_name_space, namespace) }

            group.meths.each { |m| m.group = group }
            groups << group
          end
          groups
        end

        #
        #
        def generate_method(yard_method, yard_name_space, namespace)
          method                         = Doc::CodeObjects::GemMethod.new
          method.parent                  = namespace
          method.name                    = yard_method.name
          method.html_description        = markdown_h(yard_method.docstring.to_s)
          method.examples                = compute_method_examples(yard_method)
          method.source_files            = yard_method.files.map { |f| [f[0].gsub(/^.*\/lib\//,'lib/'), f[1]] }
          method.spec_files              = find_spec_files(method.source_files)
          method.scope                   = yard_method.scope
          method.signature               = yard_method.signature
          method.visibility              = yard_method.visibility
          method.html_source             = syntax_highlight(yard_method.source)
          method.is_attribute            = yard_method.is_attribute?
          # method.is_alias                = yard_method.is_alias?
          method.parameters              = compute_method_parameters(yard_method, :param)
          method.returns                 = compute_method_parameters(yard_method, :return)
          method.html_signature          = compute_method_signature(yard_method)
          method.html_todos              = yard_method.tags('todo').map { |t| markdown_h(t.text) }
          if yard_name_space.is_a?(YARD::CodeObjects::ClassObject)
            method.inherited               = yard_name_space.inherited_meths.include?(yard_method)
          end
          #aliases
          #owner
          method
        end

        def find_spec_files(source_files)
          spec_dir = gem_spec_file + '../spec'
          source_files.map do |source_file|
            name =  File.basename(source_file[0], '.rb')
            files = Dir.glob(spec_dir + "**/#{name}_spec.rb")
            files.map { |f| f.gsub(/^.*\/spec\//,'spec/') }
          end.flatten.compact
        end

        # Taken from YARD
        #
        def compute_method_signature(yard_method)
          if yard_method.tags(:overload).size == 1
            syntax_highlight signature(yard_method.tag(:overload), false)
          elsif yard_method.tags(:overload).size > 1
            yard_method.tags(:overload).each do |overload|
              syntax_highlight signature(overload, false)
            end
          else
            syntax_highlight signature(yard_method, false)
          end
        end

        def compute_method_parameters(yard_method, tag_name)
          r = yard_method.docstring.tags(tag_name).map do |tag|
            param = CodeObjects::Param.new
            param.name  = tag.name
            if tag.types
              param.types = tag.types
            else
              warn "Missing types for tag #{tag.name} of method #{yard_method.name}"
            end
            if tag.text
              param.html  = markdown_h(tag.text.strip)
            else
              warn "Missing text for tag #{tag.name} of method #{yard_method.name}"
            end
            param
          end
          r  unless r.empty?
        end

        # @return [Array<CodeObjects::Example>] The list of the default values of the
        #         attribute in HTML.
        #
        #         In this context the name of the tag is used as the
        #         description.
        #
        def compute_method_examples(yard_method)
          r = yard_method.docstring.tags(:example).map do |e|
            CodeObjects::Example.new(e.name, syntax_highlight(e.text.strip))
          end
          r  unless r.empty?
        end


        #---------------------------------------------------------------------#

        require 'yard'
        include YARD::Templates::Helpers::BaseHelper
        include YARD::Templates::Helpers::HtmlHelper
        include YARD::Templates::Helpers::MethodHelper

        def options
          @options ||= YARD::Templates::TemplateOptions.new
        end

        # @see ./lib/yard/templates/helpers/html_helper.rb:468
        def signature(meth, link = true, show_extras = true, full_attr_name = true)
          args = format_args(meth)
          name = meth.name
          type = signature_types(meth, false)
          type = 'undefined' if type.empty?
          "#{name}#{args} #=> #{type}"

        end

        # @see lib/yard/templates/helpers/html_helper.rb:415
        def format_types(typelist, brackets = true)
          return 'undefined' if typelist.empty?
          return typelist unless typelist.is_a?(Array)
          typelist.join(", ")
        end

        def signature_types(meth, link = true)
          r = super
          r.gsub!(/[\(\)]/, '')
          r
        end

        # @see lib/yard/helpers/method_helper.rb:6
        def format_args(object)
          return if object.parameters.nil?
          params = object.parameters
          if object.has_tag?(:yield) || object.has_tag?(:yieldparam)
            params.reject! do |param|
              param[0].to_s[0,1] == "&" &&
                !object.tags(:param).any? {|t| t.name == param[0][1..-1] }
            end
          end

          unless params.empty?
            args = params.map {|n, v| v ? "#{n} = #{v}" : n.to_s }.join(", ")
            "(#{args})"
          else
            ""
          end
        end

        #---------------------------------------------------------------------#

        def format_constant(value)
          sp = value.split("\n").last[/^(\s+)/, 1]
          num = sp ? sp.size : 0
          html_syntax_highlight value.gsub(/^\s{#{num}}/, '')
        end

        #---------------------------------------------------------------------#

      end
    end
  end
end
