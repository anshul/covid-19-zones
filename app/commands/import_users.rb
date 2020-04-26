# frozen_string_literal: true

class ImportUsers < BaseCommand
  def self.perform_task
    new.call_with_transaction
  end

  attr_reader :response, :raw_patients
  def run
    create_users &&
      User.clear_cache &&
      log(" - We have #{User.count} users") ||
      puts_red("Failed: #{error_message}")
  end

  def create_users
    users.all? do |attrs|
      create_user(attrs)
    end
  end

  def create_user(attrs)
    user = User[attrs[:email]]
    return true if user && attrs.keys.reject { |k| k =~ /password/ }.all? { |k| user[k] == attrs[k] }

    user = User.find_by(email: attrs[:email]) || User.new(email: attrs[:email], password: attrs[:password], password_confirmation: attrs[:password])
    user.assign_attributes(**attrs.except(:password))
    log "   > #{user.id ? 'Updating' : 'Creating'} user #{attrs[:email]}"
    user.save || add_error(user.error_message)
  end

  def users
    [
      { email: "bot@covid19zones.com", password: Rails.env.production? ? Rails.application.credentials.bot_password : "bot123", role: "bot", name: "c19z bot" }
    ]
  end
end
