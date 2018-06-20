class ActivitiesController < ApplicationController
  before_action :set_activity, only: [:show, :update, :destroy]

# GET /activities
def index
  @activities = Activity.all
  json_response(@activities)
end

#POST /activities/random
def create_random
  #RandActivityJob.perform_later
  activity_params = [{name: Faker::Name.name,
              address: Faker::Address.full_address,
              phone: Faker::PhoneNumber.cell_phone,
              intro: Faker::Lorem.paragraph,
              url: Faker::Internet.url,
              longitude: Faker::Address.longitude,
              latitude: Faker::Address.latitude,
              category: Faker::Company.type }]
  @activity = Activity.create!(activity_params)
  json_response(@activity, :created)
end

# POST /activities
def create
  #@activity = Activity.new(activity_params)
  #@activity.save
  @activity = Activity.create!(activity_params)
  json_response(@activity, :created)
end

# GET /activities/:id
def show
  json_response(@activity)
end

#  PUT /activities/:id
 def update
   @activity.update(activity_params)
   head :no_content
 end

# DELETE /activities/:id
def destroy
  @activity.destroy
  head :no_content
end

private
  def activity_params
    # whitelist params
  #  params.require(:activity).permit(:name, :address, :phone, :intro, :url, :longitude, :latitude, :category)
    params.permit(:name, :address, :phone, :intro, :url, :longitude, :latitude, :category)
  end

  def set_activity
    @activity = Activity.find(params[:id])
  end
end