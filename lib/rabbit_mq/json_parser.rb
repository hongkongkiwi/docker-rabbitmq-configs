# frozen_string_literal: true

require 'json'

module RabbitMQ
  module JSONParser
    extend self

    def parse(payload)
      JSON.parse(payload)
    rescue JSON::ParserError
      raise RabbitMQ::MessageInvalidError, 'JSON::ParserError Payload is not a hash'
    end
  end
end
