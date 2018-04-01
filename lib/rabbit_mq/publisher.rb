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

    def retry_exchange(payload, routing_key = 'test')
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

    def retry(payload, sinbin_ttl = 5000)
      channel
        .queue('my-queue.retry',
               durable: true,
               arguments: {
                 'x-dead-letter-exchange' => 'my-exchange',
                 'x-message-ttl' => sinbin_ttl
               })
        .publish(
          format_payload(payload),
          persistent: true
        )
    end

    def invalid(payload)
      channel
        .queue('my-queue.invalid', durable: true)
        .publish(
          format_payload(payload),
          persistent: true
        )
    end

    def dead(payload)
      channel
        .queue('my-queue.dead', durable: true)
        .publish(
          format_payload(payload),
          persistent: true
        )
    end

    def format_payload(payload)
      payload.is_a?(Hash) ? payload.to_json : payload
    end
  end
end
