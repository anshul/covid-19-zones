# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.[](code)
    @cached ||= {}
    @cached[code] ||= readonly.find_by(code: code)
  end

  def self.clear_cache
    @cached = {}
    true
  end

  def self.view_attrs
    @view_attrs ||= attribute_names.map(&:to_s) - %w[id created_at updated_at]
  end

  def self.rw_attribute_names
    @rw_attribute_names ||= (attribute_names.map(&:to_s) - %w[id created_at updated_at])
  end

  def self.rw_attribute_names_sym
    @rw_attribute_names_sym ||= rw_attribute_names.map(&:to_sym)
  end

  def self.on_duplicate_key_options
    { conflict_target: %i[code], columns: (attribute_names - %w[id created_at updated_at]) }
  end

  def self.default_model
    new
  end

  def error_message
    errors.full_messages.to_sentence.gsub(";,", ";").gsub(".,", ",")
  end
end
