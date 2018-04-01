# frozen_string_literal: true

require 'logger'

module RabbitMQ
  module LoggerFactory
    extend self

    def build(output = $stdout,
              sync_output = true,
              log_level = Logger::INFO)
      output.sync = sync_output
      Logger.new(output).level(log_level)
    end
  end
end
