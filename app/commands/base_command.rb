# frozen_string_literal: true

class BaseCommand
  include ActiveModel::Validations

  def call_with_transaction
    ::ActiveRecord::Base.transaction(requires_new: true) do
      return true if call

      raise ::ActiveRecord::Rollback, "Aborting transaction: #{error_message}"
    end
    false
  end

  def call(**kwargs)
    @errors = kwargs[:errors] if kwargs[:errors].present?

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

  def self.puts_red(str)
    puts_colored :red, str
  end

  def self.puts_blue(str)
    puts_colored :blue, str
  end

  def self.puts_green(str)
    puts_colored :green, str
  end

  def self.puts_yellow(str)
    puts_colored :yellow, str
  end

  def self.puts_colored(color, str)
    color_code = {
      red:    31,
      green:  32,
      yellow: 33,
      blue:   34
    }[color.to_sym] || 35
    send(:puts, "\e[#{color_code}m#{str}\e[0m")
  end

  def self.log(msg, return_value: true, color: :blue)
    puts_colored(color.to_sym, "#{format('%.3f', t).rjust(5)}s - #{msg}") unless Rails.env.test?
    return_value
  end

  def self.t_start
    @t_start ||= Time.zone.now
  end

  def self.t
    (Time.zone.now.to_f - t_start.to_f).abs.round(3)
  end

  private

  def import(klass, models, **options)
    out = klass.import(models, **options)
    return true if out.failed_instances.empty?

    out.failed_instances.map(&:error_message).tally.each do |err, count|
      add_error("#{count} #{klass} failed to import due to #{err}")
    end
    false
  end

  def record_fact(fact_type, entity_slug:, entity_type:, details:)
    cmd = ::V2::RecordFact.new(details: details, entity_type: entity_type, entity_slug: entity_slug, fact_type: fact_type)
    cmd.call(errors: errors)
  end

  def log(msg, return_value: true)
    puts_blue "#{format('%.3f', t).rjust(5)}s - #{msg}" unless Rails.env.test?
    return_value
  end

  def t_start
    @t_start ||= Time.zone.now
  end

  def t
    (Time.zone.now.to_f - t_start.to_f).abs.round(3)
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
