cocoapods.github.com
====================

User and developer documentation for CocoaPods.

## Architecture

This application builds a static site with the [Middlemand](http://middlemanapp.com).
The information for the templates is gathered either from the comments of the Gems or 
from the Markdown files available in the repo. The source files of the Gems are processed
with [YARD](http://yardoc.org) and the information is stored in YAML files.

## Getting Started

```console
$ rake bootstrap
$ rake build
$ middleman
```

To seel all the availble rake taks:

```console
$ rake -T
```


## Collaborate

All CocoaPods development happens on GitHub, there is a repository for CocoaPods and one for the CocoaPods specs. Contributing patches or Pods is really easy and gratifying. You even get push access when one of your specs or patches is accepted.

Follow @CocoaPodsOrg to get up to date information about what's going on in the CocoaPods world.

## License

This repository and CocoaPods are available under the MIT license.