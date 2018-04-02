# frozen_string_literal: true

module RabbitMQ
  module SimpleObservable
    def observers
      @observers ||= []
    end

    def add_observer(observer)
      error = 'Observer must have an #update method'
      raise error unless observer.respond_to?(:update)
      observers << observer
    end

    def notify_observers(delivery_info, properties, body)
      observers.each do |observer|
        observer.update(delivery_info, properties, body)
      end
    end
  end
end
