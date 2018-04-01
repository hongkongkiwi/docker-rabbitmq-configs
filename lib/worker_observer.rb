# frozen_string_literal: true

require_relative 'rabbit_mq'

module RabbitMQ
  class WorkerObserver < RabbitMQ::Observer
    def update(delivery_info, properties, payload)
      super(delivery_info, properties, payload)

      if payload.is_a?(Hash) && payload.key?('message')
        logger.info "+-----------------------------------+
                     | SUCCESS #{payload['message']}     |
                     +-----------------------------------+"
      else
        raise "#{self.class.name}: payload must have a message"
      end
    end
  end
end
