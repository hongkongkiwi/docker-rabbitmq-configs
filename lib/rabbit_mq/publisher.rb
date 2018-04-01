# frozen_string_literal: true

require 'bunny'

module RabbitMQ
  module Publisher
    extend self

    def publish(payload, routing_key = 'test')
      exchange.publish(
        payload,
        routing_key: routing_key,
        persistent: true
      )
    end

    def exchange
      @exchange ||= begin
          RabbitMQ::Connection.channel
                              .direct(
                                'my-exchange',
                                durable: true,
                                arguments: { 'alternate-exchange' => 'my-exchange.unrouted' }
                              )
        end
    end
  end
end
