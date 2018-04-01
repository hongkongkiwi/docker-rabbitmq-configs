# frozen_string_literal: true

require 'logger'

module RabbitMQ
  module LoggerFactory
    extend self

    def build(output: $stdout,
              sync_output: true,
              log_level: Logger::INFO)
      output.sync = sync_output
      logger = Logger.new(output)
      logger.level = log_level
      logger
    end
  end
end
