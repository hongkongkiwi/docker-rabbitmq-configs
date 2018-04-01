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

    def close
      @connection.close
    end

    def connection_string
      # https://www.rabbitmq.com/uri-spec.html
      'amqp://me:me@localhost/my-vhost'
    end
  end
end
