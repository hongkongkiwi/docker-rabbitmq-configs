# frozen_string_literal: true

require_relative 'rabbit_mq'

module RabbitMQ
  class WorkerObserver < RabbitMQ::Observer
    def update(delivery_info, properties, payload)
      super(delivery_info, properties, payload)
      payload_error unless payload.key?('message')
      logger.info "====! SUCCESS #{payload['message']} !===="
    end

    def payload_error
      raise "#{self.class.name}: payload must have a message"
    end
  end
end
