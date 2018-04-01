# frozen_string_literal: true

require_relative './lib/rabbit_mq'

logger = RabbitMQ::LoggerFactory.build
observer = RabbitMQ::Observer.new(logger)
worker = RabbitMQ::Worker.new(logger)
worker.add_observer(observer)
worker.run
