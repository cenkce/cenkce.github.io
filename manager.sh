#!/usr/bin/env bash

IMAGE_NAME="nullcappone/jekyll"
PORT="4000"
CONTAINER_NAME="cenkce_blog"

log() {
  echo "$1"
}

check() {
    [ $? != 0 ] || echo "ok"
}

init(){
    STATUS=$(docker-machine status)

    case $STATUS in
        Running)
            log "docker-machine is restarting"
            docker-machine restart
            check
            ;;
        Stopping|Saved )
            log "docker-machine is starting"
            docker-machine start
            check
            ;;
        *)
            log "docker-machine is creating"
            docker-machine create -d virtualbox default
            check
    esac

    log "docker machine env"
    eval $(docker-machine env)
    check
}

generateCerts(){
    docker-machine regenerate-certs
}

ssh(){
    docker-machine -D ssh default
}

# @param port
test(){
    curl $(dockerip):$1
}

dockerip(){
    docker-machine ip 2> /dev/null
}

machineEnv(){
    eval $(docker-machine env)
}

containerip(){
    docker inspect --format='{{.NetworkSettings.IPAddress}}' $1
}

enter(){
    log "entering to container"
    docker exec -it $CONTAINER_NAME bash
}

start(){
    log "docker container is starting"
    docker run -it --rm -p $PORT:$PORT -v $(pwd):/srv/jekyll --name $CONTAINER_NAME $IMAGE_NAME
    check
}

stop(){
    docker stop $CONTAINER_NAME
}

build(){
    log "docker build is starting"
    docker build -t $IMAGE_NAME .
    check
}

push(){
    log "docker build is starting"
    docker push $IMAGE_NAME
    check
}

$*
