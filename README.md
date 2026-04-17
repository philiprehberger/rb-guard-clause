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

### Type Checking

```ruby
Philiprehberger::GuardClause.guard(user).is_a(User, message: "expected a User instance")
Philiprehberger::GuardClause.guard(count).is_a(Integer)
```

### Range Check

```ruby
Philiprehberger::GuardClause.guard(age).between(18, 120, message: "age out of range")
```

### Length Guards

```ruby
Philiprehberger::GuardClause.guard(password).min_length(8, message: "password too short")
Philiprehberger::GuardClause.guard(username).max_length(20, message: "username too long")
```

### Custom Predicate

```ruby
Philiprehberger::GuardClause.guard(number).satisfies(message: "must be even") { |v| v.even? }
```

### Present Guard

Validates value is not nil, not empty, and not blank (whitespace-only strings):

```ruby
Philiprehberger::GuardClause.guard(name).present(message: "name is required")
Philiprehberger::GuardClause.guard(tags).present(message: "tags must not be empty")
```

### Format Validation

Validates value matches a pattern (Regexp or built-in symbol):

```ruby
Philiprehberger::GuardClause.guard(id).format(:uuid, message: "must be a valid UUID")
Philiprehberger::GuardClause.guard(email).format(:email, message: "invalid email")
Philiprehberger::GuardClause.guard(code).format(/\A[A-Z]{3}\z/, message: "must be 3 uppercase letters")
```

Built-in patterns: `:uuid` (UUID v4), `:email` (basic email format).

### String Prefix and Suffix

```ruby
Philiprehberger::GuardClause.guard(url).starts_with("https://", message: "must be HTTPS")
Philiprehberger::GuardClause.guard(filename).ends_with(".rb", message: "must be a Ruby file")
```

### Collection Element Guard

Iterate over a collection and validate each element with a nested guard:

```ruby
Philiprehberger::GuardClause.guard([1, 2, 3])
  .each { |g| g.positive('must be positive') }
```

In soft mode, errors are collected with the element index prepended:

```ruby
guard = Philiprehberger::GuardClause.guard([-1, 2, -3], soft: true)
guard.each { |g| g.positive('must be positive') }
guard.errors # => ['[0] must be positive', '[2] must be positive']
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
| `#is_a(type, message:)` | Assert value is an instance of type |
| `#between(min, max, message:)` | Assert value is within inclusive range |
| `#min_length(n, message:)` | Assert value length >= n |
| `#max_length(n, message:)` | Assert value length <= n |
| `#satisfies(message:, &block)` | Assert custom predicate returns truthy |
| `#starts_with(prefix, message:)` | Assert string starts with prefix |
| `#ends_with(suffix, message:)` | Assert string ends with suffix |
| `#present(message:)` | Assert value is not nil, not empty, and not blank |
| `#format(pattern, message:)` | Assert value matches a Regexp or built-in pattern |
| `#each(&block)` | Iterate over collection elements, yielding a Guard for each |
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
