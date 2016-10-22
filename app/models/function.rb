require 'zip'

class Function < ApplicationRecord
  has_paper_trail

  MODULE_NAME = "index"
  HANDLER = "#{MODULE_NAME}.handler"

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

  # http://docs.aws.amazon.com/sdkforruby/api/Aws/Lambda/Client.html#create_function-instance_method
  def create_remote_function!
    AWS_LAMBDA_CLIENT.create_function({
      function_name: remote_id,
      runtime: runtime,
      role: Rails.application.secrets.aws.fetch("lambda").fetch("role"),
      handler: HANDLER,
      code: {
        zip_file: code_as_zip_file,
      },
      timeout: timeout,
      memory_size: memory_size,
    })
  end

  def update_code!(code)
    ActiveRecord::Base.transaction do
      update!({code: code})
      AWS_LAMBDA_CLIENT.update_function_code({
        function_name: remote_id,
        zip_file: code_as_zip_file,
      })
    end
  end

  def update_configuration!(timeout: self.timeout, memory_size: self.memory_size, runtime: self.runtime)
    ActiveRecord::Base.transaction do
      update!({
        timeout: timeout,
        memory_size: memory_size,
        runtime: runtime,
      })
      AWS_LAMBDA_CLIENT.update_function_configuration({
        function_name: remote_id,
        timeout: timeout,
        memory_size: memory_size,
        runtime: runtime,
      })
    end
  end

  def invoke!(invocation_type: "RequestResponse", client_context: {}, payload: {})
    log_type = invocation_type == "RequestResponse" ? "Tail" : "None"
    AWS_LAMBDA_CLIENT.invoke({
      function_name: remote_id,
      invocation_type: invocation_type, # accepts Event, RequestResponse, DryRun
      log_type: log_type, # accepts None, Tail
      # client_context: Base64.encode64(client_context.to_json),
      payload: payload.to_json,
    })
  end

private

  def code_as_zip_file
    stringio = Zip::OutputStream.write_buffer do |out|
      out.put_next_entry("#{MODULE_NAME}.#{zip_file_extension}")
      out.write(code)
    end
    stringio.rewind
    stringio
  end

  def zip_file_extension
    case runtime
    when "python2.7"
      "py"
    when "java8"
      "java"
    else
      "js"
    end
  end

  def set_defaults
    self.remote_id = "function-#{SecureRandom.urlsafe_base64(40)}"
    self.memory_size ||= 128
    self.timeout ||= 3
    self.private ||= false
  end
end
