require 'yard'
require 'redcarpet'
require 'pygments'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/array/conversions'

DOC_ROOT = Pathname.new(File.expand_path('../', __FILE__))
$:.unshift((DOC_ROOT).to_s)

require 'base'
require 'base/dsl'
require 'base/commands'
require 'base/gem'
require 'base/name_space'




