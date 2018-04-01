# frozen_string_literal: true

module RabbitMQ
  class Worker
    attr_reader :observers

    def initialize(logger)
      @logger = logger
      @observers = []
    end

    def add_observer(observer)
      raise 'Observer must have an #update method' unless observer.respond_to?(:update)
      @observers << observer
    end

    def notify_observers(delivery_info, properties, body)
      observers.each do |observer|
        observer.update(delivery_info, properties, body)
      end
   end

    def channel
      RabbitMQ::Connection.channel
    end

    def queue
      channel
        .queue('my-queue',
               durable: true,
               arguments: {
                 'x-dead-letter-exchange' => 'my-exchange.dead',
                 'x-message-ttl' => 10_000
               })
    end

    def run
      channel.prefetch(1)
      puts ' [*] Waiting for messages. To exit press CTRL+C'

      begin
        queue
          .subscribe(manual_ack: true, block: true) do |delivery_info, properties, body|
          puts " [x] Received '#{body}'"
          puts ' [x] Notifying observers'
          notify_observers(delivery_info, properties, body)
          puts ' [x] Done'
          channel.ack(delivery_info.delivery_tag)
        end
      rescue Interrupt => _
        RabbitMQ::Connection.close
      end
    end
  end
end
