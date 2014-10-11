require 'spec_helper'
include AuthenticationHelpers
include FactoryGirl::Syntax::Methods

describe 'changesets' do
  before { login_as username }

  describe 'as a developer' do
    let(:username) { 'dev' }

    before do
      create :syncinator, name: 'rather-dashing', queue_changes: false
      create :syncinator, name: 'trogador', queue_changes: true
      create :person, last_name: 'Cumberdale', preferred_name: 'Ron', partial_ssn: '3000'
    end

    describe 'changeset#show' do
      it 'should show a changeset' do
        visit root_path
        click_link 'Syncinators'
        click_link 'trogador'
        click_link Date.today.to_s
        expect(page).to have_content 'Create person record for Ron Cumberdale'
        expect(page).to have_content '3000' # partial_ssn
      end

      it 'should list syncinators with queue_changes on' do
        visit root_path
        click_link 'Syncinators'
        click_link 'trogador'
        click_link Date.today.to_s
        expect(page).to have_content 'trogador'
        expect(page).to_not have_content 'rather-dashing'
      end

      it 'should link to the affected person' do
        visit root_path
        click_link 'Syncinators'
        click_link 'trogador'
        click_link Date.today.to_s
        expect(page).to have_content 'Ron Cumberdale'
        click_link 'Ron Cumberdale'
        expect(page).to have_content 'Ron Cumberdale'
        expect(page).to have_content 'Groups & Permissions'
        expect(page).to have_content '3000'
      end
    end
  end
end
