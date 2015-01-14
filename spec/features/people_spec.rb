require 'spec_helper'
include AuthenticationHelpers
include FactoryGirl::Syntax::Methods

describe 'people' do
  before { login_as username }

  describe 'as an unauthorized user' do
    let(:username) { 'nobody' }

    it 'should render a forbidden page' do
      visit people_path
      expect(page).to have_content 'Access Denied'
    end
  end

  describe 'as a developer' do
    let(:username) { 'dev' }
    let!(:lord) { create :person, last_name: 'Quackingstick', preferred_name: 'Lord' }
    let!(:frank) { create :person, last_name: 'Bennedetto', preferred_name: 'Frank', partial_ssn: '0486' }

    describe 'people#index' do
      it 'should list people' do
        visit root_path
        click_link 'People'
        expect(page).to have_content 'Lord Quackingstick'
        expect(page).to have_content 'Frank Bennedetto'
      end

      it 'should search people' do
        visit root_path
        click_link 'People'
        fill_in 'q', with: 'Quack'
        click_button 'search_button'
        expect(page).to have_content 'Lord Quackingstick'
        expect(page).to_not have_content 'Frank Bennedetto'
      end
    end

    describe 'people#show' do
      it 'should show a person' do
        visit root_path
        click_link 'People'
        click_link 'Frank Bennedetto'
        expect(page).to have_content 'Frank Bennedetto'
        expect(page).to have_content '0486' # partial SSN
      end

      it 'should link to a changeset' do
        visit root_path
        click_link 'People'
        click_link 'Frank Bennedetto'
        expect(page).to have_content 'Changes'
        click_link frank.changesets.first.created_at.to_s(:shortish)
        expect(page).to have_content 'Create person record for Frank Bennedetto'
      end
    end
  end
end
