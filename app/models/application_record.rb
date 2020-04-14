# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.[](code)
    @cached ||= {}
    @cached[code] ||= readonly.find_by(code: code)
  end

  def self.reset_cache
    @cached = {}
  end

  def self.view_attrs
    @view_attrs ||= attribute_names.map(&:to_s) - %w[id created_at updated_at]
  end
end
