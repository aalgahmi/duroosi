module Actionable
  extend ActiveSupport::Concern

  included do
    has_many :activities, :as => :actionable, :dependent => :destroy

    def log_activity(action, klass, student, context = nil, points = 0, accumulate_points = false, data = nil)
      a = self.activities.where(:action => action, :klass => klass, :student => student).first_or_initialize
      a.times = a.times + 1
      if context
        a.context_id = context.id
        a.context_type = context.class.name
      end
    
      if accumulate_points
        a.points += points
      else
        a.points = points
      end

      a.data = data if data.present?
      a.save!

      a
    end
  
    def has?(action, klass, student) 
      self.activities.where(:student => student, :klass => klass, :action => action).any?
    end

    def activity(action, klass, student)
      self.activities.where(:student => student, :klass => klass, :action => action).first
    end
  end

  module ClassMethods
	end
end