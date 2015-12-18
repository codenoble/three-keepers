module PasswordHelper
  def random_password
    # TODO: The gsub shouldn't be necessary once verison > 0.0.2 of Madgab is released
    Madgab.generate.gsub '_', ' '
  end
end
