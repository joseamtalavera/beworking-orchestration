c#!/bin/bash

# Script to fix dashboard dependencies in Docker container

echo "Installing dependencies in beworking-dashboard container..."

# Execute npm install inside the container
docker-compose exec beworking-dashboard npm install

echo "Restarting container..."
docker-compose restart beworking-dashboard

echo "Done! Check the logs with: docker-compose logs -f beworking-dashboard"
