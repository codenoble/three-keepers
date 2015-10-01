require 'spec_helper'
include AuthenticationHelpers
include FactoryGirl::Syntax::Methods

describe 'deprovision schedules' do
  let(:address) { 'frank.bennedetto@biola.edu' }
  let(:deprovision_schedule_id) { BSON::ObjectId.new.to_s }
  let(:reason) { 'Testing with Capybara' }
  let(:person) { create(:person, first_name: 'Frank', last_name: 'Bennedetto', partial_ssn: '0486') }
  let(:email_hash) { build(:person_email_hash, uuid: person.uuid, address: address, deprovision_schedules: [{'id' => deprovision_schedule_id, 'action' => 'delete', 'scheduled_for' => Time.now.to_s, 'reason' => reason}]) }
  let(:email_hashes) { [email_hash, build(:person_email_hash)] }
  let(:headers) { {'x-page' => 1, 'x-total-pages' => 1, 'x-limit-value' => 2} }
  before { login_as username }

  describe 'as an unauthorized user' do
    let(:username) { 'nobody' }

    it 'should render a forbidden page' do
      visit new_person_email_deprovision_schedule_path(email_hash['id'])
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

    describe 'deprovision_schedules#new' do
      let(:user) { create :person }
      let(:action) { :delete }
      let(:scheduled_for) { Time.now.to_s }
      let(:completed_at) { 1.minute.from_now.to_s }

      before do
        create :id, person: user, identifier: 'dev', type: :netid
        expect_any_instance_of(GoogleSyncinator::APIClient::DeprovisionSchedules).to receive(:create).with(action: action.to_s, scheduled_for: scheduled_for, reason: reason, email_id: email_hash['id']).and_return double(perform: double(success?: true, parse: {'email_id' => email_hash['id']}))
      end

      it 'creates a new deprovision schedule' do
        visit root_path
        click_link 'Emails'
        click_link address
        click_link 'New Deprovision Schedule'
        select action.to_s.titleize, from: 'Action'
        fill_in 'Scheduled Time', with: scheduled_for
        fill_in 'Reason', with: reason
        click_button 'Create Deprovision Schedule'
        expect(page).to have_content address
        expect(page).to have_content(/Owner.*#{person.first_name}\ #{person.last_name}/)
        expect(page).to have_content('Testing with Capybara')
      end
    end

    describe 'emails#update' do
      before do
        expect_any_instance_of(GoogleSyncinator::APIClient::DeprovisionSchedules).to receive(:update).with(email_id: email_hash['id'], id: deprovision_schedule_id, canceled: 'true').and_return double(perform: double(success?: true))
      end

      it 'updates a deprovision schedule' do
        visit root_path
        click_link 'Emails'
        click_link address
        click_link 'Cancel'
        expect(page).to have_content address
        expect(page).to have_content(/Owner.*#{person.first_name}\ #{person.last_name}/)
        expect(page).to have_content 'Deprovision schedule updated'
      end
    end

    describe 'emails#destroy' do
      before do
        expect_any_instance_of(GoogleSyncinator::APIClient::DeprovisionSchedules).to receive(:destroy).with(email_id: email_hash['id'], id: deprovision_schedule_id).and_return double(perform: double(success?: true))
      end

      it 'deletes a deprovision schedule' do
        visit root_path
        click_link 'Emails'
        click_link address
        click_link 'Delete'
        expect(page).to have_content address
        expect(page).to have_content(/Owner.*#{person.first_name}\ #{person.last_name}/)
        expect(page).to have_content 'Deprovision schedule deleted'
      end
    end
  end
end
