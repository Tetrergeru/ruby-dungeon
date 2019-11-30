# frozen_string_literal: true

require 'mongoid'

# Inventory
class Inventory
  include Mongoid::Document

  embeds_many :items
  embedded_in :owner
end
