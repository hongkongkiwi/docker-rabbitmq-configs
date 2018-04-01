# frozen_string_literal: true
require 'json'

module RabbitMQ
  class Observer
    attr_reader :logger

    def initialize(logger)
      @logger = logger
    end

    def update(delivery_info, properties, payload)
      log_confirmation(delivery_info, properties, payload)
      payload = JSON.parse(payload)
      if payload.key?('message')
        puts "
          +-------------------------------+
            SUCCESS! #{payload['message']}
          +-------------------------------+
        "
      else
        raise "#{self.class.name} No message key in payload."
      end
    rescue JSON::ParserError => e
      raise JSON::ParserError, "#{self.class.name} payload is not a hash."
    end

    def log_confirmation(delivery_info, properties, payload)
      logger.info "#{self.class.name} received message: " \
                  "delivery_info: #{delivery_info}; " \
                  "properties: #{properties}; " \
                  "payload: #{payload}."
    end
  end
end
