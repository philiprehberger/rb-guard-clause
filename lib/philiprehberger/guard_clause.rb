# frozen_string_literal: true

require_relative 'guard_clause/version'
require_relative 'guard_clause/guard'

module Philiprehberger
  module GuardClause
    class Error < StandardError; end

    # Create a guard for the given value
    #
    # @param value [Object] the value to guard
    # @param soft [Boolean] when true, collect errors instead of raising
    # @return [Guard] the guard object
    def self.guard(value, soft: false)
      Guard.new(value, soft: soft)
    end
  end
end
