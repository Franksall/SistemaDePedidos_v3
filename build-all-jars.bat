@echo off
echo  Reconstruyendo los .JAR de TODOS los microservicios...
echo (Esto borrara las carpetas 'build' y las volvera a crear)
echo.

echo --- Construyendo ms-config-server ---
cd ms-config-server
call gradlew clean bootJar
cd ..

echo --- Construyendo registry-service ---
cd registry-service
call gradlew clean bootJar
cd ..

echo --- Construyendo ms-authorization-server ---
cd ms-authorization-server
call gradlew clean bootJar
cd ..

echo --- Construyendo gateway-service ---
cd gateway-service
call gradlew clean bootJar
cd ..

echo --- Construyendo ms-productos ---
cd ms-productos
call gradlew clean bootJar
cd ..

echo --- Construyendo ms-pedidos ---
cd ms-pedidos
call gradlew clean bootJar
cd ..

echo.
echo  ¡Todos los microservicios han sido empaquetados!
pause