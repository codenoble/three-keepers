class DepartmentEmailsController < ApplicationController
  include SearchEmail
  include EmailAPI

  def show
    if raw_email.nil?
      render file: "#{Rails.root}/public/404.html",  status: 404
    else
      @email = DepartmentEmailPresenter.new(raw_email)
    end
  end

  def new
    @form = DepartmentEmailForm.new(email_model)
  end

  def create
    @form = DepartmentEmailForm.new(email_model)

    # Strip out blank entries that can come through from blank form fields
    params[:department_email][:uuids] = Array(params[:department_email][:uuids]).reject(&:blank?)

    if @form.validate(params[:department_email])
      @form.save do |hash|
        response = GoogleSyncinator::APIClient::DepartmentEmails.new.create(params[:department_email]).perform

        if response.success? && @form.password.present? && params[:email_password]
          DepartmentEmailMailer.new_email(@form).deliver
        end

        handle_response(response, route: :department_email, email_id_param: 'id')
      end
    else
      flash.now[:alert] = @form.errors.full_messages.join('. ') + '.'
      render :new
    end
  end

  def edit
    @form = DepartmentEmailForm.new(email_model(raw_email))
    mark_persisted @form
  end

  def update
    # Strip out blank entries that can come through from blank form fields
    params[:department_email][:uuids] = Array(params[:department_email][:uuids]).reject(&:blank?)
    params[:department_email].delete(:password) if params[:department_email][:password].blank?

    @form = DepartmentEmailForm.new(email_model(raw_email))

    if @form.validate(params[:department_email])
      @form.save do |hash|
        response = GoogleSyncinator::APIClient::DepartmentEmails.new.update(params[:department_email].merge id: params[:id]).perform

        if response.success? && params[:email_password]
          if @form.password.present?
            DepartmentEmailMailer.changed_password(@form).deliver
          else
            flash[:alert] = "Can't email the password unless it's being changed"
          end
        end

        flash[:notice] = 'Sucessfully updated department email'
        handle_response(response, route: :department_email, email_id_param: 'id')
      end
    else
      flash.now[:alert] = @form.errors.full_messages.join('. ') + '.'
      mark_persisted @form
      render :new
    end
  end

  private

  def email_model(parameters = {})
    defaults = {'id' => nil, 'address' => nil, 'uuids' => nil, 'first_name' => nil, 'last_name' => nil, 'department' => nil, 'title' => nil, 'privacy' => false}
    OpenStruct.new(defaults.merge(parameters).slice(*defaults.keys))
  end

  def raw_email
    @raw_email ||= (
      response = GoogleSyncinator::APIClient::DepartmentEmails.new.show(id: params[:id]).perform

      if response.status != 404
        response.parse
      end
    )
  end

  # Make form_for treat this like an edit and not a create
  def mark_persisted(form)
    def form.persisted?() true end
  end
end
