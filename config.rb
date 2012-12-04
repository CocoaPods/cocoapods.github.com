
set :css_dir,           'css'
set :js_dir,            'js'
set :images_dir,        'img'
set :encoding,          'utf-8'
set :relative_links,    true

# Support for browsing from the build folder.
set :strip_index_file,  false

configure :build do
  activate :minify_javascript
  activate :minify_css
  activate :relative_assets
  activate :asset_hash
end

#--------------------------------------#

set :markdown_engine, :redcarpet
set :markdown, {
  :fenced_code_blocks => true,
  :autolink           => true,
  :smartypants        => true }

activate :automatic_image_sizes
#--------------------------------------#


#------------------------------------------------------------------------------#

require "lib/navigation_helpers.rb"
require "lib/html_helpers.rb"
require 'lib/doc/code_objects'

helpers NavigationHelpers
helpers HTMLHelpers

#--------------------------------------#

# Loading data

navigation_data = YAML::load(File.open('docs_data/navigation.yaml'))
content_for :dsl_data do navigation_data * '<br>' end

# Dynamic pages

navigation_data['dsl'].each do |name|
  proxy "#{name}.html", "templates/dsl.html", {
    :locals => { :name => name },
    :ignore => true
  }
end

gems = []
navigation_data['gems'].each do |name|
  proxy "#{parameterize name}/index.html", "templates/gem.html", {
    :locals => { :name => name },
    :ignore => true
  }

  proxy "#{parameterize name}/name_spaces.html", "templates/gem_namespaces_list.html", {
    :locals => { :name => name },
    :ignore => true
  }

  proxy "#{parameterize name}/gem_todo_list.html", "templates/gem_todo_list.html", {
    :locals => { :name => name },
    :ignore => true
  }

  # FIXME
  gem = deserialize(name)
  gems << gem
  gem.name_spaces.each do |name_space|
    proxy "#{link_for_code_object(name_space)}/index.html", "templates/gem_namespace.html", {
      :locals => { :name_space => name_space, :code_object => name_space },
      :ignore => true
    }
  end
end
data.store('gems', gems)





