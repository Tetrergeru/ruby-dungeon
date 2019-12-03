# frozen_string_literal: true

require 'mongoid'

# Door
class Door
  include Mongoid::Document
  include Mongoid::Timestamps

  field :x, type: Integer
  field :y, type: Integer
  field :target_level, type: BSON::ObjectId
  embedded_in :level

  def action(user, _action_id)
    # FIXME
    d = level.doors.find(id)
    unless target_level
      if Level.all.count > 4
        d.target_level = Level.all[rand(Level.all.count)].id
      else
        d.target_level = Level.random_generate(level).id
      end
    end
    d.save
    user.location = d.target_level
  end
end
