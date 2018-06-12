class User < ApplicationRecord
    # validations
    validates_presence_of :username, :password
end
