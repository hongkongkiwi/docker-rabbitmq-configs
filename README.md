# RabbitMQ on Docker

An example of a RabbitMQ with custom configuration loaded with Docker or Docker Compose

This is designed as a tutorial and boilerplate that you can customise and extend for the setup you desire.

There are instructions for using it via the RabbitMQ UI, as well as ruby module that allows you to send messages and process them.

## Docker

Useful commands:  
- `docker ps` view running containers
- `docker ps -a` view all containers, including stopped ones
- `docker rm [CONTAINER]` Removes a container
- `docker images` lists images
- `docker image rm [IMAGE]`

There are scripts in the `bin` folder to build, run, stop and remove containers and images. See how to use them below.

## Docker compose

To start RabbitMQ on docker  

- `docker-compose up`

To start RabbitMQ on docker to run without logging to the current terminal session

- `docker-compose up -d`

To shut down RabbitMQ on docker  

- `docker-compose down -v`

There are bash scripts in the `bin` folder to stop and remove the containers and images if you prefer. They both take a `--silent` flag if you don't want them to log output, eg `bin/remove --silent`.  
- bin/remove.sh - Stops and removes the rabbitmq-docker container and image
- bin/stop.sh - will just stop the rabbitmq-docker container

View the logs  

- `docker-compose logs rabbitmq-docker`

To view logs and follow output  

- `docker-compose logs --follow rabbitmq-docker`

# RabbitMQ Docker

Build and run: `./bin/run.sh`  

To just build it: `./bin/build.sh`  

This loads the configuration defined in the rabbitmq folder  

in the Dockerfile:
```
COPY ./rabbitmq/rabbitmq.conf ./etc/rabbitmq/rabbitmq.conf
COPY ./rabbitmq/definitions.json ./etc/rabbitmq/definitions.json
```

There are bash scripts in the `bin` folder to stop and remove the containers and images if you would rather not do this manually. They both take a `--silent` flag if you don't want them to log output, eg `bin/remove --silent`.  
- bin/remove.sh - Stops and removes the rabbitmq-docker container and image
- bin/stop.sh - will just stop the rabbitmq-docker container

## Configuration

Open the definitions.json file and replace the names of user, my_vhost, exchanges and queues with the ones you need.

## RabbitMQ UI

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

### Unrouted exchange and queue

To create an exchange and queue for messages that cannot be routed due to not having a defined routing key or headers:
- Add as an argument to your main exchange: `"alternate-exchange": "my-exchange.dead"`
- Define your unrouted exchange as a fanout exchange
- Define an unrouted queue
- bind your unrouted exchange to your unrouted queue

## Further Development

- Diagramming
- Key concepts, eg vhost is a host within a RabbitMQ instance, allowing multiple apps to use the same instance for different purposes, types of exchange etc

## Links

* https://medium.com/@thomasdecaux/deploy-rabbitmq-with-docker-static-configuration-23ad39cdbf39
* https://stackoverflow.com/questions/40280293/defining-a-queue-with-a-config-file-in-rabbitmq
* https://www.rabbitmq.com/configure.html
* https://devops.datenkollektiv.de/creating-a-custom-rabbitmq-container-with-preconfigured-queues.html
* https://www.cloudamqp.com/blog/2015-05-18-part1-rabbitmq-for-beginners-what-is-rabbitmq.html
* https://medium.com/@kiennguyen88/rabbitmq-delay-retry-schedule-with-dead-letter-exchange-31fb25a440fc
