# frozen_string_literal: true

module RabbitMQ
  class Observer
    attr_reader :logger, :observer_name

    def initialize(logger, observer_name = 'RabbitMQ::Observer')
      @observer_name = observer_name
      @logger = logger
    end

    def update(delivery_info, properties, body)
      log_confirmation(delivery_info, properties, body)
    end

    def log_confirmation(delivery_info, properties, body)
      logger.info "#{observer_name} Received message: " \
                  "delivery_info: #{delivery_info}; " \
                  "properties: #{properties}; " \
                  "body: #{body}."
    end
  end
end
