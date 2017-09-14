FROM elixir:1.5.1-slim
MAINTAINER Team Aegis <aegis@decisiv.com>

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && apt-get install -y --no-install-recommends apt-utils build-essential
RUN mix do local.hex --force, local.rebar --force
RUN mkdir /app
WORKDIR /app
ADD . /app

ENTRYPOINT ["mix"]
CMD ["do" "compile", "test"]

