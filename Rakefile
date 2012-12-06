
desc "Downloads the gems in a temporary directory"
task :bootstrap do
  sh "git submodule update --init"
  FileUtils.mkdir_p 'docs_data'
end

#-----------------------------------------------------------------------------#

def gems
  %w[ CocoaPods CocoaPods-Core Xcodeproj CLAide ]
end

def dsls
  %w[ Specification Podfile ]
end

#-----------------------------------------------------------------------------#

# Generates the data YAML ready to be used by the Middleman.
#
namespace :generate do
  require 'pathname'
  ROOT = Pathname.new(File.expand_path('../', __FILE__))
  $:.unshift((ROOT + 'lib').to_s)
  require 'doc'

  desc "Generates the data for the dsl."
  task :dsl do
    puts "\e[1;33mBuilding DSL Data\e[0m"

    dsls.each do |name|
    dsl_file = (ROOT + "gems/Core/lib/cocoapods-core/#{name.downcase}/dsl.rb").to_s
      generator = Pod::Doc::Generators::DSL.new(dsl_file)
      generator.name = name
      generator.output_file = "docs_data/#{name.downcase}.yaml"
      generator.save
    end
  end

  desc "Generates the data for the gems."
  task :gems do
    puts "\e[1;33mBuilding Gems Data\e[0m"

    gems.each do |name|
      github_name = name == 'CocoaPods-Core' ? 'Core' : name
      generator = Pod::Doc::Generators::Gem.new(ROOT + "gems/#{github_name}/#{name}.gemspec")
      generator.name = name
      generator.github_name = github_name
      generator.output_file = "docs_data/#{name.downcase.gsub('-','_')}.yaml"
      generator.save
    end
  end

  desc "Generates the data for the commands."
  task :commands do
    # puts "\e[1;33mBuilding Commands Data\e[0m"
    # TODO
  end

  # TODO To generate reliable urls, they should be considered part of the
  # model, an it should be computed by the code objects.
  #
  desc "Generates the data for the search."
  task :search do
    puts "\e[1;33mBuilding Search Data\e[0m"

    # [Hash{String=>Hash{String=>String}]
    result = {
      'dsls'        => {},
      'name_spaces' => {},
      'methods'     => {},
    }

    # FIXME DSL should have urls similar to the gems
    #
    dsls.each do |name|
      name = name.downcase.gsub('-','_')
      file = "docs_data/#{name}.yaml"
      dsl  = YAML::load(File.open(file))
      dsl.meths.compact.each do |method|
        result['dsls']["#{name}/#{method.name.downcase}"] = "#{name}.html##{method.name.downcase}"
      end
    end

    gems.each do |name|
      name = name.downcase.gsub('-','_')
      file = "docs_data/#{name}.yaml"
      gem  = YAML::load(File.open(file))
      gem.name_spaces.each do |ns|
        result['name_spaces'][ns.ruby_path] = "#{name}/#{ns.ruby_path.downcase.gsub(/::/,'/')}"
        ns.meths.compact.each do |method|
          result['methods'][method.ruby_path] = "#{name}/#{method.ruby_path.downcase.gsub(/::/,'/')}"
        end
      end
    end

    require 'json'
    File.open('source/typeahead.json', 'w') { |f| f.puts(result.to_json) }
  end

  task :all => [:dsl, :gems, :commands, :search]
end

#-----------------------------------------------------------------------------#

desc "Generates the data for the commands."
task :build => 'generate:all' do
  sh "middleman build"
end

#-----------------------------------------------------------------------------#

desc "deploy build directory to github pages"
task :bootstrap_build do
  FileUtils.rm_rf 'build'
  sh 'git clone git@github.com:CocoaPods/cocoapods.github.com.git build'
end

# From http://stackoverflow.com/questions/11809180/middleman-and-github-pages
#
desc "deploy build directory to github pages"
task :deploy do
  puts "\e[1;33mDeploying branch to master brach\e[0m"
  cd "build" do
    sh "git add ."
    sh "git add -u"
    sh "git commit -m 'Site updated at #{Time.now.utc}'"
    sh "git push origin master"
  end
  puts "\e[1;32mGithub Pages deployed at https://github.com/CocoaPods/cocoapods.github.com\e[0m"
end

task :default => 'generate:all'
