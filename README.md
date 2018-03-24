# rabbitmq-docker-compose

An example of a RabbitMQ with custom configuration loaded with docker-compose

This is designed as a tutorial and boilerplate that you can customise and extend for the setup you desire.

#### Configuration

Open the definitions.json file and replace the names of user, my_vhost, exchanges and queues with the ones you need.

#### Running the RabbitMQ

`docker-compose up`

login at localhost:15672

username and password are set in the definitions.json, currently "me" and "me"

Click on the exchanges tab to view exchanges. The ones defined in definitions.json should be listed.

Publish a message on "my_exchange" with routing key: "test"  

Click on the queues tab.

`my_queue` should show a spike of activity as it received the message.

After the time to live value (set as 1000):
- The message will be considered dead
- It will be routed to the dead letter exchange: `my-exchange.dead`
- This places the message in the queue `my_queue.dead`

`my_queue.dead`should show an additional message

#### Links

* https://medium.com/@thomasdecaux/deploy-rabbitmq-with-docker-static-configuration-23ad39cdbf39
* https://stackoverflow.com/questions/40280293/defining-a-queue-with-a-config-file-in-rabbitmq
* https://www.rabbitmq.com/configure.html
* https://devops.datenkollektiv.de/creating-a-custom-rabbitmq-container-with-preconfigured-queues.html
* https://www.cloudamqp.com/blog/2015-05-18-part1-rabbitmq-for-beginners-what-is-rabbitmq.html
