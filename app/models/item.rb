# frozen_string_literal: true

require 'mongoid'

# Item
class Item
  include Mongoid::Document

  field :name, type: String
  embedded_in :inventory

  def self.random_generate
    i = new
    case rand(3)
    when 0
      i.name = :revolver
    when 1
      i.name = :ruby
    when 2
      i.name = :sword
    end
    i
  end
end
