# frozen_string_literal: true

require 'mongoid'

# Wall
class Wall
  include Mongoid::Document

  field :x, type: Integer
  field :y, type: Integer
  embedded_in :level
end
