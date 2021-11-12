require 'rails_helper'

RSpec.describe User, type: :model do
  
  describe "Associations" do
    it {should have_many(:tweets)}
    it {should have_many(:comments)}
  end

  describe "Validations" do
    subject {
      described_class.new(email: "abc@gmail.com", password: "some_password")
    }
    it "is valid with valid attributes" do
        expect(subject).to be_valid
    end
    it "is not valid with invalid attributes" do
        subject.email = nil
        expect(subject).to_not be_valid
    end

    it "is not valid with password with less than 6 characters" do
        subject.password = '1234'
        expect(subject).to_not be_valid
    end
  end
end
