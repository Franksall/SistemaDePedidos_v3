@echo off
echo  Deteniendo y limpiando contenedores
docker compose down

echo  Limpiando cache de build, imagenes y volumenes...
docker builder prune -f
docker image prune -f
docker volume prune -f

echo  Reconstruyendo y levantando todo el sistema...
docker compose up -d --build

echo  ¡Sistema limpio y levantado!
pause