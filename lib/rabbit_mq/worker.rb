# frozen_string_literal: true

module RabbitMQ
  class Worker
    attr_reader :logger, :observers

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
                 'x-message-ttl' => 20000
               })
    end

    def run
      RabbitMQ::Sinbin.setup(logger: logger, max_retries: 6, sinbin_ttl: 1000)
      channel.prefetch(1)
      puts ' [*] Waiting for messages. To exit press CTRL+C'

      begin
        queue
          .subscribe(manual_ack: true, block: true) do |delivery_info, properties, payload|
          logger.info " [x] Received message"
          logger.info ' [x] Notifying observers'
          notify_observers(delivery_info, properties, payload)
          logger.info ' [x] Done, ack message'
          channel.ack(delivery_info.delivery_tag)
        rescue StandardError => error
          logger.error "#{self.class.name} -> #{error.class}: #{error.message}" \
            'Publishing to retry exchange.'
          RabbitMQ::Publisher.retry_exchange(payload)
        end
      rescue Interrupt => _
        RabbitMQ::Connection.close
      end
    end

    def retry_or_dead(payload)
      properties = increment_message_count(payload)
      logger.info "#{self.class.name}: delivery_count = #{payload[:delivery_count]} for #{body}"
      if exceeded_max_retries?(payload)
        logger.info "#{self.class.name}: delivery_count exceeded max_retries of #{max_retries}" \
          'publishing to dead queue'
        RabbitMQ::Publisher.dead(payload)
      else
        logger.info "#{self.class.name}: publishing to retry for #{retry_ttl}"
        RabbitMQ::Publisher.retry_exchange(payload)
      end
    end

    def exceeded_max_retries?(payload)
      payload[:delivery_count] > max_retries
    end

    def increment_message_count(payload)
      if payload.key?(:delivery_count)
        payload[:delivery_count] += 1
      else
        payload[:delivery_count] = 0
      end
    end
  end
end
