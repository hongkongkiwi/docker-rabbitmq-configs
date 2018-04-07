# RabbitMQ on Docker

An example of a RabbitMQ instance running on Docker with custom configuration. This can be loaded with Docker or Docker Compose.

This is designed as a tutorial and template that you can customise and extend for the implementation you desire.

This Readme will cover:  
- Useful docker commands
- RabbitMQ key concepts
- How the configuration files in the `rabbitmq` folder configure the RabbitMQ instance
- Using docker and docker-compose to run and remove the RabbitMQ images and containers
- How to use the RabbitMQ UI to view, create and delete exchanges, queues, bindings
- How to configure work, dead and retry exchanges and queues

## Docker

Useful commands:  
- `docker ps` view running containers
- `docker ps -a` view all containers, including stopped ones
- `docker rm [CONTAINER]` Removes a container
- `docker images` lists images
- `docker image rm [IMAGE]`

There are scripts in the `bin` folder to build, run, stop and remove containers and images. See how to use them below.

## RabbitMQ key concepts

- [www.rabbitmq.com AMQP Concepts](https://www.rabbitmq.com/tutorials/amqp-concepts.html)
- [www.rabbitmq.com AMQP Quick Reference Guide](https://www.rabbitmq.com/amqp-0-9-1-quickref.html)
- [www.rabbitmq.com Get Started](https://www.rabbitmq.com/getstarted.html)
- [www.rabbitmq.com Documentation](https://www.rabbitmq.com/documentation.html)
- [www.cloudamqp.com blog RabbitMQ for Beginners: What is RabbitMQ?](https://www.cloudamqp.com/blog/2015-05-18-part1-rabbitmq-for-beginners-what-is-rabbitmq.html)

## rabbitmq folder

This contains the `definitions.json` and `rabbitmq.conf` files that are loaded into the RabbitMQ instance. The configuration be overwritten directly in the files. Alternatively log into RabbitMQ UI at localhost:15672, amend then `Export definitions` with
Filename for download: `definitions.json` from the `Overview` tab and save them into this folder. The current configuration creates:  
- Admin user with username `me` and password `me` (use this to log into the RabbitMQ UI at localhost:15672)
- Exchanges: `work` (with routing key 'work'), `retry` and `dead`
- Queues: `work`, `retry` and `dead`
- Bindings for queues to exchanges

See below for more detail on the configuration of the bindings and arguments for the exchanges and queues.

# RabbitMQ Docker

There are bash scripts in the `bin` folder to:  
- `run.sh` - This will stop and remove existing `rabbitmq-docker` images and container, then build a new image and run the container `rabbitmq-docker`
- `build.sh` - builds the image `rabbitmq-docker` using the Dockerfile
- `stop.sh` - stops the container `rabbitmq-docker`. It takes an optional `--silent` flag if you don't want it to log output, eg `bin/stop --silent`.
- `remove.sh` - stops and removes the `rabbitmq-docker` containers and images. It also has an optional `--silent` flag if you don't it them to log output, eg `bin/remove --silent`.  

The `Dockerfile` will create an image from `rabbitmq:3.7.3-management` and loads the configuration defined in the `rabbitmq` folder.  
```
COPY ./rabbitmq/rabbitmq.conf ./etc/rabbitmq/rabbitmq.conf
COPY ./rabbitmq/definitions.json ./etc/rabbitmq/definitions.json
```

## Docker Compose

This uses the `docker-compose.yml`, which also uses the image `rabbitmq:3.7.3-management` and loads the `definitions.json` and `rabbitmq.conf` files into the container.

#### Docker Compose terminal commands  
- `docker-compose up` Start the RabbitMQ instance with docker-compose    
- `docker-compose up -d` Start RabbitMQ on docker to run without logging to the current terminal session  
- `docker-compose down -v` To shut down the RabbitMQ instance and remove the volumes (the `definitions.json` and `rabbitmq.conf` configuration files)
- `docker-compose logs rabbitmq-docker` View the logs  
- `docker-compose logs --follow rabbitmq-docker` To view logs and follow output  

You can also use the `bin` scripts to stop and remove the containers and images here too.
- `bin/remove.sh` - Stops and removes the rabbitmq-docker container and image
- `bin/stop.sh` - will just stop the rabbitmq-docker container

## Configuration

Open the `definitions.json` file and replace the names of user, vhost, exchanges, queues and bindings with the ones you need.

It can be easier to use the RabbitMQ UI to configure these  
- Log into RabbitMQ UI at `localhost:15672` using the login `me` for username and password (the default is `guest` if you are not using the `definitions.json` file in the `rabbitmq` folder)
- amend the configuration
- On the `Overview` tab, click on `Export definitions` and set `Filename for download: definitions.json`, and then `Dowload broker definitions` and save them into the `rabbitmq` folder

## RabbitMQ UI

### Logging in
- Create and run the RabbitMQ instance using Docker or Docker Compose
- login at `localhost:15672`
- username and password are set in the `definitions.json`, currently "me" and "me"

### Publishing messages

This configuration shows you how to use exchanges and queues with three main purposes:
- `work` the main exchange and queue that an application would consume messages from.
- `retry` publish a message here for it to wait for the time to live before routing the message to the `work` exchange. This is useful if a message throws an error or cannot be consumed at the time the message is fetched from the `work` queue.
- `dead` a place to store messages that could not be delivered or have expired their time to live on the `work` queue.

#### The work exchange and queue

- Click on the `Exchanges` tab to view exchanges. The ones defined in `rabbitmq/definitions.json` should be listed
- Publish a message on `my-exchange.work` exchange with routing key: "work"  
- Click on the queues tab.
- `my-queue.work` should show a spike of activity and the message count should increase by 1 for the configured time to live value (currently set at 5 seconds).
- After the time to live has expired, the message will be considered dead
- It will be routed to the dead letter exchange: `my-exchange.dead`
- This places the message in the queue `my-queue.dead`
- `my_queue.dead`should show an additional message. View it by clicking on the queue, then `Get messages` -> `Get messages`

#### The retry exchange and queue
- Click on the `Exchanges` tab, then click on the `my-exchange.retry` exchange
- Publish a message on `my-exchange.retry` exchange with routing key: "work"  
- Click on the queues tab. The `my-queue.retry` message count should increase by 1 for the configured time to live value (currently set at 5 seconds).
- After the time to live has expired, the message will be routed to the `my-exchange.work`
- This places the message in the queue `my-queue.work` for the time to live, before routing to the `my-exchange.dead`, which sends it to `my-queue.dead`

#### Un-routed messages
- Publish a message on `my-exchange.work` without a routing key or one not defined in the configuration.
- This should be routed to `my-queue.dead`

Below explains how to set up these exchanges, queues and bindings.

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
