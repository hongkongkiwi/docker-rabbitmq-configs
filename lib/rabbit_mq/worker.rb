# frozen_string_literal: true

module RabbitMQ
  class Worker
    attr_reader :logger, :parser, :observers, :max_retries

    def initialize(logger, parser, max_retries = 5)
      @logger = logger
      @parser = parser
      raise 'max_retries cannot be less than 1' if max_retries < 1
      @max_retries = max_retries
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
      channel.prefetch(1)
      logger.info ' [*] Waiting for messages. To exit press CTRL+C'

      begin
        queue
          .subscribe(manual_ack: true, block: true) do |delivery_info, properties, payload|
          logger.info " [x] Received message"
          logger.info " [x] Parsing payload"
          payload = parser.parse(payload)
          logger.info ' [x] Notifying observers'
          notify_observers(delivery_info, properties, payload)
          logger.info ' [x] Done, ack message'
          channel.ack(delivery_info.delivery_tag)
        rescue StandardError => error
          handle_error(error, delivery_info, properties, payload)
        end
      rescue Interrupt => _
        RabbitMQ::Connection.close
      end
    end

    def handle_error(error, delivery_info, _properties, payload)
      logger.error "#{self.class.name}: #{error.class} #{error.message || ''}"
      logger.debug "#{error.backtrace.join("\n\t")}"
      if error.is_a? RabbitMQ::MessageError
        logger.info "#{self.class.name} RabbitMQ::MessageError publishing to dead queue: #{payload}"
        channel.nack(delivery_info.delivery_tag)
        return
      end
      increment_message_count(payload)
      if exceeded_max_retries?(payload)
        logger.info "#{self.class.name}:" \
          " delivery_count exceeded max_retries of #{max_retries};" \
          ' publishing to dead queue'
        channel.nack(delivery_info.delivery_tag)
      else
        logger.info "#{self.class.name}: publishing to retry exchange"
        channel.ack(delivery_info.delivery_tag)
        RabbitMQ::Publisher.retry(payload)
      end
    end

    def exceeded_max_retries?(payload)
      payload["delivery_count"] >= max_retries
    end

    def increment_message_count(payload)
      if payload.key?("delivery_count")
        payload["delivery_count"] += 1
      else
        payload["delivery_count"] = 1
      end
      logger.info "#{self.class.name}: " \
        "delivery_count = #{payload["delivery_count"]} for #{payload}"
    end
  end
end
