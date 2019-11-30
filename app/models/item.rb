# frozen_string_literal: true

require 'mongoid'

# Item
class Item
  include Mongoid::Document

  field :name, type: String
  embedded_in :inventory
end
