class User < ApplicationRecord
  has_secure_password

  has_many :functions, inverse_of: :user

  before_validation :set_defaults, on: :create

  validates :api_key, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true, length: {minimum: 3, maximum: 30}, format: {with: /\A[-_a-zA-Z0-9]+\z/}
  validates :email, email: true, uniqueness: true
  # allow_nil is necessary for has_secure_password
  validates :password, length: { minimum: 6 }, allow_nil: true

  def self.find_by_username_case_insensitive!(username)
    User.where('lower(username) = ?', username.downcase).first!
  end

  def self.find_by_username_case_insensitive(username)
    User.where('lower(username) = ?', username.downcase).first
  end

  def regenerate_api_key
    self.api_key = "api-key_#{SecureRandom.urlsafe_base64(30)}"
  end

private

  def set_defaults
    regenerate_api_key
  end
end
