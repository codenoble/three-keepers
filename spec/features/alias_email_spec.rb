require 'spec_helper'
include AuthenticationHelpers
include FactoryGirl::Syntax::Methods

describe 'alias emails' do
  let(:address) { 'frank.bennedetto@biola.edu' }
  let(:person) { create(:person, first_name: 'Frank', last_name: 'Bennedetto', partial_ssn: '0486') }
  let(:person_email_hash) { build(:person_email_hash, uuid: person.uuid, address: address) }
  let(:alias_email_hash) { build(:alias_email_hash) }
  let(:email_hashes) { [person_email_hash, alias_email_hash] }
  let(:headers) { {'x-page' => 1, 'x-total-pages' => 1, 'x-limit-value' => 2} }
  before { login_as username }

  describe 'as an unauthorized user' do
    let(:username) { 'nobody' }

    it 'should render a forbidden page' do
      visit alias_email_path(email_hashes.first['id'])
      expect(page).to have_content 'Access Denied'
    end
  end

  describe 'as a developer' do
    let(:username) { 'dev' }

    describe 'alias_emails#show' do
      before do
        allow_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:index).with({}).and_return double(perform: double(headers: headers, parse: email_hashes))
        expect_any_instance_of(GoogleSyncinator::APIClient::AliasEmails).to receive(:show).and_return double(perform: double(status: 200, parse: alias_email_hash))
        allow_any_instance_of(GoogleSyncinator::APIClient::AccountEmails).to receive(:show).and_return double(perform: double(status: 200, parse: person_email_hash))
        allow_any_instance_of(GoogleSyncinator::APIClient::PersonEmails).to receive(:show).and_return double(perform: double(status: 200, parse: person_email_hash))
        allow_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:index).with(q: alias_email_hash['address']).and_return double(perform: double(parse: []))
      end

      it 'should show an email' do
        visit root_path
        click_link 'Emails'
        click_link alias_email_hash['address']
        expect(page).to have_content alias_email_hash['address']
        expect(page).to have_content(/Alias of.*#{address}/)
      end

      it 'should link to the account email' do
        allow_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:index).with(q: address).and_return double(perform: double(parse: []))

        visit root_path
        click_link 'Emails'
        click_link alias_email_hash['address']
        click_link address
        expect(page).to have_content(/Owner.*Frank Bennedetto/)
      end
    end

    describe 'alias_emails#new' do
      before do
        allow_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:index).with({}).and_return double(perform: double(headers: headers, parse: email_hashes))
        expect_any_instance_of(GoogleSyncinator::APIClient::AliasEmails).to receive(:create).with('account_email_id' => person_email_hash['id'], 'address' => address).and_return double(perform: double(success?: true, parse: email_hashes.first))
        expect_any_instance_of(GoogleSyncinator::APIClient::AliasEmails).to receive(:show).and_return double(perform: double(status: 200, parse: alias_email_hash))
        allow_any_instance_of(GoogleSyncinator::APIClient::AccountEmails).to receive(:show).and_return double(perform: double(status: 200, parse: person_email_hash))
        allow_any_instance_of(GoogleSyncinator::APIClient::PersonEmails).to receive(:show).and_return double(perform: double(status: 200, parse: person_email_hash))
        allow_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:index).with(q: alias_email_hash['address']).and_return double(perform: double(parse: []))
      end

      it 'creates a new alias email' do
        visit root_path
        click_link 'Emails'
        click_link 'New Alias Email'
        # NOTE: fill_in doesn't work for hidden fields, this is the work around.
        #   Ideally, we'd be using a JavaScript engine here, but it seems like overkill for just this.
        find(:xpath, "//input[@id='alias_email_account_email_id']").set person_email_hash['id']
        fill_in 'alias_email_address', with: address
        click_button 'Create Alias Email'
        expect(page).to have_content address
        expect(page).to have_content(/Alias of.*#{person_email_hash['address']}/)
      end
    end
  end
end
