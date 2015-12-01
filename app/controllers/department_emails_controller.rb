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
    @form = DepartmentEmailForm.new(new_email_model)
  end

  def create
    @form = DepartmentEmailForm.new(new_email_model)

    # Strip out blank entries that can come through from blank form fields
    params[:department_email][:uuids] = Array(params[:department_email][:uuids]).reject(&:blank?)

    if @form.validate(params[:department_email])
      @form.save do |hash|
        response = GoogleSyncinator::APIClient::DepartmentEmails.new.create(params[:department_email]).perform

        handle_response(response, route: :department_email, email_id_param: 'id')
      end
    else
      flash.now[:alert] = @form.errors.full_messages.join('. ') + '.'
      render :new
    end
  end

  def edit
    # TODO
  end

  def update
    # TODO
  end

  private

  def new_email_model
    OpenStruct.new(address: nil, uuids: nil, first_name: nil, last_name: nil, department: nil, title: nil, privacy: false)
  end

  def update_email_model(address = nil)
    # TODO
    # OpenStruct.new(address: address)
  end

  def raw_email
    @raw_email ||= (
      response = GoogleSyncinator::APIClient::DepartmentEmails.new.show(id: params[:id]).perform

      if response.status != 404
        response.parse
      end
    )
  end
end
