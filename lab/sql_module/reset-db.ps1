$ErrorActionPreference = "Stop"  # Exit immediately if any command fails
Write-Host "Stopping containers..."
docker compose down
Write-Host "Removing Postgres data directory..."
Remove-Item -Recurse -Force .\postgres_data -ErrorAction SilentlyContinue
Write-Host "Starting containers..."
docker compose up
Write-Host "Database reset complete. Init scripts reran successfully."
Collapse

# powershell -ExecutionPolicy Bypass -File reset-db.ps1
# տեստ