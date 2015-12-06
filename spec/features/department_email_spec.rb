require 'spec_helper'
include AuthenticationHelpers
include FactoryGirl::Syntax::Methods

describe 'department emails' do
  let(:address) { 'homestarmy@biola.edu' }
  let(:person) { create(:person, first_name: 'Frank', last_name: 'Bennedetto', partial_ssn: '0486') }
  let(:email_hash) { build(:department_email_hash, uuids: [person.uuid], address: address, first_name: 'Homestar', last_name: 'Army') }
  let(:headers) { {'x-page' => 1, 'x-total-pages' => 1, 'x-limit-value' => 2} }
  before { login_as username }

  describe 'as an unauthorized user' do
    let(:username) { 'nobody' }

    it 'should render a forbidden page' do
      visit person_email_path(email_hash['id'])
      expect(page).to have_content 'Access Denied'
    end
  end

  describe 'as a developer' do
    let(:username) { 'dev' }

    describe 'department_emails#show' do
      before { allow_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:index).with({}).and_return double(perform: double(headers: headers, parse: [email_hash])) }
      before { expect_any_instance_of(GoogleSyncinator::APIClient::DepartmentEmails).to receive(:show).and_return double(perform: double(status: 200, parse: email_hash)) }
      before { allow_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:index).with(q: address).and_return double(perform: double(parse: [])) }

      it 'should show an email' do
        visit root_path
        click_link 'Emails'
        click_link address
        expect(page).to have_content address
        expect(page).to have_content /First\ Name.*Homestar/
        expect(page).to have_content /Last\ Name.*Army/
      end

      it 'should link to the owners' do
        visit root_path
        click_link 'Emails'
        click_link address
        click_link 'Frank Bennedetto'
        expect(page).to have_content '0486' # partial SSN
      end
    end

    describe 'department_emails#new' do
      before do
        allow_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:index).with({}).and_return double(perform: double(headers: headers, parse: [email_hash]))
        expect_any_instance_of(GoogleSyncinator::APIClient::DepartmentEmails).to receive(:create).with('address' => address, 'uuids' => [person.uuid], 'first_name' => 'Frank', 'last_name' => 'Bennedetto', 'department' => 'Infantry', 'title' => 'Private', 'privacy' => 'false').and_return double(perform: double(success?: true, parse: email_hash))
        expect_any_instance_of(GoogleSyncinator::APIClient::DepartmentEmails).to receive(:show).and_return double(perform: double(status: 200, parse: email_hash))
        allow_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:index).with(q: address).and_return double(perform: double(parse: []))
      end

      it 'creates a new email' do
        visit root_path
        click_link 'Emails'
        click_link 'New Department Email'
        fill_in 'department_email_address', with: address
        # NOTE: fill_in doesn't work for hidden fields, this is the work around.
        #   Ideally, we'd be using a JavaScript engine here, but it seems like overkill for just this.
        find(:xpath, "//input[@id='department_email_uuids_']").set person.uuid
        fill_in 'First Name', with: 'Frank'
        fill_in 'Last Name', with: 'Bennedetto'
        fill_in 'Department', with: 'Infantry'
        fill_in 'Title', with: 'Private'
        click_button 'Create Department Email'
        expect(page).to have_content address
        expect(page).to have_content(/Owner.*#{person.first_name}\ #{person.last_name}/)
      end
    end

    describe 'department_emails#edit' do
      before do
        allow_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:index).with({}).and_return double(perform: double(headers: headers, parse: [email_hash]))
        allow_any_instance_of(GoogleSyncinator::APIClient::DepartmentEmails).to receive(:show).and_return double(perform: double(status: 200, parse: email_hash))
        allow_any_instance_of(GoogleSyncinator::APIClient::Emails).to receive(:index).with(q: address).and_return double(perform: double(parse: []))
        expect_any_instance_of(GoogleSyncinator::APIClient::DepartmentEmails).to receive(:update).with(id: email_hash['id'], address: address, uuids: [person.uuid], first_name: 'Frankie', last_name: email_hash['last_name'], department: email_hash['department'], title: email_hash['title'], privacy: 'false').and_return double(perform: double(success?: true, parse: {'id' => 1234}))
      end

      it 'renames an email' do
        visit root_path
        click_link 'Emails'
        click_link address
        click_link 'Edit Department Email'
        fill_in 'First Name', with: 'Frankie'
        click_button 'Update Department Email'
        expect(page).to have_content address
        expect(page).to have_content 'Sucessfully updated department email'
      end
    end
  end
end
