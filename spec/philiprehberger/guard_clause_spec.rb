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
