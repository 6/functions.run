require 'zip'

class Function < ApplicationRecord
  has_paper_trail

  MODULE_NAME = "index"
  HANDLER = "#{MODULE_NAME}.handler"

  RUNTIMES = [
    # "java8",
    "nodejs4.3",
    "python2.7",
  ]
  RUNTIME_NAMES = {
    "java8" => "Java 8",
    "nodejs4.3" => "Node.js 4.3",
    "python2.7" => "Python 2.7",
  }
  RUNTIME_LANGUAGES = {
    "java8" => "java",
    "nodejs4.3" => "javascript",
    "python2.7" => "python",
  }
  RUNTIME_VERSIONS = {
    "java8" => 8,
    "nodejs4.3" => 4.3,
    "python2.7" => 2.7,
  }
  RUNTIME_TAB_SIZES = {
    "java8" => 4,
    "nodejs4.3" => 2,
    "python2.7" => 4,
  }

  MEMORY_SIZES = [
    128,
    # TODO: enable the below for paid plans?
    # 256,
    # 512,
    # 1024,
    # 1536,
  ]

  belongs_to :user, inverse_of: :functions

  validates :user, presence: true
  validates :name, presence: true, format: {with: /\A[_a-zA-Z0-9]+\z/}, length: {maximum: 100}, uniqueness: {scope: [:user_id]}
  validates :description, length: {maximum: 500}
  validates :remote_id, presence: true, uniqueness: true
  validates :runtime, inclusion: {in: RUNTIMES}
  validates :code, presence: true, length: {maximum: 5000}
  validates :memory_size, inclusion: {in: MEMORY_SIZES}
  validates :timeout, inclusion: 1..10
  validates :private, inclusion: {in: [true, false]}

  before_validation :set_defaults, on: :create

  def self.runtime_name(runtime)
    RUNTIME_NAMES[runtime]
  end

  def authorize!(current_user)
    if private? && user_id != current_user&.id
      raise ActiveRecord::RecordNotFound
    end
  end

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

  def update_remote_function!(attributes)
    ActiveRecord::Base.transaction do
      update!(attributes)

      if attributes[:code].present?
        AWS_LAMBDA_CLIENT.update_function_code({
          function_name: remote_id,
          zip_file: code_as_zip_file,
        })
      end

      if [:timeout, :memory_size, :runtime].any? { |attribute| attributes[attribute].present?}
        AWS_LAMBDA_CLIENT.update_function_configuration({
          function_name: remote_id,
          timeout: timeout,
          memory_size: memory_size,
          runtime: runtime,
        })
      end
    end
  end

  def delete_remote_function!
    AWS_LAMBDA_CLIENT.delete_function({
      function_name: remote_id,
    })
  end

  def invoke!(invocation_type: "RequestResponse", client_context: {}, payload: {})
    payload = payload.to_json unless payload.is_a?(String)
    log_type = invocation_type == "RequestResponse" ? "Tail" : "None"
    AWS_LAMBDA_CLIENT.invoke({
      function_name: remote_id,
      invocation_type: invocation_type, # accepts Event, RequestResponse, DryRun
      log_type: log_type, # accepts None, Tail
      client_context: Base64.encode64(client_context.to_json),
      payload: payload,
    })
  end

  def runtime_name
    self.class.runtime_name(runtime)
  end

  def runtime_language
    RUNTIME_LANGUAGES[runtime]
  end

  def runtime_version
    RUNTIME_VERSIONS[runtime]
  end

  def runtime_tab_size
    RUNTIME_TAB_SIZES[runtime]
  end

  def as_json(options = {})
    super(options).merge({
      runtime_name: runtime_name,
      runtime_language: runtime_language,
      runtime_version: runtime_version,
      runtime_tab_size: runtime_tab_size,
      code_with_template: code_with_template(use_public_template: true),
      disable_first_line_editing: disable_first_line_editing?,
      disable_final_line_editing: disable_final_line_editing?,
    })
  end

private

  def code_as_zip_file
    stringio = Zip::OutputStream.write_buffer do |out|
      out.put_next_entry("#{MODULE_NAME}.#{file_extension}")
      out.write(code_with_template)
    end
    stringio.rewind
    stringio
  end

  def file_extension
    case runtime
    when "python2.7"
      "py"
    when "java8"
      "java"
    else
      "js"
    end
  end

  def disable_first_line_editing?
    true
  end

  def disable_final_line_editing?
    runtime_language == "javascript" || runtime_language == "java"
  end

  def code_with_template(use_public_template: false)
    filename = "template.erb.#{file_extension}"
    filename = "public_#{filename}" if use_public_template
    read_template(filename)
  end

  def set_defaults
    self.remote_id = "function_#{SecureRandom.urlsafe_base64(40)}"
    self.memory_size ||= 128
    self.timeout ||= 3
    self.private ||= false
    self.code ||= default_code_template
  end

  def default_code_template
    read_template("default_template.erb.#{file_extension}")
  end

  def read_template(filename)
    file_contents = File.read(Rails.root.join("app/views/lambda_templates/#{filename}"))
    erb_binding = binding
    erb_binding.local_variable_set(:code, code) if code
    erb_binding.local_variable_set(:name, name) if name
    ERB.new(file_contents).result(erb_binding).strip
  end
end
