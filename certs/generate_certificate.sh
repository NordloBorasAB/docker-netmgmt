#! /bin/bash
openssl req -nodes -x509 -newkey rsa:4096 -keyout server.key -out server.crt -sha256 -days 3650
