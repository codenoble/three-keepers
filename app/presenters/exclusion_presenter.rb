class ExclusionPresenter < ApplicationPresenter
  presents Hash

  def id
    model['id']
  end

  def creator
    @creator ||= PersonPresenter.new(person_model) if person_model.present?
  end
  alias :person :creator

  def starts_at
    DateTime.parse(model['starts_at']) if model['starts_at'].present?
  end

  def ends_at
    DateTime.parse(model['ends_at']) if model['ends_at'].present?
  end

  def reason
    model['reason']
  end

  def past?
    ends_at.present? && ends_at.past?
  end

  def current?
    starts_at.past? && (ends_at.nil? || ends_at.future?)
  end

  def future?
    starts_at.future?
  end

  private

  def creator_uuid
    model['creator_uuid']
  end

  def person_model
    @person_model ||= Person.where(uuid: creator_uuid).first if creator_uuid.present?
  end
end
