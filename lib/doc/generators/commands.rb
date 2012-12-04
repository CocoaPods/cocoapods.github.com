module Pod
  module Doc
    module Generators

      # Provides support for describing executable commands and options.
      #
      class Commands < Base

        def initialize(*args)
          $:.unshift((DOC_GEM_ROOT + 'cocoapods/lib').to_s)
          require 'cocoapods'
          super
        end

      end

    end
  end
end
