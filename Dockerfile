FROM rabbitmq:3.6.11-alpine

ADD rabbitmq.config /etc/rabbitmq/
ADD definitions.json /etc/rabbitmq/

docker pull rabbitmq
docker run -d --hostname my-rabbit --name some-rabbit rabbitmq:3.6.11-management
