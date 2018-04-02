# frozen_string_literal: true

module RabbitMQ
  module Queue
    class << self
      def worker
        RabbitMQ::Connection.channel
          .queue('my-queue.worker',
                 durable: true,
                 arguments: {
                   'x-dead-letter-exchange' => "#{ENV.fetch('RABBITMQ_PREFIX')}-exchange.dead",
                   'x-message-ttl' => 20_000
                 })
      end
    end
  end
end
