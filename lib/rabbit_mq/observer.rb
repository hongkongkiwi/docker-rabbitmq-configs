# frozen_string_literal: true

module RabbitMQ
  class Observer
    attr_reader :logger

    def initilize(logger)
      @logger = logger
    end

    def update(delivery_info, properties, body)
      logger.info "Received message: #{delivery_info} #{properties} #{body}"
    end
  end
end
