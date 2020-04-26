# frozen_string_literal: true

class User < ApplicationRecord
  def self.[](handle)
    email = handle =~ /\@/ ? handle : "#{handle.downcase}@covid19zones.com"
    @cached ||= {}
    @cached[email] ||= readonly.find_by(email: email)
  end

  ROLES = %w[bot admin contributor].freeze

  validates :role, inclusion: { in: ROLES, message: "must be one of #{ROLES.to_sentence}" }
  has_many :zones, class_name: "::V2::Zone", foreign_key: "maintainer", primary_key: "email", inverse_of: :maintainer, dependent: :delete_all
  has_many :units, class_name: "::V2::Unit", foreign_key: "maintainer", primary_key: "email", inverse_of: :maintainer, dependent: :delete_all

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable, :omniauthable
end
