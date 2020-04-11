# frozen_string_literal: true

module Minitest
  module Assertions
    def assert_subset(exp, act, msg = nil)
      exp.is_a?(Hash) ? assert_subset_hash(exp, act, msg) : assert_subset_array(exp, act, msg)
    end

    def assert_subset_hash(exp, act, msg = nil)
      assert_instance_of Hash, exp
      assert_instance_of Hash, act

      subset_act = act.slice(*exp.keys)
      assert_equal exp, subset_act, message(msg) { "Expected\n#{mu_pp(exp)}\n    to be a subset of\n\n#{mu_pp(act)}." }
    end

    def assert_subset_array(exp, act, msg = nil)
      diff = exp - act
      assert_empty diff, message(msg) { "Expected #{mu_pp(exp)} to be a subset of #{mu_pp(act)} but #{mu_pp(diff)} was missing." }
    end
  end
end
