# frozen_string_literal: true

class Project
  def self.root
    @root ||= defined?(Rails) ? Rails.root : File.expand_path(File.join(__dir__, "..", ".."))
  end

  unless root.respond_to?(:join)
    def root.join(*args)
      File.join(self, *args)
    end
  end

  def self.default_to!(default_env)
    return true if env.present?
    raise "Fatal: PROJECT_ENV=#{ENV['PROJECT_ENV'].inspect} is invalid." if rack_env.production?

    send(:puts, "Warning: PROJECT_ENV=#{ENV['PROJECT_ENV'].inspect} is invalid. Setting to #{default_env}")
    @env = valid_environments.select { |environ| environ == default_env }.first.to_s.inquiry
    raise "Fatal: default env=#{default_env.inspect} is invalid." if env.blank?

    env
  end

  def self.valid_environment?
    environment.present?
  end

  def self.test_env
    @test_env ||= "test".inquiry
  end

  def self.valid_environments
    @valid_environments ||= %w[live test fixture local ci canary]
  end

  def self.env
    @env ||= test_env if test?
    @env ||= valid_environments.select { |env| env == ENV["PROJECT_ENV"] }.first.to_s.inquiry
  end

  def self.rack_env
    rack_environment.inquiry
  end

  def self.rack_environment
    @rack_environment ||= defined?(Rails) ? Rails.env.to_s : (ENV["RACK_ENV"] || "development")
  end

  def self.environment
    env
  end

  def self.test?
    ENV["RACK_ENV"] == "test" || ENV["RAILS_ENV"] == "test" || ENV["PROJECT_ENV"] == "test"
  end
end
