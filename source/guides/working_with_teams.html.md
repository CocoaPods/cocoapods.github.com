## Working with teams

To effectively work with teams it is necessary to understand the interdependence of
two CocoaPods files.

- `Podfile.lock`
- `Pods/Manifest.lock`


### Podfile.lock

This file keeps track of what version of a Pod is installed. For example the
following dependency might install RestKit 0.10.3:

    pod 'RestKit'

Thanks to the `Podfile.lock` every machine which runs pod install on the
hypothetical project will use RestKit 0.10.3 even if a newer version is
available. CocoaPods will honor this version unless the dependency is updated
on the Podfile or `pod update` is called. In this way CocoaPods avoids headaches
caused by unexpected changes to dependencies.

This file should always be kept under version control.

### Manifest.lock

If you use CocoaPods the `Pods` folder, it is not expected to be under source
control (as long as you trust the remotes which provide the sources for your
Pods). The `Manifest.lock` stores the information of which version of Pod is
installed in a specific Pods folder. It is a copy of the Podfile.lock at the
time of the last installation on that machine.

### The big picture

Once an installation is invoked, CocoaPods compares the Podfile to the
Podfile.lock. If the installation was triggered by `pod install` all the
versions of the non-changed Pods are locked and thus will not be updated. Once
the resolution process is completed CocoaPods will compare the resolved version
of the Pods to the Pods/Manifest.lock in order to detect which Pods actually
need to be installed.

### Note

Currently CocoaPods doesn't keep track of the specific checkout SHA of Pods
obtained through external sources, which might create different installations
across machines if the external sources are not specific.

For example, at the moment CocoaPods doesn't keep track of the commit SHA for
the following dependency:

    pod 'AFNetworking', :git => 'https://github.com/AFNetworking/AFNetworking'

