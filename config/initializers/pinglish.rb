ThreeKeepers::Application.config.middleware.use Pinglish do |ping|
  ping.check :mongodb do
    Mongoid.default_session.command(ping: 1).has_key? 'ok'
  end
end
