# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::GuardClause do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
  end

  describe '.guard' do
    it 'returns a Guard instance' do
      result = described_class.guard('hello')
      expect(result).to be_a(described_class::Guard)
    end
  end

  describe Philiprehberger::GuardClause::Guard do
    describe '#not_nil' do
      it 'passes for non-nil values' do
        guard = Philiprehberger::GuardClause.guard('hello')
        expect { guard.not_nil }.not_to raise_error
      end

      it 'raises for nil values' do
        guard = Philiprehberger::GuardClause.guard(nil)
        expect { guard.not_nil }.to raise_error(Philiprehberger::GuardClause::Error, 'value must not be nil')
      end

      it 'uses a custom message' do
        guard = Philiprehberger::GuardClause.guard(nil)
        expect do
          guard.not_nil('name is required')
        end.to raise_error(Philiprehberger::GuardClause::Error, 'name is required')
      end
    end

    describe '#not_empty' do
      it 'passes for non-empty values' do
        guard = Philiprehberger::GuardClause.guard('hello')
        expect { guard.not_empty }.not_to raise_error
      end

      it 'raises for empty strings' do
        guard = Philiprehberger::GuardClause.guard('')
        expect { guard.not_empty }.to raise_error(Philiprehberger::GuardClause::Error, 'value must not be empty')
      end

      it 'raises for empty arrays' do
        guard = Philiprehberger::GuardClause.guard([])
        expect { guard.not_empty }.to raise_error(Philiprehberger::GuardClause::Error)
      end
    end

    describe '#positive' do
      it 'passes for positive numbers' do
        guard = Philiprehberger::GuardClause.guard(5)
        expect { guard.positive }.not_to raise_error
      end

      it 'raises for zero' do
        guard = Philiprehberger::GuardClause.guard(0)
        expect { guard.positive }.to raise_error(Philiprehberger::GuardClause::Error, 'value must be positive')
      end

      it 'raises for negative numbers' do
        guard = Philiprehberger::GuardClause.guard(-1)
        expect { guard.positive }.to raise_error(Philiprehberger::GuardClause::Error)
      end
    end

    describe '#gte' do
      it 'passes when value is greater than or equal' do
        guard = Philiprehberger::GuardClause.guard(10)
        expect { guard.gte(5) }.not_to raise_error
      end

      it 'passes when value equals the bound' do
        guard = Philiprehberger::GuardClause.guard(5)
        expect { guard.gte(5) }.not_to raise_error
      end

      it 'raises when value is less than bound' do
        guard = Philiprehberger::GuardClause.guard(3)
        expect { guard.gte(5) }.to raise_error(Philiprehberger::GuardClause::Error)
      end
    end

    describe '#lte' do
      it 'passes when value is less than or equal' do
        guard = Philiprehberger::GuardClause.guard(3)
        expect { guard.lte(5) }.not_to raise_error
      end

      it 'passes when value equals the bound' do
        guard = Philiprehberger::GuardClause.guard(5)
        expect { guard.lte(5) }.not_to raise_error
      end

      it 'raises when value is greater than bound' do
        guard = Philiprehberger::GuardClause.guard(10)
        expect { guard.lte(5) }.to raise_error(Philiprehberger::GuardClause::Error)
      end
    end

    describe '#matches' do
      it 'passes when value matches the regex' do
        guard = Philiprehberger::GuardClause.guard('hello@example.com')
        expect { guard.matches(/@/) }.not_to raise_error
      end

      it 'raises when value does not match' do
        guard = Philiprehberger::GuardClause.guard('invalid')
        expect { guard.matches(/@/) }.to raise_error(Philiprehberger::GuardClause::Error)
      end
    end

    describe '#one_of' do
      it 'passes when value is in the list' do
        guard = Philiprehberger::GuardClause.guard(:admin)
        expect { guard.one_of(%i[admin user guest]) }.not_to raise_error
      end

      it 'raises when value is not in the list' do
        guard = Philiprehberger::GuardClause.guard(:superadmin)
        expect { guard.one_of(%i[admin user guest]) }.to raise_error(Philiprehberger::GuardClause::Error)
      end
    end

    describe '#not_equal' do
      it 'passes when values differ' do
        guard = Philiprehberger::GuardClause.guard(5)
        expect { guard.not_equal(10) }.not_to raise_error
      end

      it 'raises when values are equal' do
        guard = Philiprehberger::GuardClause.guard(5)
        expect { guard.not_equal(5) }.to raise_error(Philiprehberger::GuardClause::Error)
      end
    end

    describe 'chaining' do
      it 'allows multiple checks' do
        guard = Philiprehberger::GuardClause.guard(10)
        expect { guard.not_nil.positive.gte(5).lte(20) }.not_to raise_error
      end

      it 'raises on first failing check' do
        guard = Philiprehberger::GuardClause.guard(-1)
        expect do
          guard.not_nil.positive.gte(5)
        end.to raise_error(Philiprehberger::GuardClause::Error, 'value must be positive')
      end
    end

    describe 'soft mode' do
      it 'collects errors instead of raising' do
        guard = Philiprehberger::GuardClause.guard('', soft: true)
        guard.not_empty.not_nil
        expect(guard.valid?).to be(false)
        expect(guard.errors).to include('value must not be empty')
      end

      it 'reports valid when no errors' do
        guard = Philiprehberger::GuardClause.guard('hello', soft: true)
        guard.not_nil.not_empty
        expect(guard.valid?).to be(true)
        expect(guard.errors).to be_empty
      end

      it 'collects multiple errors' do
        guard = Philiprehberger::GuardClause.guard(-5, soft: true)
        guard.positive.gte(0).lte(-10)
        expect(guard.errors.length).to eq(3)
      end
    end

    describe '#value' do
      it 'returns the original value' do
        guard = Philiprehberger::GuardClause.guard(42)
        expect(guard.value).to eq(42)
      end
    end

    describe 'nil input to each guard type' do
      it 'not_nil raises for nil' do
        guard = Philiprehberger::GuardClause.guard(nil)
        expect { guard.not_nil }.to raise_error(Philiprehberger::GuardClause::Error)
      end

      it 'not_empty passes for nil (no empty? method)' do
        guard = Philiprehberger::GuardClause.guard(nil)
        expect { guard.not_empty }.not_to raise_error
      end

      it 'positive does not raise for nil (no > method)' do
        guard = Philiprehberger::GuardClause.guard(nil)
        expect { guard.positive }.not_to raise_error
      end

      it 'gte does not raise for nil (no >= method)' do
        guard = Philiprehberger::GuardClause.guard(nil)
        expect { guard.gte(0) }.not_to raise_error
      end

      it 'lte does not raise for nil (no <= method)' do
        guard = Philiprehberger::GuardClause.guard(nil)
        expect { guard.lte(0) }.not_to raise_error
      end

      it 'matches converts nil to string' do
        guard = Philiprehberger::GuardClause.guard(nil)
        expect { guard.matches(/\d/) }.to raise_error(Philiprehberger::GuardClause::Error)
      end

      it 'one_of raises when nil is not in the list' do
        guard = Philiprehberger::GuardClause.guard(nil)
        expect { guard.one_of(%i[a b]) }.to raise_error(Philiprehberger::GuardClause::Error)
      end

      it 'not_equal passes when nil != other' do
        guard = Philiprehberger::GuardClause.guard(nil)
        expect { guard.not_equal(5) }.not_to raise_error
      end
    end

    describe 'custom error messages on all guards' do
      it 'not_empty with custom message' do
        guard = Philiprehberger::GuardClause.guard('')
        expect do
          guard.not_empty('cannot be blank')
        end.to raise_error(Philiprehberger::GuardClause::Error, 'cannot be blank')
      end

      it 'positive with custom message' do
        guard = Philiprehberger::GuardClause.guard(-1)
        expect { guard.positive('must be > 0') }.to raise_error(Philiprehberger::GuardClause::Error, 'must be > 0')
      end

      it 'gte with custom message' do
        guard = Philiprehberger::GuardClause.guard(1)
        expect { guard.gte(5, 'too small') }.to raise_error(Philiprehberger::GuardClause::Error, 'too small')
      end

      it 'lte with custom message' do
        guard = Philiprehberger::GuardClause.guard(10)
        expect { guard.lte(5, 'too large') }.to raise_error(Philiprehberger::GuardClause::Error, 'too large')
      end

      it 'matches with custom message' do
        guard = Philiprehberger::GuardClause.guard('abc')
        expect { guard.matches(/\d/, 'need digits') }.to raise_error(Philiprehberger::GuardClause::Error, 'need digits')
      end

      it 'one_of with custom message' do
        guard = Philiprehberger::GuardClause.guard(:x)
        expect do
          guard.one_of(%i[a b], 'invalid option')
        end.to raise_error(Philiprehberger::GuardClause::Error, 'invalid option')
      end

      it 'not_equal with custom message' do
        guard = Philiprehberger::GuardClause.guard(5)
        expect { guard.not_equal(5, 'must differ') }.to raise_error(Philiprehberger::GuardClause::Error, 'must differ')
      end
    end

    describe 'chained guards with many checks' do
      it 'passes all chained validations' do
        guard = Philiprehberger::GuardClause.guard(10)
        expect { guard.not_nil.positive.gte(1).lte(100).not_equal(0) }.not_to raise_error
      end

      it 'fails at the correct point in the chain' do
        guard = Philiprehberger::GuardClause.guard(0)
        expect { guard.not_nil.positive }.to raise_error(Philiprehberger::GuardClause::Error, 'value must be positive')
      end
    end

    describe 'soft mode with all guard types' do
      it 'collects errors from matches and one_of' do
        guard = Philiprehberger::GuardClause.guard('xyz', soft: true)
        guard.matches(/\d/).one_of(%w[a b c])
        expect(guard.errors.length).to eq(2)
        expect(guard.valid?).to be false
      end

      it 'collects error from not_equal' do
        guard = Philiprehberger::GuardClause.guard(5, soft: true)
        guard.not_equal(5)
        expect(guard.errors.length).to eq(1)
      end
    end

    describe '#is_a' do
      it 'passes when value matches the type' do
        guard = Philiprehberger::GuardClause.guard('hello')
        expect { guard.is_a(String) }.not_to raise_error
      end

      it 'passes for subclass instances' do
        guard = Philiprehberger::GuardClause.guard(42)
        expect { guard.is_a(Numeric) }.not_to raise_error
      end

      it 'raises when value does not match the type' do
        guard = Philiprehberger::GuardClause.guard('hello')
        expect { guard.is_a(Integer) }.to raise_error(Philiprehberger::GuardClause::Error, 'value must be a Integer')
      end

      it 'raises for nil when checking a type' do
        guard = Philiprehberger::GuardClause.guard(nil)
        expect { guard.is_a(String) }.to raise_error(Philiprehberger::GuardClause::Error)
      end

      it 'uses a custom message' do
        guard = Philiprehberger::GuardClause.guard('hello')
        expect do
          guard.is_a(Integer, message: 'expected an integer')
        end.to raise_error(Philiprehberger::GuardClause::Error, 'expected an integer')
      end
    end

    describe '#between' do
      it 'passes when value is within range' do
        guard = Philiprehberger::GuardClause.guard(5)
        expect { guard.between(1, 10) }.not_to raise_error
      end

      it 'passes when value equals min' do
        guard = Philiprehberger::GuardClause.guard(1)
        expect { guard.between(1, 10) }.not_to raise_error
      end

      it 'passes when value equals max' do
        guard = Philiprehberger::GuardClause.guard(10)
        expect { guard.between(1, 10) }.not_to raise_error
      end

      it 'raises when value is below range' do
        guard = Philiprehberger::GuardClause.guard(0)
        expect { guard.between(1, 10) }.to raise_error(Philiprehberger::GuardClause::Error, 'value must be between 1 and 10')
      end

      it 'raises when value is above range' do
        guard = Philiprehberger::GuardClause.guard(11)
        expect { guard.between(1, 10) }.to raise_error(Philiprehberger::GuardClause::Error)
      end

      it 'does not raise for nil (no < method)' do
        guard = Philiprehberger::GuardClause.guard(nil)
        expect { guard.between(1, 10) }.not_to raise_error
      end

      it 'uses a custom message' do
        guard = Philiprehberger::GuardClause.guard(0)
        expect do
          guard.between(1, 10, message: 'out of range')
        end.to raise_error(Philiprehberger::GuardClause::Error, 'out of range')
      end
    end

    describe '#min_length' do
      it 'passes when string length meets minimum' do
        guard = Philiprehberger::GuardClause.guard('hello')
        expect { guard.min_length(3) }.not_to raise_error
      end

      it 'passes when length equals minimum' do
        guard = Philiprehberger::GuardClause.guard('abc')
        expect { guard.min_length(3) }.not_to raise_error
      end

      it 'raises when string is too short' do
        guard = Philiprehberger::GuardClause.guard('ab')
        expect { guard.min_length(3) }.to raise_error(Philiprehberger::GuardClause::Error, 'value must have a minimum length of 3')
      end

      it 'works with arrays' do
        guard = Philiprehberger::GuardClause.guard([1])
        expect { guard.min_length(2) }.to raise_error(Philiprehberger::GuardClause::Error)
      end

      it 'does not raise for nil (no length method)' do
        guard = Philiprehberger::GuardClause.guard(nil)
        expect { guard.min_length(1) }.not_to raise_error
      end

      it 'uses a custom message' do
        guard = Philiprehberger::GuardClause.guard('a')
        expect do
          guard.min_length(5, message: 'too short')
        end.to raise_error(Philiprehberger::GuardClause::Error, 'too short')
      end
    end

    describe '#max_length' do
      it 'passes when string length is within maximum' do
        guard = Philiprehberger::GuardClause.guard('hi')
        expect { guard.max_length(5) }.not_to raise_error
      end

      it 'passes when length equals maximum' do
        guard = Philiprehberger::GuardClause.guard('hello')
        expect { guard.max_length(5) }.not_to raise_error
      end

      it 'raises when string is too long' do
        guard = Philiprehberger::GuardClause.guard('hello world')
        expect { guard.max_length(5) }.to raise_error(Philiprehberger::GuardClause::Error, 'value must have a maximum length of 5')
      end

      it 'works with arrays' do
        guard = Philiprehberger::GuardClause.guard([1, 2, 3])
        expect { guard.max_length(2) }.to raise_error(Philiprehberger::GuardClause::Error)
      end

      it 'does not raise for nil (no length method)' do
        guard = Philiprehberger::GuardClause.guard(nil)
        expect { guard.max_length(5) }.not_to raise_error
      end

      it 'uses a custom message' do
        guard = Philiprehberger::GuardClause.guard('hello world')
        expect do
          guard.max_length(5, message: 'too long')
        end.to raise_error(Philiprehberger::GuardClause::Error, 'too long')
      end
    end

    describe '#satisfies' do
      it 'passes when predicate returns true' do
        guard = Philiprehberger::GuardClause.guard(4)
        expect { guard.satisfies(&:even?) }.not_to raise_error
      end

      it 'raises when predicate returns false' do
        guard = Philiprehberger::GuardClause.guard(3)
        expect do
          guard.satisfies(&:even?)
        end.to raise_error(Philiprehberger::GuardClause::Error, 'value does not satisfy the condition')
      end

      it 'raises when predicate returns nil' do
        guard = Philiprehberger::GuardClause.guard('test')
        expect { guard.satisfies { |_v| nil } }.to raise_error(Philiprehberger::GuardClause::Error)
      end

      it 'uses a custom message' do
        guard = Philiprehberger::GuardClause.guard(3)
        expect do
          guard.satisfies(message: 'must be even', &:even?)
        end.to raise_error(Philiprehberger::GuardClause::Error, 'must be even')
      end
    end

    describe '#starts_with' do
      it 'passes when string starts with prefix' do
        guard = Philiprehberger::GuardClause.guard('hello world')
        expect { guard.starts_with('hello') }.not_to raise_error
      end

      it 'raises when string does not start with prefix' do
        guard = Philiprehberger::GuardClause.guard('hello world')
        expect do
          guard.starts_with('world')
        end.to raise_error(Philiprehberger::GuardClause::Error, 'value must start with "world"')
      end

      it 'does not raise for non-string values (no start_with? method)' do
        guard = Philiprehberger::GuardClause.guard(123)
        expect { guard.starts_with('1') }.not_to raise_error
      end

      it 'does not raise for nil' do
        guard = Philiprehberger::GuardClause.guard(nil)
        expect { guard.starts_with('x') }.not_to raise_error
      end

      it 'uses a custom message' do
        guard = Philiprehberger::GuardClause.guard('hello')
        expect do
          guard.starts_with('world', message: 'wrong prefix')
        end.to raise_error(Philiprehberger::GuardClause::Error, 'wrong prefix')
      end
    end

    describe '#ends_with' do
      it 'passes when string ends with suffix' do
        guard = Philiprehberger::GuardClause.guard('hello world')
        expect { guard.ends_with('world') }.not_to raise_error
      end

      it 'raises when string does not end with suffix' do
        guard = Philiprehberger::GuardClause.guard('hello world')
        expect do
          guard.ends_with('hello')
        end.to raise_error(Philiprehberger::GuardClause::Error, 'value must end with "hello"')
      end

      it 'does not raise for non-string values (no end_with? method)' do
        guard = Philiprehberger::GuardClause.guard(123)
        expect { guard.ends_with('3') }.not_to raise_error
      end

      it 'does not raise for nil' do
        guard = Philiprehberger::GuardClause.guard(nil)
        expect { guard.ends_with('x') }.not_to raise_error
      end

      it 'uses a custom message' do
        guard = Philiprehberger::GuardClause.guard('hello')
        expect do
          guard.ends_with('world', message: 'wrong suffix')
        end.to raise_error(Philiprehberger::GuardClause::Error, 'wrong suffix')
      end
    end

    describe 'chaining new guards together' do
      it 'chains type check with range check' do
        guard = Philiprehberger::GuardClause.guard(5)
        expect { guard.is_a(Integer).between(1, 10) }.not_to raise_error
      end

      it 'chains string guards' do
        guard = Philiprehberger::GuardClause.guard('hello world')
        expect { guard.starts_with('hello').ends_with('world').min_length(5).max_length(20) }.not_to raise_error
      end

      it 'chains new guards with existing guards' do
        guard = Philiprehberger::GuardClause.guard(42)
        expect { guard.not_nil.is_a(Integer).positive.between(1, 100) }.not_to raise_error
      end

      it 'chains satisfies with other guards' do
        guard = Philiprehberger::GuardClause.guard(4)
        expect { guard.is_a(Integer).positive.satisfies(&:even?) }.not_to raise_error
      end
    end

    describe 'soft mode with new guards' do
      it 'collects errors from new guard types' do
        guard = Philiprehberger::GuardClause.guard('hi', soft: true)
        guard.is_a(Integer).min_length(5).starts_with('xyz').ends_with('abc')
        expect(guard.errors.length).to eq(4)
        expect(guard.valid?).to be false
      end

      it 'collects errors from between and satisfies' do
        guard = Philiprehberger::GuardClause.guard(50, soft: true)
        guard.between(1, 10).satisfies(message: 'must be even', &:odd?)
        expect(guard.errors.length).to eq(2)
      end

      it 'mixes old and new guards in soft mode' do
        guard = Philiprehberger::GuardClause.guard('', soft: true)
        guard.not_empty.min_length(3).starts_with('x')
        expect(guard.errors.length).to eq(3)
      end
    end

    describe '#present' do
      it 'passes for a non-empty string' do
        guard = Philiprehberger::GuardClause.guard('hello')
        expect { guard.present }.not_to raise_error
      end

      it 'raises for nil' do
        guard = Philiprehberger::GuardClause.guard(nil)
        expect { guard.present }.to raise_error(Philiprehberger::GuardClause::Error, 'value must be present')
      end

      it 'raises for empty string' do
        guard = Philiprehberger::GuardClause.guard('')
        expect { guard.present }.to raise_error(Philiprehberger::GuardClause::Error, 'value must be present')
      end

      it 'raises for whitespace-only string' do
        guard = Philiprehberger::GuardClause.guard('   ')
        expect { guard.present }.to raise_error(Philiprehberger::GuardClause::Error, 'value must be present')
      end

      it 'raises for tab and newline whitespace' do
        guard = Philiprehberger::GuardClause.guard("\t\n")
        expect { guard.present }.to raise_error(Philiprehberger::GuardClause::Error, 'value must be present')
      end

      it 'raises for empty array' do
        guard = Philiprehberger::GuardClause.guard([])
        expect { guard.present }.to raise_error(Philiprehberger::GuardClause::Error, 'value must be present')
      end

      it 'passes for non-empty array' do
        guard = Philiprehberger::GuardClause.guard([1])
        expect { guard.present }.not_to raise_error
      end

      it 'raises for empty hash' do
        guard = Philiprehberger::GuardClause.guard({})
        expect { guard.present }.to raise_error(Philiprehberger::GuardClause::Error, 'value must be present')
      end

      it 'passes for non-empty hash' do
        guard = Philiprehberger::GuardClause.guard({ a: 1 })
        expect { guard.present }.not_to raise_error
      end

      it 'passes for numeric values' do
        guard = Philiprehberger::GuardClause.guard(0)
        expect { guard.present }.not_to raise_error
      end

      it 'uses a custom message' do
        guard = Philiprehberger::GuardClause.guard(nil)
        expect do
          guard.present(message: 'name is required')
        end.to raise_error(Philiprehberger::GuardClause::Error, 'name is required')
      end

      it 'returns self for chaining' do
        guard = Philiprehberger::GuardClause.guard('hello')
        expect(guard.present).to eq(guard)
      end

      it 'works in soft mode' do
        guard = Philiprehberger::GuardClause.guard('  ', soft: true)
        guard.present
        expect(guard.valid?).to be false
        expect(guard.errors).to include('value must be present')
      end
    end

    describe '#format' do
      describe 'with Regexp' do
        it 'passes when value matches the pattern' do
          guard = Philiprehberger::GuardClause.guard('abc123')
          expect { guard.format(/\d+/) }.not_to raise_error
        end

        it 'raises when value does not match' do
          guard = Philiprehberger::GuardClause.guard('abc')
          expect { guard.format(/\d+/) }.to raise_error(Philiprehberger::GuardClause::Error)
        end

        it 'uses a custom message' do
          guard = Philiprehberger::GuardClause.guard('abc')
          expect do
            guard.format(/\d+/, message: 'must contain digits')
          end.to raise_error(Philiprehberger::GuardClause::Error, 'must contain digits')
        end
      end

      describe 'with :uuid pattern' do
        it 'passes for valid UUID v4' do
          guard = Philiprehberger::GuardClause.guard('550e8400-e29b-41d4-a716-446655440000')
          expect { guard.format(:uuid) }.not_to raise_error
        end

        it 'passes for uppercase UUID v4' do
          guard = Philiprehberger::GuardClause.guard('550E8400-E29B-41D4-A716-446655440000')
          expect { guard.format(:uuid) }.not_to raise_error
        end

        it 'raises for invalid UUID' do
          guard = Philiprehberger::GuardClause.guard('not-a-uuid')
          expect { guard.format(:uuid) }.to raise_error(Philiprehberger::GuardClause::Error)
        end

        it 'raises for UUID without version 4 marker' do
          guard = Philiprehberger::GuardClause.guard('550e8400-e29b-31d4-a716-446655440000')
          expect { guard.format(:uuid) }.to raise_error(Philiprehberger::GuardClause::Error)
        end

        it 'raises for UUID with invalid variant' do
          guard = Philiprehberger::GuardClause.guard('550e8400-e29b-41d4-c716-446655440000')
          expect { guard.format(:uuid) }.to raise_error(Philiprehberger::GuardClause::Error)
        end
      end

      describe 'with :email pattern' do
        it 'passes for valid email' do
          guard = Philiprehberger::GuardClause.guard('user@example.com')
          expect { guard.format(:email) }.not_to raise_error
        end

        it 'raises for email without @' do
          guard = Philiprehberger::GuardClause.guard('userexample.com')
          expect { guard.format(:email) }.to raise_error(Philiprehberger::GuardClause::Error)
        end

        it 'raises for email without domain' do
          guard = Philiprehberger::GuardClause.guard('user@')
          expect { guard.format(:email) }.to raise_error(Philiprehberger::GuardClause::Error)
        end

        it 'raises for email with spaces' do
          guard = Philiprehberger::GuardClause.guard('user @example.com')
          expect { guard.format(:email) }.to raise_error(Philiprehberger::GuardClause::Error)
        end

        it 'raises for empty string' do
          guard = Philiprehberger::GuardClause.guard('')
          expect { guard.format(:email) }.to raise_error(Philiprehberger::GuardClause::Error)
        end
      end

      describe 'with unknown pattern' do
        it 'raises ArgumentError for unknown symbol' do
          guard = Philiprehberger::GuardClause.guard('test')
          expect { guard.format(:unknown) }.to raise_error(ArgumentError, 'unknown built-in pattern: :unknown')
        end
      end

      it 'returns self for chaining' do
        guard = Philiprehberger::GuardClause.guard('user@example.com')
        expect(guard.format(:email)).to eq(guard)
      end

      it 'works in soft mode' do
        guard = Philiprehberger::GuardClause.guard('invalid', soft: true)
        guard.format(:email).format(:uuid)
        expect(guard.errors.length).to eq(2)
        expect(guard.valid?).to be false
      end

      it 'converts nil to string for matching' do
        guard = Philiprehberger::GuardClause.guard(nil)
        expect { guard.format(:email) }.to raise_error(Philiprehberger::GuardClause::Error)
      end

      it 'chains with present' do
        guard = Philiprehberger::GuardClause.guard('user@example.com')
        expect { guard.present.format(:email) }.not_to raise_error
      end
    end

    describe '#each' do
      it 'passes for a collection where all elements satisfy the block' do
        guard = Philiprehberger::GuardClause.guard([1, 2, 3])
        expect { guard.each { |g| g.positive('value must be positive') } }.not_to raise_error
      end

      it 'raises on the first element violation in hard mode' do
        guard = Philiprehberger::GuardClause.guard([1, -2, 3])
        expect { guard.each { |g| g.positive('value must be positive') } }
          .to raise_error(Philiprehberger::GuardClause::Error, 'value must be positive')
      end

      it 'collects all element errors in soft mode with index info' do
        guard = Philiprehberger::GuardClause.guard([-1, 2, -3], soft: true)
        guard.each { |g| g.positive('must be positive') }
        expect(guard.errors).to include('[0] must be positive')
        expect(guard.errors).to include('[2] must be positive')
        expect(guard.errors.length).to eq(2)
      end

      it 'collects no errors in soft mode when all elements pass' do
        guard = Philiprehberger::GuardClause.guard([1, 2, 3], soft: true)
        guard.each { |g| g.positive('value must be positive') }
        expect(guard.valid?).to be(true)
        expect(guard.errors).to be_empty
      end

      it 'passes for an empty collection without invoking the block' do
        guard = Philiprehberger::GuardClause.guard([])
        expect { guard.each { |g| g.positive('value must be positive') } }.not_to raise_error
      end

      it 'raises GuardClause::Error when value does not respond to each' do
        guard = Philiprehberger::GuardClause.guard(42)
        expect do
          guard.each { |g| g.positive('value must be positive') }
        end.to raise_error(Philiprehberger::GuardClause::Error, 'value must respond to each')
      end

      it 'returns self for chaining' do
        guard = Philiprehberger::GuardClause.guard([1, 2])
        result = guard.each { |g| g.positive('value must be positive') }
        expect(result).to eq(guard)
      end

      it 'chains after each' do
        guard = Philiprehberger::GuardClause.guard([1, 2, 3])
        expect { guard.not_empty.each { |g| g.positive('value must be positive') } }.not_to raise_error
      end
    end

    describe '#not_empty with hash' do
      it 'raises for empty hash' do
        guard = Philiprehberger::GuardClause.guard({})
        expect { guard.not_empty }.to raise_error(Philiprehberger::GuardClause::Error)
      end

      it 'passes for non-empty hash' do
        guard = Philiprehberger::GuardClause.guard({ a: 1 })
        expect { guard.not_empty }.not_to raise_error
      end
    end
  end
end
