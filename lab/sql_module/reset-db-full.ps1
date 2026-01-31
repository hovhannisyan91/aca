$ErrorActionPreference = "Stop"  # Exit immediately if any command fails
Write-Host "Stopping containers... and removing volumes..."
docker compose down -v
Write-Host "Removing Postgres data directory..."
Remove-Item -Recurse -Force .\postgres_data -ErrorAction SilentlyContinue
Write-Host "Removing Pgadmin data directory..."
Remove-Item -Recurse -Force .\pgadmin_data -ErrorAction SilentlyContinue
Write-Host "Starting containers..."
docker compose up
Write-Host "Database reset complete. Init scripts reran successfully."
Collapse

# powershell -ExecutionPolicy Bypass -File reset-db.ps1