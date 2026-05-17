# Start Java Backend
$ErrorActionPreference = "Continue"
$WorkingDir = "c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-java"

Write-Host "Starting Java Backend in $WorkingDir..."

# Start Maven Spring Boot in a new window
Start-Process -FilePath "mvn" -ArgumentList "spring-boot:run", "-DskipTests" -WorkingDirectory $WorkingDir -WindowStyle Normal

Write-Host "Backend starting... Waiting 60 seconds for startup..."
Start-Sleep -Seconds 60

# Check if backend is running
try {
    $response = Invoke-WebRequest -Uri "http://192.168.31.72:8080/api/health" -TimeoutSec 5 -ErrorAction Stop
    Write-Host "Backend is running! Response: $($response.Content)"
} catch {
    Write-Host "Backend may still be starting or not accessible. Error: $($_.Exception.Message)"
}

Write-Host "Done!"
