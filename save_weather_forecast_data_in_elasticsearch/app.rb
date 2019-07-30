require 'json'

def lambda_handler(event:, context:)
  display_message(200, "OK")
rescue => error
  display_message(400, error.message)
end

def display_message(status_code, message)
  {
    statusCode: status_code,
    body: {
      message: message
    }.to_json
  }
end
