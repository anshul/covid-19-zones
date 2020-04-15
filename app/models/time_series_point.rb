# frozen_string_literal: true

class TimeSeriesPoint < ApplicationRecord
  def zero?
    announced.zero? && recovered.zero? && deceased.zero?
  end
end
