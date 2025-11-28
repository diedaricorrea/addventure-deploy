# Script para generar una clave JWT segura
# Ejecutar con: .\generate-jwt-secret.ps1

Write-Host "🔐 Generando clave JWT segura..." -ForegroundColor Cyan
Write-Host ""

# Generar 64 bytes aleatorios y convertir a Base64
$bytes = New-Object byte[] 64
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$rng.GetBytes($bytes)
$jwtSecret = [Convert]::ToBase64String($bytes)

Write-Host "✅ Clave JWT generada:" -ForegroundColor Green
Write-Host ""
Write-Host $jwtSecret -ForegroundColor Yellow
Write-Host ""
Write-Host "📋 Copia esta clave y úsala como JWT_SECRET en tu servidor" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ejemplo en ~/.env_addventure:" -ForegroundColor Gray
Write-Host "JWT_SECRET=$jwtSecret" -ForegroundColor DarkGray
Write-Host ""

# Copiar al portapapeles si es posible
try {
    Set-Clipboard -Value $jwtSecret
    Write-Host "✅ Clave copiada al portapapeles" -ForegroundColor Green
} catch {
    Write-Host "⚠️  No se pudo copiar al portapapeles automáticamente" -ForegroundColor Yellow
}
