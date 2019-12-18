# frozen_string_literal: true

require 'mongoid'

# Item
class Item
  include Mongoid::Document

  field :name, type: String
  field :dam, type: Float
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
      i.dam = default_damage(i.name)
    i
  end

  def self.default_damage(name)
    case name.to_sym
    when :revolver
      2
    when :sword
      1
    else
      0
    end
  end

  def damage
    if dam
      dam
    else
      Item.default_damage(name)
    end
  end
end
