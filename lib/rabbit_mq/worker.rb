# frozen_string_literal: true

module RabbitMQ
  class Worker
    include SimpleObservable
    attr_reader :logger, :parser, :max_retries

    def initialize(logger, parser, max_retries = 5)
      @logger = logger
      @parser = parser
      raise 'max_retries cannot be less than 1' if max_retries < 1
      @max_retries = max_retries
    end

    def channel
      RabbitMQ::Connection.channel
    end

    def run
      channel.prefetch(1)
      logger.info ' [*] Waiting for messages. To exit press CTRL+C'
      RabbitMQ::Queue.worker
        .subscribe(
          manual_ack: true, block: true
        ) do |delivery_info, properties, payload|
        execute(delivery_info, properties, payload)
      end
    rescue Interrupt => _
      RabbitMQ::Connection.close
    end

    def execute(delivery_info, properties, payload)
      logger.info ' [x] Received message, parsing payload...'
      payload = parser.parse(payload)
      logger.info " [x] Parsed paylod: #{payload}"
      notify_observers(delivery_info, properties, payload)
      logger.info ' [x] Done, ack message'
      channel.ack(delivery_info.delivery_tag)
    rescue RabbitMQ::MessageError => error
      log_error(error)
      logger.info "#{self.class.name} publishing to dead queue: #{payload}"
      channel.nack(delivery_info.delivery_tag)
    rescue StandardError => error
      log_error(error)
      retry_message(delivery_info, properties, payload)
    end

    def log_error(error)
      logger.error "#{self.class.name} #{error.class} #{error.message}"
      logger.debug error.backtrace.join("\n\t").to_s
    end

    def retry_message(delivery_info, properties, payload)
      payload = increment_message_count(payload)
      if (payload['delivery_count'] > max_retries)
        logger.info "#{self.class.name}" \
          " delivery_count exceeded max_retries of #{max_retries};" \
          ' publishing to dead queue'
        channel.nack(delivery_info.delivery_tag)
      else
        logger.info "#{self.class.name} publishing to retry exchange"
        channel.ack(delivery_info.delivery_tag)
        RabbitMQ::Publisher.retry(payload)
      end
    end

    def check_max_retries(delivery_info, properties, payload)
      return if (payload['delivery_count'] < max_retries)
      logger.info "#{self.class.name}" \
        " delivery_count exceeded max_retries of #{max_retries};" \
        ' publishing to dead queue'
      channel.nack(delivery_info.delivery_tag)
    end

    def increment_message_count(payload)
      if payload.key?('delivery_count')
        payload['delivery_count'] += 1
      else
        payload['delivery_count'] = 1
      end
      logger.info "#{self.class.name}: " \
        "delivery_count = #{payload['delivery_count']} for #{payload}"
      payload
    end
  end
end
