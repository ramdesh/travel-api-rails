class Hotel < ApplicationRecord
    # validations
    validates_presence_of :name
end
