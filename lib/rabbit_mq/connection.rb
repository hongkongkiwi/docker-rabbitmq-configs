# frozen_string_literal: true

require 'bunny'

module RabbitMQ
  module Connection
    extend self

    def channel(connection_uri = connection_string)
      @channel ||= begin
        Bunny.new(connection_uri)
             .start
             .create_channel
      end
    end

    def ack(delivery_info)
      channel.ack(delivery_info.delivery_tag)
    end

    def nack(delivery_info)
      channel.nack(delivery_info.delivery_tag)
    end

    def close
      channel.queue_delete(queue: 'my-queue')
      channel.queue_delete(queue: 'my-queue.invalid')
      channel.queue_delete(queue: 'my-queue.retry')
      channel.queue_delete(queue: 'my-queue.dead')
      @channel.close
    end

    def connection_string
      # https://www.rabbitmq.com/uri-spec.html
      'amqp://me:me@rabbit/my-vhost'
    end
  end
end
