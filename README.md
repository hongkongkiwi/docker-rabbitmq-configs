# rabbitmq-docker-compose

An example of a RabbitMQ with custom configuration loaded with docker-compose

This is designed as a tutorial and boilerplate that you can customise and extend for the setup you desire.

There are instructions for using it via the RabbitMQ UI, as well as ruby module that allows you to send messages and process them.

## Configuration

Open the definitions.json file and replace the names of user, my_vhost, exchanges and queues with the ones you need.

## Command line

In one tab:
- `docker-compose up`
This will spin up the RabbitMQ instance and display its logs

In the second tab:
- `ruby runner.rb`
This will start the worker that will consume from `my-queue`, log messages in the terminal acknowledge the messages have been received so RabbitMQ can remove them from the queue once processed.

In the third tab:
- `pry` / `irb`
- `require 'lib/rabbit_mq'`
- `RabbitMQ::Publisher.publish` + YOUR MESSAGE OR PAYLOAD
This will send the message to `my-exchange`, which will route it to `my-queue` with the routing key `test`.

See below for more on the configuration of the exchanges and queues.

## RabbitMQ UI

`docker-compose up`

login at localhost:15672

username and password are set in the definitions.json, currently "me" and "me"

Click on the exchanges tab to view exchanges. The ones defined in definitions.json should be listed.

Publish a message on "my_exchange" with routing key: "test"  

Click on the queues tab.

`my_queue` should show a spike of activity as it received the message.

After the time to live value (set as 10000, equivalent to 10 seconds):
- The message will be considered dead
- It will be routed to the dead letter exchange: `my-exchange.dead`
- This places the message in the queue `my_queue.dead`

`my_queue.dead`should show an additional message

Publish a message on "my_exchange" with no routing key.  
This should be listed in the unrouted queue

Below explains how to set up these exchanges, queues and bindings. Either use the UI or amend the definitions.json file.

### The main exchange and queue

Create an exchange "my-exchange". One of the simplest ways of routing is using a direct type exchange, where you define the "routing_key" in the bindings when linking the exchange to a queue. So for this example, specify the type as "direct".

Define a queue, such as "my-queue", then the bindings between them with the source being the exchange and the destination the queue. The destination_type is queue. Then in the arguments state the routing key, for example `"routing_key":"test"`

### Dead letter exchange and queue

- On your main queue, eg `my_queue`, add arguments
    - "x-dead-letter-exchange": "my-exchange.dead"
    - "x-message-ttl": 10000

`x-message-ttl` is the variable that stores the amount of time a message should be kept on a queue before being considered dead and routed to the `dead-letter-exchange`

- Define your dead letter exchange, eg "my-exchange.dead", and set it as type fanout
- Define your dead letter queue, eg `my_queue.dead`
- Bind the dead letter exchange to the dead letter queue

### Unrouted exchange and queue

To create an exchange and queue for messages that cannot be routed due to not having a defined routing key or headers:
- Add as an argument to your main exchange: `"alternate-exchange": "my-exchange.unrouted"`
- Define your unrouted exchange as a fanout exchange
- Define an unrouted queue
- bind your unrouted exchange to your unrouted queue

## Further Development

- Write up setting up a RabbitMQ instance on Docker with a vhost, exchanges, queues and bindings
- Creating a reusable Publisher that can publish to various exchanges and queues
- Creating a Consumer, including acknowledgements, rejects, re-queuing, and retry counts
- Extracting message processing out of the worker using Observers
- Extracting definitions from a config yml file
- Use Environment variables for username, password, connections string, setting defaults, etc
- Prefetch

Documentation  

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
