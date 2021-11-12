require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe "Association" do
    it {should belong_to(:user)}
    it {should belong_to(:tweet)}
  end

  describe "Validations" do
    let!(:user) {create(:user)}
    let!(:tweet) {create(:tweet, user: user)}
    subject{
      described_class.new(title: "I don't agree with this", user: user,tweet: tweet)
    }
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end
    
    it "is not valid with invalid attributes" do
      subject.user = nil
      expect(subject).not_to be_valid
    end

    it "is not valid with invalid attributes" do
      subject.tweet = nil
      expect(subject).not_to be_valid
    end

  end
end
