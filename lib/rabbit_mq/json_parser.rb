# frozen_string_literal: true

require 'json'

module RabbitMQ
  module JSONParser
    class << self
      def parse(payload)
        parsed_payload = JSON.parse(payload)
        raise JSON::ParserError unless parsed_payload.is_a?(Hash)
        parsed_payload
      rescue JSON::ParserError
        raise RabbitMQ::MessageError,
              'JSON::ParserError Payload is not a hash'
      end
    end
  end
end
