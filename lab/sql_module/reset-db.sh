#!/usr/bin/env bash

set -e  # Exit immediately if any command fails

echo "Stopping containers..."
docker compose down -v

echo "Removing Postgres data directory..."
rm -rf ./postgres_data


echo "Starting containers..."
docker compose up --build

echo "Database reset complete. Init scripts reran successfully."

