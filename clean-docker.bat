@echo off
echo  Deteniendo y limpiando contenedores...
docker compose down

echo ¡BORRANDO TODO! (Cache de build, imagenes huerfanas y volumenes)...
docker builder prune -f
docker image prune -f
docker volume prune -f

echo  Entorno Docker limpio.
pause