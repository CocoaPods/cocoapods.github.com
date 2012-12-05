
# The gems are stored in the `gems` directory which is not under source
# control.
#
# At the moment I'm preferring this approach because I can add the gems with
# the SSH url. Without forcing them on users without access to it. It might
# make sense convert to submodules.
#
namespace :gems do

  desc "Downloads the gems in a temporary directory"
  task :bootstrap do
    FileUtils.mkdir_p 'gems'
    Dir.chdir 'gems' do
      sh 'git clone git@github.com:CocoaPods/CocoaPods.git' unless File.exist?("CocoaPods")
      sh 'git clone git@github.com:CocoaPods/Core.git'      unless File.exist?("Core")
      sh 'git clone git@github.com:CocoaPods/Xcodeproj.git' unless File.exist?("Xcodeproj")
      sh 'git clone git@github.com:CocoaPods/CLAide.git'    unless File.exist?("CLAide")
    end
  end

  desc "Downloads the gems in a temporary directory"
  task :update => :bootstrap do
    FileUtils.mkdir_p 'gems'
    Dir.glob('gems/*').each do |subdir|
      Dir.chdir subdir do
        puts "Updating #{subdir}"
        sh 'git pull'
      end
    end
  end
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
    # TODO
  end

  # TODO To generate reliable urls, they should be considered part of the
  # model, an it should be computed by the code objects.
  #
  desc "Generates the data for the search."
  task :search do

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

  task :all => [:dsl, :gems, :commands]
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
  puts "## Deploying branch to master brach"
#   cp_r ".nojekyll", "build/.nojekyll"
#   cd "build" do
#     system "git add ."
#     system "git add -u"
#     puts "\n## Commiting: Site updated at #{Time.now.utc}"
#     message = "Site updated at #{Time.now.utc}"
#     system "git commit -m \"#{message}\""
#     puts "\n## Pushing generated website"
#     system "git push origin master"
#     puts "\n## Github Pages deploy complete"
#   end
end

task :default => 'generate:all'
