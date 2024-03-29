# frozen_string_literal: true

class BaseQuery
  include ActiveModel::Validations

  attr_reader :result

  def call_with_transaction
    ::ActiveRecord::Base.transaction(requires_new: true) do
      return true if call

      raise ::ActiveRecord::Rollback, "Aborting transaction: #{error_message}"
    end
    false
  end

  def call
    return errors.empty? if run

    errors.add(:base, "Something went wrong") if errors.empty?
    false
  end

  def call!
    return true if call_with_transaction

    errors.add(:base, "Something went wrong") if errors.empty?
    raise error_message
  end

  def run
    add_error("#{self.class}#run not implemented")
  end

  def error_message
    errors.full_messages.to_sentence.gsub(";,", ";").gsub(".,", ",")
  end

  def add_error(msg)
    errors.add(:base, msg)
    false
  end

  def puts_red(str)
    puts_colored :red, str
  end

  def puts_blue(str)
    puts_colored :blue, str
  end

  def puts_green(str)
    puts_colored :green, str
  end

  def puts_yellow(str)
    puts_colored :yellow, str
  end

  def puts_colored(color, str)
    color_code = {
      red:    31,
      green:  32,
      yellow: 33,
      blue:   34
    }[color.to_sym] || 35
    send(:puts, "\e[#{color_code}m#{str}\e[0m")
  end
end
