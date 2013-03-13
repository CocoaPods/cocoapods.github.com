## Installing CocoaPods


### Dependencies

- Ruby MRI 2.0.0 or 1.8.7 (ships with Mac OS X)
- Xcode command line tools.


### Installation

To install CocoaPods you can run:

    $ [sudo] gem install cocoapods

To enjoy performance benefits you can install a modern Ruby like 2.0.0 trough a
Ruby manager like RVM. If you don't use the system Ruby avoid to use sudo as it
creates bad effects.

### Update

To update CocoaPods you can run:

    $ [sudo] gem update cocoapods

If you would like to try a pre-release version of CocoaPods you can run:

    $ [sudo] gem update cocoapods --pre


### Troubleshooting

- The gem might not be able to compile, to solve this you might need to symlink
  GCC.

- If you used an pre release version of Xcode you might need to update the
  command line tools.

- CocoaPods is not compatible with MacRuby.
