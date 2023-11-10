# frozen_string_literal: true

module Philiprehberger
  module GuardClause
    # Guard object that performs validation checks on a value
    class Guard
      # @param value [Object] the value to guard
      # @param soft [Boolean] when true, collect errors instead of raising
      def initialize(value, soft: false)
        @value = value
        @soft = soft
        @errors = []
      end

      # @return [Object] the guarded value
      attr_reader :value

      # @return [Array<String>] collected errors (soft mode only)
      attr_reader :errors

      # @return [Boolean] true if no errors were collected
      def valid?
        @errors.empty?
      end

      # Assert the value is not nil
      #
      # @param message [String] custom error message
      # @return [Guard] self for chaining
      def not_nil(message = nil)
        handle_violation(message || 'value must not be nil') if @value.nil?
        self
      end

      # Assert the value is not empty
      #
      # @param message [String] custom error message
      # @return [Guard] self for chaining
      def not_empty(message = nil)
        handle_violation(message || 'value must not be empty') if @value.respond_to?(:empty?) && @value.empty?
        self
      end

      # Assert the value is positive
      #
      # @param message [String] custom error message
      # @return [Guard] self for chaining
      def positive(message = nil)
        handle_violation(message || 'value must be positive') if @value.respond_to?(:>) && @value <= 0
        self
      end

      # Assert the value is greater than or equal to n
      #
      # @param n [Numeric] the minimum value
      # @param message [String] custom error message
      # @return [Guard] self for chaining
      def gte(n, message = nil)
        if @value.respond_to?(:>=) && @value < n
          handle_violation(message || "value must be greater than or equal to #{n}")
        end
        self
      end

      # Assert the value is less than or equal to n
      #
      # @param n [Numeric] the maximum value
      # @param message [String] custom error message
      # @return [Guard] self for chaining
      def lte(n, message = nil)
        handle_violation(message || "value must be less than or equal to #{n}") if @value.respond_to?(:<=) && @value > n
        self
      end

      # Assert the value matches a regex pattern
      #
      # @param regex [Regexp] the pattern to match
      # @param message [String] custom error message
      # @return [Guard] self for chaining
      def matches(regex, message = nil)
        handle_violation(message || "value must match #{regex.inspect}") unless regex.match?(@value.to_s)
        self
      end

      # Assert the value is one of the given options
      #
      # @param arr [Array] the allowed values
      # @param message [String] custom error message
      # @return [Guard] self for chaining
      def one_of(arr, message = nil)
        handle_violation(message || "value must be one of #{arr.inspect}") unless arr.include?(@value)
        self
      end

      # Assert the value is not equal to another value
      #
      # @param other [Object] the value to compare against
      # @param message [String] custom error message
      # @return [Guard] self for chaining
      def not_equal(other, message = nil)
        handle_violation(message || "value must not be equal to #{other.inspect}") if @value == other
        self
      end

      # Assert the value is an instance of the given type
      #
      # @param type [Class] the expected type
      # @param message [String] custom error message
      # @return [Guard] self for chaining
      def is_a(type, message: nil)
        handle_violation(message || "value must be a #{type}") unless @value.is_a?(type)
        self
      end

      # Assert the value is between min and max (inclusive)
      #
      # @param min [Comparable] the minimum bound
      # @param max [Comparable] the maximum bound
      # @param message [String] custom error message
      # @return [Guard] self for chaining
      def between(min, max, message: nil)
        if @value.respond_to?(:<) && @value.respond_to?(:>) && (@value < min || @value > max)
          handle_violation(message || "value must be between #{min} and #{max}")
        end
        self
      end

      # Assert the value has a minimum length
      #
      # @param n [Integer] the minimum length
      # @param message [String] custom error message
      # @return [Guard] self for chaining
      def min_length(n, message: nil)
        if @value.respond_to?(:length) && @value.length < n
          handle_violation(message || "value must have a minimum length of #{n}")
        end
        self
      end

      # Assert the value has a maximum length
      #
      # @param n [Integer] the maximum length
      # @param message [String] custom error message
      # @return [Guard] self for chaining
      def max_length(n, message: nil)
        if @value.respond_to?(:length) && @value.length > n
          handle_violation(message || "value must have a maximum length of #{n}")
        end
        self
      end

      # Assert the value satisfies a custom predicate
      #
      # @param message [String] custom error message
      # @param block [Proc] the predicate block
      # @return [Guard] self for chaining
      def satisfies(message: nil, &block)
        handle_violation(message || 'value does not satisfy the condition') unless block.call(@value)
        self
      end

      # Assert the value starts with the given prefix
      #
      # @param prefix [String] the expected prefix
      # @param message [String] custom error message
      # @return [Guard] self for chaining
      def starts_with(prefix, message: nil)
        if @value.respond_to?(:start_with?) && !@value.start_with?(prefix)
          handle_violation(message || "value must start with #{prefix.inspect}")
        end
        self
      end

      # Assert the value ends with the given suffix
      #
      # @param suffix [String] the expected suffix
      # @param message [String] custom error message
      # @return [Guard] self for chaining
      def ends_with(suffix, message: nil)
        if @value.respond_to?(:end_with?) && !@value.end_with?(suffix)
          handle_violation(message || "value must end with #{suffix.inspect}")
        end
        self
      end

      private

      # @param message [String] the violation message
      def handle_violation(message)
        raise GuardClause::Error, message unless @soft

        @errors << message
      end
    end
  end
end
