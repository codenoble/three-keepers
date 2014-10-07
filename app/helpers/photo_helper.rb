module PhotoHelper
  # TODO: this should be replaced once photos are synced into Trogdir
  def photo(person, size=:medium)
    if biola_id = person.ids.where(type: :biola_id).first
      md5 = Digest::MD5.hexdigest(biola_id.identifier.to_s)
      "https://apps.biola.edu/idphotos/#{md5}_#{size}.jpg"
    end
  end
end
