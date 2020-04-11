# frozen_string_literal: true

module ActiveSupport
  class TestCase
    def better_inspect(object)
      object.inspect.gsub("'", "::BETTER_INSPECT_QUOTE::").tr('"', "'").gsub("::BETTER_INSPECT_QUOTE::", '"')
    end

    def hash_diff(hash1, hash2)
      Hash[Hashdiff.diff(hash1, hash2).map do |diff|
        type = diff[0]
        field = diff[1]
        from = type == "+" ? nil : better_inspect(diff[2])
        to = better_inspect(type == "+" ? diff[2] : diff[3])
        ["#{type} #{field}", "#{from} ---> #{to}"]
      end]
    end
  end
end
