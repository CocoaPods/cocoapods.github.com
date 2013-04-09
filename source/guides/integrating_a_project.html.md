# Integrating with an Xcode project

## Before you begin

1. Check the [Specs](http://github.com/CocoaPods/Specs) repository to make sure the libraries you would like to use are available.
2. [Install CocoaPods on your computer][installing-cocoapods].

## Installation

1. Create a [Podfile][podfile], and add your dependencies:

```
    pod 'AFNetworking', '~> 1.0'  
    pod 'ObjectiveSugar', '~> 0.5'
```

2. Run `$ pod install` in your project directory.
3. Open `App.xcworkspace` and build.

### What this does

In Xcode, it:

1. [Creates or updates a workspace.][creating-a-workspace]
2. [Adds your project to the workspace if needed.][adding-projects-to-workspace]
3. [Adds the CocoaPods static library project to the workspace if needed.][adding-projects-to-workspace]
4. [Adds libPods.a to: targets => build phases => link with libraries.][adding-build-target-dependencies]
5. Adds the CocoaPods Xcode configuration file to your app’s project.
6. [Changes your app's target configurations to be based on CocoaPods's.][basing-target-configurations-on-xcconfig] (Expand the ‘To add a new build configuration…’ section of the linked page for a howto.)
7. Adds a build phase to copy resources from any pods you installed to your app bundle. i.e. a ‘Script build phase’ after all other build phases with the following:
  * Shell: `/bin/sh`
  * Script: `${SRCROOT}/Pods/PodsResources.sh`

Note that steps 3 onwards are skipped if the CocoaPods static library is already in your project.

This is largely based on [http://blog.carbonfive.com/2011/04/04/using-open-source-static-libraries-in-xcode-4](http://blog.carbonfive.com/2011/04/04/using-open-source-static-libraries-in-xcode-4).  
  


## FAQ & Troubleshooting

_“A curse a day keeps the Xcode doctor away.”_

1. If something doesn’t seem to work, first of all ensure that you are not completely overriding any options set from the `Pods.xcconfig` file in your project’s build settings. To add values to options from your project’s build settings, prepend the value list with `$(inherited)`.

2. If Xcode can’t find the headers of the dependencies:
   * Check if the pod header files are correctly symlinked in `Pods/Headers` and you are not overriding the `HEADER_SEARCH_PATHS` (see #1).
   * Make sure your project is using the `Pods.xcconfig`.   
   _To check this select your project file, then select it in the second pane again and open the `Info` section in the third pane. Under configurations you should select `Pods.xcconfig` for each configurations requiring your installed pods._
   * If Xcode still can’t find them, as a last resort you can prepend your imports, e.g. `#import <Pods/SSZipArchive.h>`.  

3. If you're getting errors about unrecognized C compiler command line options, e.g. `cc1obj: error: unrecognized command line option "-Wno-sign-conversion"`:
   * Make sure your project build settings are [configured](https://img.skitch.com/20111120-brfn4mp8qwrju8w8325wphan9h.png) to use "Apple LLVM compiler" (clang)
   * Are you setting the `CC`, `CPP` or `CXX` environment variable, e.g. in your `~/.profile`? This may interfere with the Xcode build process. Remove the environment variable from your `~/.profile`.

4. If Xcode complains when linking, e.g. `Library not found for -lPods`, it doesn't detect the implicit dependencies:
   * Go to Product > Edit Scheme
   * Click on Build
   * Add the `Pods` static library, and make sure it's at the top of the list
   * Clean and build again
   * If that doesn't work, verify that the source for the spec you are trying to include has been pulled from github. Do this by looking in &lt;Project Dir>/Pods/&lt;Name of spec you are trying to include>. If it is empty (it should not be), verify that the ~/.cocoapods/master/&lt;spec>/&lt;spec>.podspec has the correct Github url in it.
   * If still doesn't work, check your XCode build locations settings. Go to Preferences -> Locations -> Derived Data -> Advanced and set build location to "Relative to Workspace".

   ![Xcode build location settings](https://img.skitch.com/20120426-chmda3m5suhcfrhjge6brjhesk.png)

5. If you tried to submit app to App Store, and found that "Product" > "Archive" produces nothing in "Organizer":
    * In Xcode "Build Settings", find "Skip Install". Set the value for "Release" to "NO" on your application target. Build again and it should work. 

_Different Xcode versions can have various problems. Ask for help and tell us what version you're using._

[creating-a-workspace]: http://blog.carbonfive.com/2011/04/04/using-open-source-static-libraries-in-xcode-4/#creating_a_workspace
[adding-projects-to-workspace]: http://blog.carbonfive.com/2011/04/04/using-open-source-static-libraries-in-xcode-4/#adding_projects_to_a_workspace
[configuring-project-scheme]: http://blog.carbonfive.com/2011/04/04/using-open-source-static-libraries-in-xcode-4/#configuring_the_projects_scheme
[adding-build-target-dependencies]: http://blog.carbonfive.com/2011/04/04/using-open-source-static-libraries-in-xcode-4/#adding_build_target_dependencies
[basing-target-configurations-on-xcconfig]: http://developer.apple.com/library/ios/#documentation/ToolsLanguages/Conceptual/Xcode4UserGuide/025-Configure_Your_Project/configure_project.html
[installing-cocoapods]: installing_cocoapods.html
[podfile]: /podfile.html