# frozen_string_literal: true

class ImportUsers < BaseCommand
  def self.perform_task
    new.call_with_transaction
  end

  attr_reader :response, :raw_patients
  def run
    create_users &&
      log(" - We have #{User.count} users") ||
      puts_red("Failed: #{error_message}")
  end

  def create_users
    users.all? do |attrs|
      create_user(attrs)
    end
  end

  def create_user(attrs)
    return true if User.exists?(email: attrs[:email])

    user = User.new(**attrs.merge(password_confirmation: attrs[:password]))
    log "   > Creating user #{attrs[:email]}"
    user.save || add_error(user.error_message)
  end

  def users
    [
      { email: "bot@covid19zones.com", password: "bCGUvwEmRknKw2Yt" }
    ]
  end
end
