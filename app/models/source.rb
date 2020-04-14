# frozen_string_literal: true

class Source < ApplicationRecord
  def self.slug_for(uid)
    "covid19-india-#{uid}"
  end

  def self.code_for(uid)
    "c19-in-#{uid}"
  end
end
