class User < ApplicationRecord

  validates_presence_of :username, :first_name
end
