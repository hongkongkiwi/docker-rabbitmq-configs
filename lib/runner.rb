# frozen_string_literal: true

require_relative 'rabbit_mq'
require_relative 'worker_observer'

logger = RabbitMQ::LoggerFactory.build
parser = RabbitMQ::JSONParser
worker = RabbitMQ::Worker.new(logger, parser)
observer = RabbitMQ::WorkerObserver.new(logger)
worker.add_observer(observer)
worker.run
