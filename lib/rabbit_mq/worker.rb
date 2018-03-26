module RabbitMQ
  module Worker
    extend self

    def run
      channel = RabbitMQ::Connection.channel
      queue =
        channel
          .queue('my-queue',
                durable: true,
                arguments: {
          "x-dead-letter-exchange" => "my-exchange.dead",
          "x-message-ttl" => 10000
        }
      )

      channel.prefetch(1)
      puts ' [*] Waiting for messages. To exit press CTRL+C'

      begin
        queue
          .subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
          puts " [x] Received '#{body}'"
          # imitate some work
          sleep body.count('.').to_i
          puts ' [x] Done'
          channel.ack(delivery_info.delivery_tag)
        end
      rescue Interrupt => _
        RabbitMQ::Connection.close
      end
    end
  end
end
