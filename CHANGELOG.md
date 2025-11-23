# Changelog

## v0.2.0

- Enhancement
  - Supports `@idoc` attribute definition prior to a private function definition.
  - The doc written with the `@idoc` attribute is fetched and rendered in the UI the same way docs generated using ExDoc are rendered.

## v0.1.4

- Bug Fix
  - Allow clicking on the documentation icon in the functions column to open function doc
- Enhancement
  - Support Umbrella projects

## v0.1.3

- Bug Fix
    - Use `ex_doc` only in `dev` env to avoid dependency conflicts.

## v0.1.2

- Enhancements
    - Show iris GUI in generated documentation with `iris.docs` task
- Bug Fixes
    - Fix nil mod_name error when mod_name doesn't contain Elixir prefix

## v0.1.1

- Enhancements
    - Sort functions alphabetically
    - Elixir 1.19 readiness changes
    - Create iris directory if it doesn't already exist

## v0.1.0

First public release