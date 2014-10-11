require 'spec_helper'
include AuthenticationHelpers
include FactoryGirl::Syntax::Methods

describe 'syncinators' do
  before { login_as username }

  describe 'as an unauthorized user' do
    let(:username) { 'nobody' }

    it 'should render a forbidden page' do
      visit syncinators_path
      expect(page).to have_content 'Access Denied'
    end
  end

  describe 'as a developer' do
    let(:username) { 'dev' }

    before do
      create :syncinator, name: 'rather-dashing', queue_changes: false
      create :syncinator, name: 'trogador', queue_changes: true
      create :person, last_name: 'Gary', preferred_name: 'Poor', partial_ssn: '3000'
    end

    describe 'syncinators#index' do
      it 'should list syncinators' do
        visit root_path
        click_link 'Syncinators'
        expect(page).to have_content 'rather-dashing'
        expect(page).to have_content 'trogador'
      end
    end

    describe 'syncinators#show' do
      it 'should show a syncinator' do
        visit root_path
        click_link 'Syncinators'
        click_link 'rather-dashing'
        expect(page).to have_content 'rather-dashing'
        expect(page).to have_content 'Changesets'
      end

      context 'without queued changes' do
        it 'should not show changesets' do
          visit root_path
          click_link 'Syncinators'
          click_link 'rather-dashing'
          expect(page).to have_content 'Change queueing has been disabled for this syncinator'
          expect(page).to_not have_content Date.today.to_s
          expect(page).to_not have_content 'Poor Gary'
        end
      end

      context 'with queued changes' do
        it 'it should show changesets' do
          visit root_path
          click_link 'Syncinators'
          click_link 'trogador'
          expect(page).to have_content 'Changesets'
          expect(page).to_not have_content 'Change queueing has been disabled for this syncinator'
          expect(page).to have_content Date.today.to_s
          expect(page).to have_content 'Poor Gary'
        end

        it 'should link to a changeset' do
          visit root_path
          click_link 'Syncinators'
          click_link 'trogador'
          click_link Date.today.to_s
          expect(page).to have_content 'Create person record for Poor Gary'
        end

        it 'should link to a person' do
          visit root_path
          click_link 'Syncinators'
          click_link 'trogador'
          click_link 'Poor Gary'
          expect(page).to have_content 'Poor Gary'
          expect(page).to have_content '3000'
        end
      end
    end
  end
end
