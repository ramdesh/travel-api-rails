require 'rails_helper'

RSpec.describe 'Activities API', type: :request do
  # initialize test data 
  let!(:activities) { create_list(:activity, 10) }
  let(:activity_id) { activities.first.id }

  # Test suite for GET /activities
  describe 'GET /activities' do
    # make HTTP get request before each example
    before { get '/activities' }

    it 'returns activities' do
      # Note `json` is a custom helper to parse JSON responses
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  # Test suite for POST /activities
  describe 'POST /activities' do
    # valid payload
    let(:valid_attributes) { { activity: { name: 'Sigiriya' } } }

    context 'when the request is valid' do
      before { post '/activities', params: valid_attributes }

      it 'creates a activities' do
        expect(JSON.parse(response.body)).to eq(v) 
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when the request is invalid' do
      before { post '/activities' }

      it 'returns status code 400' do
        expect(response).to have_http_status(400)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/ActionController::ParameterMissing: param is missing or the value is empty: activity/)
      end
    end
  end

  # Test suite for GET /activities/:id
  describe 'GET /activities/:id' do
    before { get "/activities/#{activity_id}" }

    context 'when the record exists' do
      it 'returns the activities' do
        expect(json).not_to be_empty
        #expect(json['activity_id']).to eq(activity_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'error' do
      let(:activity_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Activity/)
      end
    end   
  end

  # Test suite for PUT /activities/:id
  # describe 'PUT /activities/:id' do
  #   let(:valid_attributes) { { name: 'Shopping' } }

  #   context 'when the record exists' do
  #     before { put "/activities/#{activity_id}", params: valid_attributes }

  #     it 'updates the record' do
  #       expect(response.body).to be_empty
  #     end

  #     it 'returns status code 204' do
  #       expect(response).to have_http_status(204)
  #     end
  #   end
  # end

  # Test suite for DELETE /activities/:id
  describe 'DELETE /activities/:id' do
    before { delete "/activities/#{activity_id}" }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end