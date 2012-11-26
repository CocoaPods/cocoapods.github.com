module Pod
  module Doc

    # Provides suppor for describing a DSL.
    #
    class DSL < Base

      def yard_object
        yard_registry.at("Pod::#{name}::DSL")
      end

      # @return [DSL::Group]
      #
      def groups
        unless @groups
          @groups = []
          yard_methods = yard_object.meths.reject{ |m| m.name.to_s =~ /^_/ }
          yard_methods.each do |yard_method|
            group = DSL::Group.new(yard_method.group)
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

      #-----------------------------------------------------------------------#

      #
      #
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

      #-----------------------------------------------------------------------#

      #
      #
      class Method
        attr_accessor :group

        def initialize(group, yard_method)
          @group, @yard_method = group, yard_method
        end

        def name
          @name ||= @yard_method.name.to_s.sub('=','')
        end

        def to_param
          name.parameterize
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
          @attribute ||= Pod::Specification::DSL.attributes.find { |attr| attr.reader_name.to_s == name }
        end
      end
    end
  end
end

