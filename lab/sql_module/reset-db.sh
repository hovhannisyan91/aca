#!/usr/bin/env bash

set -e  # Exit immediately if any command fails

echo "Stopping containers..."
docker compose down

echo "Removing Postgres data directory..."
rm -rf ./postgres_data

echo "Removing Postgres data directory..."
rm -rf ./pgadmin_data

echo "Starting containers..."
docker compose up

echo "Database reset complete. Init scripts reran successfully."

