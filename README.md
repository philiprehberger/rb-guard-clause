# philiprehberger-guard_clause

[![Tests](https://github.com/philiprehberger/rb-guard-clause/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-guard-clause/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-guard_clause.svg)](https://rubygems.org/gems/philiprehberger-guard_clause)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-guard-clause)](https://github.com/philiprehberger/rb-guard-clause/commits/main)

Expressive guard clause DSL for method precondition validation

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-guard_clause"
```

Or install directly:

```bash
gem install philiprehberger-guard_clause
```

## Usage

```ruby
require "philiprehberger/guard_clause"

Philiprehberger::GuardClause.guard(name).not_nil('name is required').not_empty
Philiprehberger::GuardClause.guard(age).not_nil.positive.gte(18)
```

### Chaining Guards

```ruby
Philiprehberger::GuardClause.guard(price)
  .not_nil('price is required')
  .positive('price must be positive')
  .lte(10_000, 'price exceeds maximum')
```

### Regex Matching

```ruby
Philiprehberger::GuardClause.guard(email).matches(/@/, 'invalid email format')
```

### Inclusion Check

```ruby
Philiprehberger::GuardClause.guard(role).one_of(%i[admin user guest], 'invalid role')
```

### Soft Mode

Collect all errors without raising:

```ruby
guard = Philiprehberger::GuardClause.guard(value, soft: true)
guard.not_nil.not_empty.positive

guard.valid?   # => false
guard.errors   # => ['value must not be empty', 'value must be positive']
```

## API

| Method | Description |
|--------|-------------|
| `GuardClause.guard(value, soft: false)` | Create a guard for the given value |
| `#not_nil(msg)` | Assert value is not nil |
| `#not_empty(msg)` | Assert value is not empty |
| `#positive(msg)` | Assert value is positive |
| `#gte(n, msg)` | Assert value >= n |
| `#lte(n, msg)` | Assert value <= n |
| `#matches(regex, msg)` | Assert value matches pattern |
| `#one_of(arr, msg)` | Assert value is in the list |
| `#not_equal(other, msg)` | Assert value differs from other |
| `#value` | Return the guarded value |
| `#valid?` | Return true if no errors (soft mode) |
| `#errors` | Return collected errors (soft mode) |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-guard-clause)

🐛 [Report issues](https://github.com/philiprehberger/rb-guard-clause/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-guard-clause/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
