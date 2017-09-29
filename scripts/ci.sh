#! /bin/bash -ex
cleanup () {
  docker images -q ex_decisiv_api_client:latest | xargs docker rmi
}
trap cleanup EXIT

docker build -t ex_decisiv_api_client:latest .
docker run --rm -e MIX_ENV=test ex_decisiv_api_client:latest ci
