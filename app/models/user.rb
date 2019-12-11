require 'mongoid'

# frozen_string_literal: true

# User
class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  embeds_one :inventory
  field :location, type: BSON::ObjectId

  field :provider, type: String
  field :uid, type: String
  field :name, type: String
  field :token, type: String
  field :secret, type: String
  field :profile_image, type: String

  def self.find_or_create_from_auth_hash(auth_hash)
    user = where(provider: auth_hash.provider, uid: auth_hash.uid).first_or_create
    user.update(
      name: auth_hash.info.nickname,
      profile_image: auth_hash.info.image,
      token: auth_hash.credentials.token,
      secret: auth_hash.credentials.secret
    )
    user.inventory = Inventory.new(items: []) unless user.inventory
    user.location = Level.all[0].id unless user.location
    user.save
    user
  end
  
  def self.action(user_id, action_id)
    # FIXME
    u = User.find(user_id)
    State.action(u, action_id)
    u.save
  end

  def self.show(user_id)
    State.show(user_id)
  end
end
