# PactTodo
Simple iOS Swift project for playing with Pact. Nothing fancy with UI yet

## Server
Project uses [Simple webapi server](https://github.com/typicode/json-server)
Run it using following command:

`$ json-server --watch db.json --routes routes.json`

Todos service will be available at:

`http://localhost:3000/todos/`

## Pact integration

To be able to create pact contracts, install Pact tools via

`$ brew install pact-ruby-standalone`

### Pact mock service

For launching and stopping Pact mock service `Scripts/start_service.sh` and `Scripts/stop_service.sh` is used
PactTodo scheme invokes them using Test Pre- and Post- Actions

## PactBroker

We are using Pact broker service hosted in the docker container. To configure and run it use following commands:

```bash
# Run the postgres container
docker run \
    --name pactbroker-db \
    -e POSTGRES_PASSWORD=ThePostgresPassword \
    -e POSTGRES_USER=admin \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
    -v /var/lib/postgresql/data:/var/lib/postgresql/data \
    -d postgres


# connect to psql in the postgres container
docker run \
    -it \
    --link pactbroker-db:postgres \
    --rm postgres \
    sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U admin'


# Create pactbroker DB user and grant some access to him
CREATE USER pactbrokeruser WITH PASSWORD 'TheUserPassword';
CREATE DATABASE pactbroker WITH OWNER pactbrokeruser;
GRANT ALL PRIVILEGES ON DATABASE pactbroker TO pactbrokeruser;

# Run the pactbroker server
docker run \
    --name pactbroker \
    --link pactbroker-db:postgres \
    -e PACT_BROKER_DATABASE_USERNAME=pactbrokeruser \
    -e PACT_BROKER_DATABASE_PASSWORD=TheUserPassword \
    -e PACT_BROKER_DATABASE_HOST=postgres \
    -e PACT_BROKER_DATABASE_NAME=pactbroker \
    -d  \
    -p 9292:9292 \
    pactfoundation/pact-broker
```

Some examples how to work with the Pact Broker

```bash
# Publish Pact file
curl -v -X PUT \
    -H "Content-Type: application/json" \
    -T tmp/pacts/todosclient-todosapi.json \
    http://localhost:9292/pacts/provider/TodosAPI/consumer/TodosClient/version/0.0.1

# Get all participants
curl --location --request GET 'http://localhost:9292/pacticipants' \
--header 'Content-Type: application/json'

# Get concrete Pact
curl --location --request GET 'http://localhost:9292/pacts/provider/TodosAPI/consumer/TodosClient/version/2.0.0' \
--header 'Content-Type: application/json' 
```
