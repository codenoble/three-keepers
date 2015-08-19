GoogleSyncinatorAPIClient.configure do |c|
  s = Settings.google_syncinator

  c.scheme = s.scheme
  c.host = s.host
  c.port = s.port
  c.script_name = s.script_name
  c.version = s.version
  c.access_id = s.access_id
  c.secret_key = s.secret_key
end
