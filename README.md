# rabbitmq-docker-compose

An example of a RabbitMQ with custom configuration loaded with docker-compose

This is designed as a tutorial and boilerplate that you can customise and extend for the setup you desire.

There are instructions for using it via the RabbitMQ UI, as well as ruby module that allows you to send messages and process them.

## Configuration

Open the definitions.json file and replace the names of user, my_vhost, exchanges and queues with the ones you need.

## Command line

In one tab:
- `bin/docker-compose.sh`
This will start the rabbitmq instance (called 'rabbit') and worker that will consume from `my-queue.worker`, log messages in the terminal acknowledge the messages have been received so RabbitMQ can remove them from the queue once processed.

In the second tab:
- `pry` / `irb`
- `require 'lib/rabbit_mq'`
- `RabbitMQ::Publisher.publish` + YOUR MESSAGE OR PAYLOAD
This will send the message to `my-exchange`, which will route it to `my-queue` with the routing key `test`.

See below for more on the configuration of the exchanges and queues.

## RabbitMQ UI

- `bin/docker-compose.sh`

login at localhost:15672

username and password are set in the definitions.json, currently "me" and "me"

Click on the exchanges tab to view exchanges. The ones defined in rabbitmq/definitions.json should be listed.

Publish a message on "my_exchange.worker" with routing key: "test"  

Click on the queues tab.

`my_queue.worker` should show a spike of activity as it received the message.

After the time to live value (set as 10000, equivalent to 10 seconds):
- The message will be considered dead
- It will be routed to the dead letter exchange: `my-exchange.dead`
- This places the message in the queue `my_queue.dead`

`my_queue.dead`should show an additional message

Publish a message on "my_exchange" with no routing key.  
This should be listed in the `my_queue.dead` queue

Below explains how to set up these exchanges, queues and bindings. Either use the UI or amend the definitions.json file.

### The main exchange and queue

Create an exchange "my-exchange". One of the simplest ways of routing is using a direct type exchange, where you define the "routing_key" in the bindings when linking the exchange to a queue. So for this example, specify the type as "direct".

Define a queue, such as "my-queue", then the bindings between them with the source being the exchange and the destination the queue. The destination_type is queue. Then in the arguments state the routing key, for example `"routing_key":"test"`

### Dead letter exchange and queue

- On your main queue, eg `my_queue.worker`, add arguments
    - "x-dead-letter-exchange": "my-exchange.dead"
    - "x-message-ttl": 10000

`x-message-ttl` is the variable that stores the amount of time a message should be kept on a queue before being considered dead and routed to the `dead-letter-exchange`

- Define your dead letter exchange, eg "my-exchange.dead", and set it as type fanout
- Define your dead letter queue, eg `my-queue.dead`
- Bind the dead letter exchange to the dead letter queue

### Retry exchange and queue

- Create `my-queue.retry` queue bound to `my-exchange.retry`
- Create exchange `my-exchange.retry` with arguments:
  - Set `x-dead-letter-exchange` to `my-exchange.worker`
  - Set `x-message-ttl` to a retry-ttl variable, eg 300000 ms (5 minutes)

- When you have an issue with a message from `my-queue`
  - nack the message `channel.nack(delivery_info.delivery_tag)`
  - then publish to the `my-exchange.retry`
  - after the retry-ttl, it will be sent to `my-exchange.worker`, then `my-queue`

- To stop an infinite loop, you need to include a publish_count with a maximum value.
  - Ensure you parse the payload, eg if it is JSON
  - if your payload is a hash, you can do payload['publish_count'] = 1, then increment it for subsequent times
  - if publish_count reached the maximum value, nack the message to send it to the dead queue

### Unrouted exchange and queue

To create an exchange and queue for messages that cannot be routed due to not having a defined routing key or headers:
- Add as an argument to your main exchange: `"alternate-exchange": "my-exchange.dead"`
- Define your unrouted exchange as a fanout exchange
- Define an unrouted queue
- bind your unrouted exchange to your unrouted queue

## Further Development

- Extracting definitions from a config yml file
- Use Environment variables for queue names, username, password, setting defaults, etc
- Purging and destroying queues on close of connection
- Prefetch variable
- variables for worker_ttl and retry_ttl

Documentation  

- Use nack to send to dead queue
- Use ack for successfully consumed message
- Use nack when republishing from consumer, eg to retry queue, otherwise it will leave message `unacked` on a queue
- Write up setting up a RabbitMQ instance on Docker with a vhost, exchanges, queues and bindings
- Publisher that can publish to various exchanges
- Creating a Consumer, including acknowledgements, rejects, re-queuing, and retry counts
- Extracting message processing out of the worker using Observers
- How to use the ruby RabbitMQ module with the connection, publisher and worker
- Diagramming
- Key concepts, eg vhost is a host within a RabbitMQ instance, allowing multiple apps to use the same instance for different purposes, types of exchange etc
- Issues to note, eg connecting to queues and exchanges with the same configuration that is in the RabbitMQ instance

## Links

* https://medium.com/@thomasdecaux/deploy-rabbitmq-with-docker-static-configuration-23ad39cdbf39
* https://stackoverflow.com/questions/40280293/defining-a-queue-with-a-config-file-in-rabbitmq
* https://www.rabbitmq.com/configure.html
* https://devops.datenkollektiv.de/creating-a-custom-rabbitmq-container-with-preconfigured-queues.html
* https://www.cloudamqp.com/blog/2015-05-18-part1-rabbitmq-for-beginners-what-is-rabbitmq.html
* https://medium.com/@kiennguyen88/rabbitmq-delay-retry-schedule-with-dead-letter-exchange-31fb25a440fc
