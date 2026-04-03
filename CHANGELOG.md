# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-04-03

### Added
- Type checking guard via `is_a`
- Inclusive range guard via `between`
- Length guards via `min_length` and `max_length`
- Custom predicate guard via `satisfies`
- String prefix and suffix guards via `starts_with` and `ends_with`

## [0.1.5] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.1.4] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.1.3] - 2026-03-24

### Fixed
- Standardize README code examples to use double-quote require statements

## [0.1.2] - 2026-03-24

### Fixed
- Fix Installation section quote style to double quotes

## [0.1.1] - 2026-03-22

### Changed
- Expand test coverage to 51 examples

## [0.1.0] - 2026-03-22

### Added
- Initial release
- Chainable guard clause DSL with not_nil, not_empty, positive, gte, lte checks
- Regex matching and inclusion validation via matches and one_of
- Inequality check via not_equal
- Soft mode for collecting errors instead of raising
