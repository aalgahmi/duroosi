module Suspendable
  extend ActiveSupport::Concern

  included do
    def suspended? 
      !active && suspended_at.present?
    end
  
    def suspend
      self.update(active: false, suspended_at: Time.zone.now, cancelled_at: nil)
    end
  end

  module ClassMethods
	end
end