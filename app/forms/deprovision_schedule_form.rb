class DeprovisionScheduleForm < Reform::Form
  include Coercion

  ACTIONS = [:notify_of_inactivity, :notify_of_closure, :suspend, :delete, :activate]

  property :email_id, type: String
  property :action, type: Symbol
  property :scheduled_for, type: DateTime
  property :reason, type: String

  validates :email_id, :action, :scheduled_for, presence: true
  validates :action, inclusion: {in: ACTIONS}

  # Actions for a FormBuilder#select drop down
  def action_options
    ACTIONS.map(&:to_s).map { |a| [a.titleize, a] }
  end
end
