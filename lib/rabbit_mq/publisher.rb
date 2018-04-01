# frozen_string_literal: true

require 'bunny'

module RabbitMQ
  module Publisher
    extend self

    def channel
      RabbitMQ::Connection.channel
    end

    def default_exchange(payload, routing_key = 'test')
      channel
        .direct(
          'my-exchange',
          durable: true,
          arguments: { 'alternate-exchange' => 'my-exchange.unrouted' }
        ).publish(
          format_payload(payload),
          routing_key: routing_key,
          persistent: true
        )
    end

    def retry(payload, routing_key = 'test')
      channel
        .fanout(
          'my-exchange.retry',
          durable: true
        ).publish(
          format_payload(payload),
          routing_key: routing_key,
          persistent: true
        )
    end

    def format_payload(payload)
      payload.is_a?(Hash) ? payload.to_json : payload
    end
  end
end
