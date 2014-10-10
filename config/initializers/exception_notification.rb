if defined? ::ExceptionNotifier
  ThreeKeepers::Application.config.middleware.use ExceptionNotification::Rack,
    email: {
      email_prefix: '[three-keepers] ',
      sender_address: Settings.email.from,
      exception_recipients: Settings.exceptions.mail_to
    }
end
