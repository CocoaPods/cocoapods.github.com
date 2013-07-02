cocoapods.github.com
====================

User and developer documentation for CocoaPods.

## Information Sources

This application gathers information from the following sources:

- [Podfile](https://github.com/CocoaPods/Core/blob/master/lib/cocoapods-core/podfile/dsl.rb)
- [Specification](https://github.com/CocoaPods/Core/blob/master/lib/cocoapods-core/specification/dsl.rb)
- [Command Line](https://github.com/CocoaPods/CocoaPods/tree/master/lib/cocoapods/command)
- [Guides](https://github.com/CocoaPods/cocoapods.github.com/tree/develop/source/guides)

If you find any area which could be improved, pull requests are welcome and
make good karma.

## Architecture

This application builds a static site by using the [Middleman](http://middlemanapp.com).

The source files of the individual libraries are processed with [YARD](http://yardoc.org)
and the pre-processed result is stored in YAML files.

The information for the HTML templates is gathered either from the YAML data of the
individual libraries or from the Markdown files available in this repo.

## Getting Started

```console
$ rake bootstrap
$ rake middleman:build
```

To see all the availible rake taks:

```console
$ rake -T
```


## Collaborate

All CocoaPods development happens on GitHub, there is a repository for CocoaPods and one for the CocoaPods specs. Contributing patches or Pods is really easy and gratifying. You even get push access when one of your specs or patches is accepted.

Follow @CocoaPods to get up to date information about what's going on in the CocoaPods world.

## License

This repository and CocoaPods are available under the MIT license.
