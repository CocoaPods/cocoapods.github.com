## CocoaPods Philosophy

### Goal

CocoaPods' goal is to improve discoverability of, and engagement in, third party
open-source libraries, by creating a more centralized ecosystem.

### Common Misconceptions

#### 1. “CocoaPods is not ready for prime-time yet.”

Correct. Version 1.0.0 will be the milestone where we feel confident that all
the basic requirements of an Objective-C dependency manager are fulfilled.

Once we reach the 1.0.0 milestone, we will, for the first time ever, contact
the community at large through mailing-lists such as cocoa-dev.

#### 2. “CocoaPods doesn’t do X, so it’s unusable.”

First see point #1, then consider that unless you tell us about the missing
feature and why it is important, it won’t happen at all. We don’t scour Twitter
to look for work, so please file a
[ticket](https://github.com/CocoaPods/CocoaPods/issues/new), or, better yet, start a pull-request.

#### 3. “CocoaPods doesn’t do dependency resolution.”

CocoaPods does in fact do dependency resolution, but it does not automatically
resolve conflicts. This means that when a conflict occurs, CocoaPods will
raise an error and leave conflict resolving up to the user. (The user can do
this by depending on a specific version of a common dependency _before_
requiring the dependencies that lead to the conflict.)

If you’re familiar with Ruby then you can compare the former (the current
CocoaPods style) to RubyGems’ style resolution and the latter (with conflict
resolving) to Bundler’s.

Adding conflict resolution to CocoaPods is on our TODO list and we will try to
work with the Bundler team to see if we can share their algorithm, but this
will be one of the last things we’ll work on. A feature like this will require
a stable basis and since we’re not there yet, working on it now would only make
working on the basics more complex than necessary.

Finally, while conflict resolving is a definite must-have, you should ask
yourself if you’re not using too many dependencies whenever you run into
conflicts, as this is in general a good indicator. See the link to a blog post
about this in #4.


#### 4. “CocoaPods is bad for the community, because it makes it too easy for users to add many dependencies.”

This is akin to saying “guns kill people”, but everybody knows it’s really
people who kill people (and [psychotic bears with
machetes](http://www.sebastienmillon.com/Machete-Bear-Art-Print-15-00)).
Furthermore, this reasoning applies to basically any means of fetching code
(e.g. git) and as such is not a discussion worth having.

What _is_ worth discussing, however, is informing the user to be responsible.
Ironically enough, the original author of CocoaPods is convinced using a lot of
dependencies is a really bad idea. For practical advice on how to deal with
this, you should read [this blog post](http://www.fngtps.com/2013/a-quick-note-on-minimal-dependencies-in-ruby-on-rails/)
by [Manfred Stienstra](http://twitter.com/manfreds).


#### 5. “CocoaPods uses workspaces, which are considered user data. Why does it not use normal sub-projects?”

Starting from Xcode 4, [Apple introduced workspaces for this very
purpose](http://developer.apple.com/library/ios/#featuredarticles/XcodeConcepts/Concept-Workspace.html).

Since then, they have also added workspace files to each xcodeproj document,
leading people to believe that a workspace is user data only. This is simply
incorrect and you should **not** ignore workspace documents any longer if you
were doing so.

Note that CocoaPods itself does not require the use of a workspace. If you
prefer to use sub-projects, you can do so by running `pod install
--no-integrate`, which will leave integration into your project up to you as
you see fit.
