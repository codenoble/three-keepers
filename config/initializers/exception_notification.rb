if defined? ::ExceptionNotifier
  BeefyArm::Application.config.middleware.use ExceptionNotification::Rack,
    email: {
      email_prefix: '[beefy-arm] ',
      sender_address: Settings.email.from,
      exception_recipients: Settings.exceptions.mail_to
    }
end
