module PasswordHelper
  CHARACTERS = %{abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*()-_=+;:'",<.>/?}
  MIN = 12 # minimum password length
  MAX = 16 # maximum password length

  # TODO: I'd rather have a better password generator eventually. But this will do for now.
  def random_password
    (0..rand(MIN..MAX)).to_a.map{ CHARACTERS[rand(0...CHARACTERS.length)]}.join
  end
end
