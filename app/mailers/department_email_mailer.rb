class DepartmentEmailMailer < ApplicationMailer
  # @param form [DepartmentEmailForm]
  def new_email(form)
    @form = form

    if (emails = emails_for(form.uuids)).any?
      mail(to: emails, subject: "New Email: #{@form.address}")
    end
  end

  # @param form [DepartmentEmailForm]
  def changed_password(form)
    @form = form

    if (emails = emails_for(form.uuids)).any?
      mail(to: emails, subject: "#{@form.address} Password Changed")
    end
  end

  private

  def emails_for(uuids)
    uuids.map do |uuid|
      Person.find_by(uuid: uuid).emails.where(type: :university).first.try(:address)
    end.compact
  end
end
