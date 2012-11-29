# TODO

- Currently there is a lot of duplication and the common parts should be extracted in partials.
  - Use slim templates?

### Specification DSL

 - `header_dir` and `header_mappings_dir` needs proper explanation.
 - `requires_arc` should default to true
 - Inheritance and merge polices should be explained.
   - When a subspec inherits an attribute as first defined?
   - When a subspec inherits an attribute by merging?
   - When a platform value is merged with the general one and when it replaces it?

### Gem

- The files for some namespaces are not being generated.
- Exclude inherited methods from the overview.
- Add Constants and Class methods.
