## Making a Podspec for a closed source projects

If your company releases a closed source library for iOS or OS X, you can still create a Podspec for them using the standard Podspec DSL.

### Bundles

Bundles are handled like any other resource:

	s.resource = 'BundleName.bundle'

### Frameworks

	s.frameworks 	 = 'FrameworkName'
	s.xcconfig       = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/FrameworkName"' }
	s.preserve_paths = 'FrameworkName.framework'
	s.source_files 	 = 'FrameworkName.framework/Headers/*.{h}'

### Libraries

	s.library         = 'LibraryName'
	s.xcconfig        =  { 'LIBRARY_SEARCH_PATHS' => '$(PODS_ROOT)/LibraryName' }
	s.preserve_paths  = 'LibraryName.a'