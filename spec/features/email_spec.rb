require 'spec_helper'
include AuthenticationHelpers
include FactoryGirl::Syntax::Methods

describe 'emails' do
  let(:address) { 'frank.bennedetto@biola.edu' }
  let(:person) { create(:person, first_name: 'Frank', last_name: 'Bennedetto', partial_ssn: '0486') }
  let(:email_hashes) { [build(:email_hash, uuid: person.uuid, address: address), build(:email_hash)] }
  before { login_as username }

  describe 'as an unauthorized user' do
    let(:username) { 'nobody' }

    it 'should render a forbidden page' do
      visit emails_path
      expect(page).to have_content 'Access Denied'
    end
  end

  describe 'as a developer' do
    let(:username) { 'dev' }
    before { allow_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:index).with(page: 1).and_return double(perform: double(parse: email_hashes)) }

    describe 'emails#index' do
      it 'should list emails' do
        visit root_path
        click_link 'Emails'
        expect(page).to have_content email_hashes.first[:address]
        expect(page).to have_content email_hashes.last[:address]
      end
    end

    describe 'emails#show' do
      before { expect_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:show).and_return double(perform: double(status: 200, parse: email_hashes.first)) }
      before { allow_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:index).with(q: address).and_return double(perform: double(parse: [])) }

      it 'should show an email' do
        visit root_path
        click_link 'Emails'
        click_link address
        expect(page).to have_content address
        expect(page).to have_content 'Frank Bennedetto'
      end

      it 'should link to a person' do
        visit root_path
        click_link 'Emails'
        click_link address
        click_link 'Frank Bennedetto'
        expect(page).to have_content '0486' # partial SSN
      end
    end
  end
end
