## Creating and maintaining a pod

The following file structure is suggested:

```
.
├── Classes
    └── ios
    └── osx
├── Resources
├── Project
    └── Podfile
├── LICENSE
├── Readme.markdown
└── NAME.podspec
```

The suggested Project/Podfile

```ruby
 platform :ios
#platform :osx

 podspec :path => "../NAME.podspec"
```

The `podspec` is a shortcut to require all the dependencies specified in `NAME.podspec`.

### Development

You can work on the library from its project. Alternatively you can work from an application project using the `:local` option:

```ruby
pod 'Name', :local => '~/code/Pods/NAME'
```

You can also lint the pod against the files of its directory:

```shell
$ cd ~/code/Pods/NAME
$ pod spec lint --local
```

### Release

The release workflow can be the following.

```shell
$ cd ~/code/Pods/NAME
$ edit NAME.podspec
# set the new version to 0.0.1
# set the new tag to 0.0.1
$ pod spec lint --local

$ git add -A && git commit -m "Release 0.0.1."
$ git tag '0.0.1'
$ git push --tags
$ pod push master
```

You can also simplify the podspec to skip a step:

```ruby
 s.version = '1.0.0'
 s.source = { :git => "https://example.com/repo.git", :tag => s.version.to_s }
#s.source = { :git => "https://example.com/repo.git", :tag => "v#{s.version}" }

```
