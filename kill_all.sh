docker kill $(docker ps -aq)
docker rm $(docker ps -aq)
docker network rm mynet