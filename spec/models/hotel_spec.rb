require 'rails_helper'

RSpec.describe Hotel, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  it { should validate_presence_of(:name) }
  # it { should validate_presence_of(:address) }
  # it { should validate_presence_of(:phone) }
  # it { should validate_presence_of(:intro) }
  # it { should validate_presence_of(:url) }
  # it { should validate_presence_of(:latitude) }
  # it { should validate_presence_of(:longitude) }
  # it { should validate_presence_of(:category) }
end
