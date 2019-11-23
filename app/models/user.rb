require 'mongoid'

# frozen_string_literal: true

# User
class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :inventory, type: Hash
  field :location_id, type: BSON::ObjectId
end