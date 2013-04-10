## Contributing to the master repo

The master repo contains specifications of open-source Objective-C libraries.

### Details

- installation path: `~/.cocoapods/master`
- home: https://github.com/CocoaPods/Specs

### Contributing

To ensure a high quality, reliable collection of Pods, the master repo is
strict about the acceptable specifications. The CocoaPods linter (see the `pod
spec lint` command) is used to validate specifications, and no errors or warnings
are accepted.

The highest priority of the master repo is to guarantee the integrity of existing
CocoaPods installations.

In general this means that:

- A specification cannot be deleted.
- Specifications can be updated only if they don't affect existing installations.
  - Broken specifications can be updated.
  - Subspecs can be added as they are included by the parent specification by default.
- Only authoritative versions are accepted.

CocoaPods uses a versioning scheme known as [Semantic
Versioning](http://semver.org/), necessary for [cross resolution of
dependencies](https://github.com/CocoaPods/Specs/wiki/Cross-dependencies-resolution-example).

### Unversioned libraries

One of the CocoaPods goals is to promote the discovery of open-source software,
for this reason new Pods for libraries which are not versioned are accepted in
the master repo. The specifications of those pods should carry the version
`0.0.1` under the assumption that, if the author starts versioning, she/he is
unlikely to pick `0.0.1`. This is the only exception for authoritative
versions.

If you add an unversioned Pod it is your responsibility to ask the author of
the library to tag versions, luckily we have a
[template](https://github.com/CocoaPods/Specs/wiki/%22Please-add-semantic-version-tags%22-issue-template)
for this.

__To prevent collisions with possible future versions, unversioned libraries
can't be updated until the author starts to tag them.__

If you need to update an unversioned library you can:

- Ask the author to version the library.
- Maintain a fork which is versioned. This fork should be clearly namespaced
  from the original library according the `NAME@USER` convention (e.g.
  `Reachability@irrationalfab`). It should also mention in the summary that it
  is a versioned fork.
- Create a podspec and use it in a private repo.


### Creating podspecs

Creating a podspec is very easy as we provide templates full of examples.

You can use the following command:

    $ pod spec create Bananas

If the library is hosted on GitHub you can pass the url so CocoaPods can precompile the template:

    $ pod spec create https://github.com/Bananas/Bananas

A this point you need edit compile the template (a pod specification is a Ruby source file):

    $ pod spec lint Bananas.podspec --verbose

### Sharing podspecs

When a podspec lints you can submit it to the master repo.

##### Without push access

You need to fork the master repo on github, then you need to:

    $ cd ~/.cocoapods/master
    $ git checkout -b fork
    $ git remote add myfork https://github.com/YOUR_USER_NAME/Specs.git
    $ cp ~/Bananas.podspec ~/.cocoapods/master/Bananas/VERSION/
    $ git push myfork
    $ git checkout master

Once you push your changes, you can make a pull request on CocoaPods/Specs.

##### With push access

    $ pod push Bananas.podspec
