class PersonPresenter < ApplicationPresenter
  presents Person
  as_sentence :affiliations, :groups, :majors, :minors
  as_yes_no :full_time

  def changesets
    ChangesetPresenter.map(model.changesets.desc(:created_at))
  end

  def name
    [model.preferred_name, model.last_name].join(' ').strip
  end
  alias :to_s :name

  def name_and_id
    name = "#{preferred_name || first_name} #{last_name}"
    netid = ids.where(type: :netid).first.try(:identifier)

    [name, netid].reject(&:blank?).join(' - ')
  end

  def disabled?
    model.enabled == false
  end

  def privacy?
    model.privacy == true
  end

  def birth_date
    model.birth_date.try(:to_s, :long)
  end

  def entitlements
    model.entitlements.try(:join, ', ')
  end

  def student_info?
    model.residence? || model.floor? || model.wing? || model.majors? || model.minors? || model.mailbox?
  end

  def employee_info?
    model.department? || model.title? || model.employee_type? || model.full_time? || model.pay_type?
  end

  def university_email?
    !!university_email_address
  end

  def university_email_address
    @university_email_address ||= model.emails.where(type: :university).first.try(:address)
  end

  def biola_id?
    !!biola_id
  end

  def biola_id
    @biola_id ||= model.ids.where(type: :biola_id).first.try(:identifier)
  end
end
