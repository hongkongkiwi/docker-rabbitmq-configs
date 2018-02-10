# rabbitmq-docker-compose

An example of a RabbitMQ with custom configuration loaded with docker-compose

This is designed as a tutorial and boilerplate that you can customise and extend for the setup you desire.

#### Configuration

Replacing the "user", "my_vhost", "my_exchange", "my_queue" and "bindings" with the ones you need.

#### Running the RabbitMQ

`docker-compose up rabbit`

login at localhost:15672

username and password are set in the definitions.json, currently "me" and "me"

Publish a message on "my_exchange"

#### Extentions

As this is designed to be a tutorial, other ideas include:

* using the RabbitMQ 3.7 style configuration using a .conf file
* set up multiple queues and bindings with dead, sinbin, invalid, etc.
* using RABBITMQ_ environment variables for configuration, eg the RABBITMQ_URL
* using ENV.fetch
* Tutorials explaining each aspect of the config
* Tutorials explaining how the docker-compose file works, including the volumes section
* How to publish to the RabbitMQ manually and via ruby code.
* Links to other useful pages

#### Links

* https://medium.com/@thomasdecaux/deploy-rabbitmq-with-docker-static-configuration-23ad39cdbf39
* https://stackoverflow.com/questions/40280293/defining-a-queue-with-a-config-file-in-rabbitmq
* https://www.rabbitmq.com/configure.html
* https://devops.datenkollektiv.de/creating-a-custom-rabbitmq-container-with-preconfigured-queues.html
* https://www.cloudamqp.com/blog/2015-05-18-part1-rabbitmq-for-beginners-what-is-rabbitmq.html


