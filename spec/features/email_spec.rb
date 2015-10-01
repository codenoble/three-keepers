require 'spec_helper'
include AuthenticationHelpers
include FactoryGirl::Syntax::Methods

describe 'emails' do
  let(:address) { 'frank.bennedetto@biola.edu' }
  let(:person) { create(:person, first_name: 'Frank', last_name: 'Bennedetto', partial_ssn: '0486') }
  let(:email_hashes) { [build(:email_hash, uuid: person.uuid, address: address), build(:email_hash)] }
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

    describe 'emails#show' do
      before { allow_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:index).with({}).and_return double(perform: double(headers: headers, parse: email_hashes)) }
      before { expect_any_instance_of(GoogleSyncinator::APIClient::PersonEmails).to receive(:show).and_return double(perform: double(status: 200, parse: email_hashes.first)) }
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

    describe 'emails#new' do
      before do
        allow_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:index).with({}).and_return double(perform: double(headers: headers, parse: email_hashes))
        expect_any_instance_of(GoogleSyncinator::APIClient::PersonEmails).to receive(:create).with('uuid' => person.uuid, 'address' => address).and_return double(perform: double(success?: true, parse: email_hashes.first))
        expect_any_instance_of(GoogleSyncinator::APIClient::PersonEmails).to receive(:show).and_return double(perform: double(status: 200, parse: email_hashes.first))
        allow_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:index).with(q: address).and_return double(perform: double(parse: []))
      end

      it 'creates a new email' do
        visit root_path
        click_link 'Emails'
        click_link 'New Person Email'
        # NOTE: fill_in doesn't work for hidden fields, this is the work around.
        #   Ideally, we'd be using a JavaScript engine here, but it seems like overkill for just this.
        find(:xpath, "//input[@id='person_email_uuid']").set person.uuid
        fill_in 'person_email_address', with: address
        click_button 'Create Person Email'
        expect(page).to have_content address
        expect(page).to have_content(/Owner.*#{person.first_name}\ #{person.last_name}/)
      end
    end
  end
end
