class User < ApplicationRecord
    #encrypt password
    has_secure_password
    
    # validations
    validates_presence_of :username, :password_digest, :role
end
