## Dependency version workflow
There is, unfortunately, often an issue of devs not interpreting version numbers well or assigning emotional value to certain version numbers.

However, arbitrary revisions as version is not a good idea for a library manager vs a proper version number (see [Semantic Versioning](http://semver.org)). Let me explain how, in an ideal world ;), I’d prefer people to interact with it:

* “I want to start using CocoaLumberjack, the current version will be fine for now.” So the dev adds a dependency on the lib _without_ a version requirement and lets the manager install it which will use the latest version:

        pod 'CocoaLumberjack'

* Some time into the future, the dev wants to update the dependencies so runs the install command again, which will now install the version of the lib which is the latest version _at that time_.

* At some point the dev is finished on the client work (or a newer version of the lib changes the API and the changes aren’t needed) so the dev adds a version requirement to the dependency. For instance, consider that the author of the lib follows the semver guidelines, you can somewhat trust that between ‘1.0.7’ and ‘1.1.0’ **no** API changes will be made, but only bug fixes. So instead of requiring a specific version, the dev can specify that _any_ ‘1.0.x’ is allowed as long as it’s higher than ‘1.0.7’:

        pod 'CocoaLumberjack', '~> 1.0.7'


The point is that devs can easily keep track of newer versions of dependencies, by simply running `pod install` again, which they might otherwise do less if they had to change everything manually.

### CocoaPods Versioning Specifics

CocoaPods uses RubyGems versions for specifying pod spec versions. The [RubyGems Versioning Policies](http://docs.rubygems.org/read/chapter/7) describes the rules used for interpreting version numbers. The [RubyGems version specifiers](http://docs.rubygems.org/read/chapter/16#page74) describe exactly how to use the comparison operators which specify dependency versions.

Following the pattern established in RubyGems, pre-release versions can also be specified in CocoaPods. A pre-release of version 1.2, for example, can be specified by '1.2.beta.3'. In this example, the dependency specifier '~> 1.2.beta' will match '1.2.beta.3'.
