class Function < ApplicationRecord
  has_paper_trail

  RUNTIMES = %w[
    java8
    nodejs
    nodejs4.3
    python2.7
  ]

  MEMORY_SIZES = [
    128,
    256,
    512,
    1024,
    1536,
  ]

  validates :name, presence: true, format: {with: /\A[-_.a-zA-Z0-9]+\z/}, length: {maximum: 100}
  validates :description, length: {maximum: 500}
  validates :remote_id, presence: true, uniqueness: true
  validates :runtime, inclusion: {in: RUNTIMES}
  validates :code, presence: true, length: {maximum: 5000}
  validates :memory_size, inclusion: {in: MEMORY_SIZES}
  validates :timeout, inclusion: 1..10
  validates :private, inclusion: {in: [true, false]}

  before_validation :set_defaults, on: :create

  def create_function!
    # TODO: http://docs.aws.amazon.com/sdkforruby/api/Aws/Lambda/Client.html#create_function-instance_method
  end

private

  def set_defaults
    self.remote_id = "function-#{SecureRandom.urlsafe_base64(40)}"
    self.memory_size ||= 128
    self.timeout ||= 3
    self.private ||= false
  end

  def aws_client
    # @aws_client ||= Aws::Lambda::Client.new(
    #   access_key_id: creds['access_key_id'],
    #   secret_access_key: creds['secret_access_key'],
    # )
  end
end
