require 'spec_helper'
include AuthenticationHelpers
include FactoryGirl::Syntax::Methods

describe 'changesets' do
  before { login_as username }

  describe 'as a developer' do
    let(:username) { 'dev' }
    let!(:syncinator_a) { create :syncinator, name: 'rather-dashing', queue_changes: false }
    let!(:syncinator_b) { create :syncinator, name: 'trogador', queue_changes: true }
    let!(:person) { create :person, last_name: 'Cumberdale', preferred_name: 'Ron', partial_ssn: '3000' }

    describe 'changeset#show' do
      it 'should show a changeset' do
        visit root_path
        click_link 'Syncinators'
        click_link 'trogador'
        click_link Time.now.to_s(:shortish)
        expect(page).to have_content 'Create person record for Ron Cumberdale'
        expect(page).to have_content '3000' # partial_ssn
      end

      it 'should list syncinators with queue_changes on' do
        visit root_path
        click_link 'Syncinators'
        click_link 'trogador'
        click_link Time.now.to_s(:shortish)
        expect(page).to have_content 'trogador'
        expect(page).to_not have_content 'rather-dashing'
      end

      it 'should link to the affected person' do
        visit root_path
        click_link 'Syncinators'
        click_link 'trogador'
        click_link Time.now.to_s(:shortish)
        expect(page).to have_content 'Ron Cumberdale'
        click_link 'Ron Cumberdale'
        expect(page).to have_content 'Ron Cumberdale'
        expect(page).to have_content 'Groups & Permissions'
        expect(page).to have_content '3000'
      end

      context 'with succeeded change_sync' do
        before do
          change_sync = person.changesets.first.change_syncs.first

          change_sync.run_after = nil
          change_sync.sync_logs << SyncLog.new(started_at: Time.now, succeeded_at: Time.now, action: 'create')
          change_sync.save!
        end

        it 'allows change_sync to be rerun' do
          visit root_path
          click_link 'Syncinators'
          click_link 'trogador'
          click_link Date.today.to_s
          expect(page).to have_button 'Rerun'
          click_button 'Rerun'
          expect(page).to have_content 'Sucessfully marked to be rerun'
          expect(page).to_not have_content 'Rerun'
        end
      end

      context 'with unfinished change_sync' do
        it 'does now allow change_sync to be rerun' do
          visit root_path
          click_link 'Syncinators'
          click_link 'trogador'
          click_link Date.today.to_s
          expect(page).to_not have_button 'Rerun'
        end
      end
    end
  end
end
