# frozen_string_literal: true

class JsonbSerializer
  def self.dump(hash)
    hash&.as_json
  end

  def self.load(hash)
    return hash if hash.is_a?(Array)

    (hash || {}).with_indifferent_access
  end
end
