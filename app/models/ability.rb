# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.role == "contributor"
      can :read, :all
      can :manage, User, id: user.id
      can :manage, ::V2::Zone, maintainer: user.email
      can :manage, ::V2::Unit, maintainer: user.email
    else
      can :manage, :all
    end
  end
end
