# init-and-push-repos.ps1

# --- CONFIGURACIÓN ---
$GitHubUser = "Franksall"
$BaseRepoURL = "https://github.com/$GitHubUser"
$TargetBranch = "k8s-harbor"
$CommitMessage = "feat: Version Kubernetes (v3) lista para despliegue en Harbor."

# Lista de carpetas de microservicios que faltan por configurar en Git
$Microservices = @(
    "ms-authorization-server",
    "gateway-service",
    "ms-productos",
    "ms-pedidos"
)

# --- EJECUCIÓN ---
foreach ($ServiceDir in $Microservices) {
    Write-Host "--- Procesando Microservicio: $ServiceDir ---" -ForegroundColor Yellow

    # 1. Definir la URL de GitHub para este servicio
    $RepoURL = "$BaseRepoURL/$ServiceDir.git"
    $FullPath = Join-Path -Path $PSScriptRoot -ChildPath $ServiceDir

    if (-not (Test-Path $FullPath)) {
        Write-Host "ERROR: Directorio no encontrado: $FullPath" -ForegroundColor Red
        continue
    }

    # 2. Navegar a la carpeta
    Set-Location $FullPath

    # 3. Inicializar Git y Crear la Rama
    if (-not (Test-Path "$FullPath\.git")) {
        Write-Host "Inicializando repositorio Git..."
        git init | Out-Null
        git branch -M master
    } else {
        Write-Host "Repositorio ya inicializado."
        git checkout master | Out-Null
    }

    # 4. Crear la rama target si no existe y cambiar a ella
    git checkout -b $TargetBranch | Out-Null

    # 5. Añadir archivos (excluyendo archivos de compilación, si el .gitignore está bien)
    Write-Host "Añadiendo archivos..."
    git add . | Out-Null

    # 6. Commit
    $CommitResult = git commit -m "$CommitMessage"
    if ($CommitResult -match "nothing to commit") {
        Write-Host "No hay cambios nuevos para commit."
    } else {
        Write-Host "Commit creado."
    }

    # 7. Conectar y Subir
    if (-not (git remote get-url origin)) {
        Write-Host "Conectando al repositorio remoto: $RepoURL"
        git remote add origin $RepoURL
    }

    Write-Host "Subiendo rama '$TargetBranch' a GitHub..."
    # Usamos -f solo la primera vez para forzar la creación de la rama remota
    git push -u origin $TargetBranch -f

    Write-Host "--- $ServiceDir COMPLETO ---`n" -ForegroundColor Green
}