# frozen_string_literal: true

class ImportUsers < BaseCommand
  def self.perform_task
    new.call!
  end

  attr_reader :response, :raw_patients
  def run
    create_users &&
      log(" - We have #{User.count} users")
  end

  def create_users
    users.all? do |attrs|
      next if User.exists?(email: attrs[:email])

      user = User.new(**attrs.merge(password_confirmation: attrs[:password]))
      log "   > Creating user #{attrs[:email]}"
      user.save || add_error(user.full_messages.to_sentence)
    end
  end

  def users
    [
      { email: "bot@covid19zones.com", password: "bCGUvwEmRknKw2Yt" }
    ]
  end
end
