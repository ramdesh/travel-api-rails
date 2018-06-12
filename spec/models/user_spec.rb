require 'rails_helper'

RSpec.describe User, type: :model do
    # pending "add some examples to (or delete) #{__FILE__}"
    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:password) }
    # it { should validate_presence_of(:phone) }
    # it { should validate_presence_of(:first_name) }
    # it { should validate_presence_of(:last_name) }
    # it { should validate_presence_of(:role) }
end
