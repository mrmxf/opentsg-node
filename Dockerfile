# syntax=docker/dockerfile:1

##DOCKER_BUILDKIT=0 docker build -t open-tpg:run1 -f Dockerfile.multistage . --progress=plain
## Build
## We build our exe in this enviroment (if this was a multistage)
FROM golang:1.18.9 AS build

WORKDIR /app
ENV CGO_ENABLED=1

## Copy all needed files
COPY go.mod ./
COPY go.sum ./
COPY ./lib/ ./lib/
COPY ./verde_factory/ ./verde_factory/
COPY ./inc/ ./inc/
COPY ./vendor/ ./vendor/
COPY *.go ./


# Install a some dependencies for compiling with cgo
# This is required for the sth package
RUN apt-get update \
  && apt-get install -y sudo

RUN adduser --disabled-password --gecos '' docker
RUN adduser docker sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN sudo apt-get install libxml2 libxml2-dev -y
RUN sudo apt-get install -y pkg-config


##Export the library so the so is found
ENV LD_LIBRARY_PATH=/app/lib:$LD_LIBRARY_PATH

##Build open-tpg!
RUN go build -o /open-tpg

# The next sections are for when the image is called

## This entry point doesnot change
ENTRYPOINT ["/open-tpg", "--c"]

#This command can be changed with docker run open-tpg:run1 command
CMD ["./verde_factory/loader.json"]


#make it singlestage for the moment
#Running it as a multistage broke everything so I've left it as a larger image for the time being

# ##
# # ## Deploy
# # ## Take our exe over and just run that with as few frills as possible
# FROM gcr.io/distroless/base-debian11 

# WORKDIR /

# COPY --from=build /open-tpg /open-tpg
# COPY --from=build ./lib/ ./lib/

# ENV LD_LIBRARY_PATH=/lib:$LD_LIBRARY_PATH
# # #RUN ls /vendor/gitlab.com/mmTristan/msg-sth-writer/lib
# # #RUN echo $LD_LIBRARY_PATH


# ENTRYPOINT ["/open-tpg"]
