require "rails_helper"
RSpec.describe "Registration", :type => :request do
    before(:each) do
        @sign_up_url = '/api/v1/auth/' 
    end
    describe 'Email registration method' do
        describe 'POST /api/v1/auth/' do
            context 'when signup params is valid' do
                let!(:valid_attributes){
                    {
                      username: "raushan998",
                      email: "user@example.com",
                      password: "12345678",
                      password_confirmation: "12345678"
                   }
                }
                before {
                   post @sign_up_url, params: valid_attributes
                }
                it 'returns status 200' do
                    expect(response).to have_http_status(200)
                end
                it 'returns authentication header with right attributes' do
                    expect(response.headers['access-token']).to be_present
                end
                it 'returns client in authentication header' do
                    expect(response.headers['client']).to be_present
                end
                it 'returns expiry in authentication header' do
                    expect(response.headers['expiry']).to be_present
                end
                it 'returns uid in authentication header' do
                    expect(response.headers['uid']).to be_present
                end
                it 'returns status success' do
                    expect(json['status']).to eq('success')
                end
                it 'creates new user' do
                    expect(json["data"]["username"]).to eql("raushan998")
                    expect(json["data"]["email"]).to eql("user@example.com")
                    expect(json["data"].count).to eql(8)
                end
            end
            context 'when signup params is invalid' do
                before { post @sign_up_url }
                it 'returns unprocessable entity 422' do
                    expect(response).to have_http_status(422)
                end
            end
        end
    end
end