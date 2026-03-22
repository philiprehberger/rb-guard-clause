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
        if @value.nil?
          handle_violation(message || 'value must not be nil')
        end
        self
      end

      # Assert the value is not empty
      #
      # @param message [String] custom error message
      # @return [Guard] self for chaining
      def not_empty(message = nil)
        if @value.respond_to?(:empty?) && @value.empty?
          handle_violation(message || 'value must not be empty')
        end
        self
      end

      # Assert the value is positive
      #
      # @param message [String] custom error message
      # @return [Guard] self for chaining
      def positive(message = nil)
        if @value.respond_to?(:>) && !(@value > 0)
          handle_violation(message || 'value must be positive')
        end
        self
      end

      # Assert the value is greater than or equal to n
      #
      # @param n [Numeric] the minimum value
      # @param message [String] custom error message
      # @return [Guard] self for chaining
      def gte(n, message = nil)
        if @value.respond_to?(:>=) && !(@value >= n)
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
        if @value.respond_to?(:<=) && !(@value <= n)
          handle_violation(message || "value must be less than or equal to #{n}")
        end
        self
      end

      # Assert the value matches a regex pattern
      #
      # @param regex [Regexp] the pattern to match
      # @param message [String] custom error message
      # @return [Guard] self for chaining
      def matches(regex, message = nil)
        unless regex.match?(@value.to_s)
          handle_violation(message || "value must match #{regex.inspect}")
        end
        self
      end

      # Assert the value is one of the given options
      #
      # @param arr [Array] the allowed values
      # @param message [String] custom error message
      # @return [Guard] self for chaining
      def one_of(arr, message = nil)
        unless arr.include?(@value)
          handle_violation(message || "value must be one of #{arr.inspect}")
        end
        self
      end

      # Assert the value is not equal to another value
      #
      # @param other [Object] the value to compare against
      # @param message [String] custom error message
      # @return [Guard] self for chaining
      def not_equal(other, message = nil)
        if @value == other
          handle_violation(message || "value must not be equal to #{other.inspect}")
        end
        self
      end

      private

      # @param message [String] the violation message
      def handle_violation(message)
        if @soft
          @errors << message
        else
          raise GuardClause::Error, message
        end
      end
    end
  end
end
