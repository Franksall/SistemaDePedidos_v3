@echo off
echo  Ejecutando pruebas de cobertura en TODOS los microservicios...

echo --- Probando ms-config-server ---
cd ms-config-server
call gradlew test
cd ..

echo --- Probando registry-service ---
cd registry-service
call gradlew test
cd ..

echo --- Probando ms-authorization-server ---
cd ms-authorization-server
call gradlew test
cd ..

echo --- Probando gateway-service ---
cd gateway-service
call gradlew test
cd ..

echo --- Probando ms-productos ---
cd ms-productos
call gradlew test
cd ..

echo --- Probando ms-pedidos ---
cd ms-pedidos
call gradlew test
cd ..

echo  ¡Todas las pruebas de cobertura han finalizado!
pause