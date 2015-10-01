require 'spec_helper'
include AuthenticationHelpers
include FactoryGirl::Syntax::Methods

describe 'exclusions' do
  let(:address) { 'frank.bennedetto@biola.edu' }
  let(:exclusion_id) { BSON::ObjectId.new.to_s }
  let(:reason) { 'Testing with Capybara' }
  let(:person) { create(:person, first_name: 'Frank', last_name: 'Bennedetto', partial_ssn: '0486') }
  let(:email_hash) { build(:email_hash, uuid: person.uuid, address: address, exclusions: [{'id' => exclusion_id, 'starts_at' => Time.now.to_s, 'reason' => reason}]) }
  let(:email_hashes) { [email_hash, build(:email_hash)] }
  let(:headers) { {'x-page' => 1, 'x-total-pages' => 1, 'x-limit-value' => 2} }
  before { login_as username }

  describe 'as an unauthorized user' do
    let(:username) { 'nobody' }

    it 'should render a forbidden page' do
      visit new_person_email_exclusion_path(email_hash['id'])
      expect(page).to have_content 'Access Denied'
    end
  end

  describe 'as a developer' do
    let(:username) { 'dev' }

    before do
      allow_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:index).with({}).and_return double(perform: double(headers: headers, parse: email_hashes))
      allow_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:show).and_return double(perform: double(status: 200, parse: email_hashes.first))
      allow_any_instance_of(GoogleSyncinator::APIClient::PersonEmails).to receive(:show).and_return double(perform: double(status: 200, parse: email_hashes.first))
      allow_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:index).with(q: address).and_return double(perform: double(parse: []))
    end

    describe 'exclusions#new' do
      let(:user) { create :person }
      let(:start_time) { Time.now.to_s }
      let(:end_time) { 1.month.from_now.to_s }

      before do
        create :id, person: user, identifier: 'dev', type: :netid
        expect_any_instance_of(GoogleSyncinator::APIClient::Exclusions).to receive(:create).with(starts_at: start_time, ends_at: end_time, reason: reason, email_id: email_hash['id'], creator_uuid: user.uuid).and_return double(perform: double(success?: true, parse: {'email_id' => email_hash['id']}))
      end

      it 'creates a new exclusion' do
        visit root_path
        click_link 'Emails'
        click_link address
        click_link 'New Exclusion'
        fill_in 'Start Time', with: start_time
        fill_in 'End Time', with: end_time
        fill_in 'Reason', with: reason
        click_button 'Create Exclusion'
        expect(page).to have_content address
        expect(page).to have_content(/Owner.*#{person.first_name}\ #{person.last_name}/)
        expect(page).to have_content('Testing with Capybara')
      end
    end

    describe 'exclusions#destroy' do
      before do
        expect_any_instance_of(GoogleSyncinator::APIClient::Exclusions).to receive(:destroy).with(email_id: email_hash['id'], id: exclusion_id).and_return double(perform: double(success?: true))
      end

      it 'deletes an exclusion' do
        visit root_path
        click_link 'Emails'
        click_link address
        click_link 'Delete'
        expect(page).to have_content address
        expect(page).to have_content(/Owner.*#{person.first_name}\ #{person.last_name}/)
        expect(page).to have_content 'Exclusion deleted'
      end
    end
  end
end
