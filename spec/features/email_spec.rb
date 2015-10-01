require 'spec_helper'
include AuthenticationHelpers
include FactoryGirl::Syntax::Methods

describe 'emails' do
  let(:address) { 'frank.bennedetto@biola.edu' }
  let(:person) { create(:person, first_name: 'Frank', last_name: 'Bennedetto', partial_ssn: '0486') }
  let(:email_hashes) { [build(:person_email_hash, uuid: person.uuid, address: address), build(:person_email_hash)] }
  let(:headers) { {'x-page' => 1, 'x-total-pages' => 1, 'x-limit-value' => 2} }
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

    describe 'emails#index' do
      before { allow_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:index).with({}).and_return double(perform: double(headers: headers, parse: email_hashes)) }

      it 'should list all emails' do
        visit root_path
        click_link 'Emails'
        expect(page).to have_content email_hashes.first['address']
        expect(page).to have_content email_hashes.last['address']
      end

      context 'when searching' do
        before { allow_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:index).with('q' => 'frank').and_return double(perform: double(headers: headers, parse: [email_hashes.first])) }

        it 'should list emailes matching search' do
          visit root_path
          click_link 'Emails'
          fill_in 'q', with: 'frank'
          click_button 'search_button'
          expect(page).to have_content email_hashes.first['address']
          expect(page).to_not have_content email_hashes.last['address']
        end
      end
    end
  end
end
