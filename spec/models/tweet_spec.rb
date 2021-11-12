require 'rails_helper'

RSpec.describe Tweet, type: :model do
  describe "Associations" do
    it {should belong_to(:user)}
    it {should have_many(:comments)}
  end

  describe "Validations" do
    let!(:user) {create(:user)}
    subject {
      described_class.new(title: Faker::Lorem.sentence, user_id: User.first.id)
    }
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end
    it "is not valid with invalid attributes" do
      subject.user = nil
      expect(subject).not_to be_valid
    end
  end
end
