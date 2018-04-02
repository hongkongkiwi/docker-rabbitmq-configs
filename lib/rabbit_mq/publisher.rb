# frozen_string_literal: true

require 'bunny'

module RabbitMQ
  module Publisher
    class << self
      def channel
        RabbitMQ::Connection.channel
      end

      def default_exchange(payload, routing_key = 'test')
        channel
          .direct(
            'my-exchange',
            durable: true,
            arguments: {
              'alternate-exchange' => "#{ENV.fetch('RABBITMQ_PREFIX')}-exchange.dead"
            }
          ).publish(
            format_payload(payload),
            routing_key: routing_key,
            persistent: true
          )
      end

      def retry(payload, routing_key = 'test')
        channel
          .fanout(
            "#{ENV.fetch('RABBITMQ_PREFIX')}-exchange.retry",
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
end
