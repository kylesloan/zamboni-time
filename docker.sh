#!/bin/bash
docker build -t rink-times .
docker run -it --rm \
  -v "$PWD":/mnt \
  rink-times
