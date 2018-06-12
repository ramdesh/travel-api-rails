# spec/models/todo_spec.rb
require 'rails_helper'

# Test suite for the Todo model
RSpec.describe User, type: :model do

  # Validation tests
  # ensure columns title and created_by are present before saving
  it { should validate_presence_of(:username) }
  it { should validate_presence_of(:first_name) }
end