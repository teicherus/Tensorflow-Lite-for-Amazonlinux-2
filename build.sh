#!/bin/bash
docker build -t tflite_amazonlinux .
docker run -d --name=tflite_amazonlinux tflite_amazonlinux
docker cp tflite_amazonlinux:/usr/local/lib/python3.9/site-packages .
docker stop tflite_amazonlinux