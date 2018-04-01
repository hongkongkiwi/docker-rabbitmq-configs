# frozen_string_literal: true

module RabbitMQ
  class Observer
    attr_reader :logger

    def initialize(logger)
      @logger = logger
    end

    def update(delivery_info, properties, payload)
      log_confirmation(delivery_info, properties, payload)
    end

    def log_confirmation(delivery_info, properties, payload)
      logger.info "#{self.class.name} received message: " \
                  "delivery_info: #{delivery_info}; " \
                  "properties: #{properties}; " \
                  "payload: #{payload}."
    end
  end
end
