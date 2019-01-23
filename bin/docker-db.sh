#!/usr/bin/env bash

docker run --name local-postgres -p5432:5432 -e POSTGRES_PASSWORD=root postgres:9 || docker container start local-postgres
