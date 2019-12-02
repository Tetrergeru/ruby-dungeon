require 'mongoid'

# frozen_string_literal: true

# User
class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  embeds_one :inventory
  field :location, type: BSON::ObjectId
  field :chest, type: BSON::ObjectId

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
    if !user.inventory
      user.inventory = Inventory.new(items: [])
    end
    user
  end

  def action(action_id)
    
    # FIXME
    if !location
      # FIXME
      u = User.find(id)
      u.location = location = Level.all[0].id
      u.save
    end

    # FIXME
    # FIXME !
    u = User.find(id)
    if u.chest.present?
      Level.find(u.location).chests.find(u.chest).action(u, action_id)
    else
      c = Level.find(u.location.to_s).chests.find(action_id)
      if c.present?
        chest = u.chest = c.id
      end
    end
    u.save
  end


  def show
    # FIXME
    u = User.find(id)
    if !location
      u.location = location = Level.all[0].id
      u.save
    end
    
    if u.chest
      Level.find(u.location).chests.find(u.chest).show(u)
    else
      Level.find(u.location).show
    end
  end
end
