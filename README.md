#  Práctica Integral: Sistema de Gestión de Pedidos con Microservicios

##  Objetivo

Desarrollar un **sistema de gestión de pedidos completo** utilizando una **arquitectura de microservicios reactiva**, implementando:

- **Spring Boot**
- **Spring WebFlux**
- **Spring Data R2DBC**
- **Spring Cloud Config**

El sistema se compone de **3 microservicios**:

1.  **ms-config-server** → Servidor de configuración centralizada  
2.  **ms-productos** → API Reactiva (Gradle + Procedimientos Almacenados)  
3.  **ms-pedidos** → API Reactiva (Gradle + Comunicación WebClient)

---

##  1. Tecnologías Utilizadas

| Componente | Tecnología |
|-------------|-------------|
| **Proyecto** | Gradle (Groovy) |
| **Lenguaje** | Java 17+ |
| **Framework principal** | Spring Boot v3.x (ej. 3.5.7) |
| **Stack Reactivo** | Spring WebFlux + Spring Data R2DBC |
| **Base de Datos** | PostgreSQL |
| **Comunicación entre servicios** | WebClient (en lugar de Feign) |
| **Configuración centralizada** | Spring Cloud Config Server |


---

##  2. Configuración de Bases de Datos

Antes de ejecutar los servicios, debes crear las **bases de datos** y **ejecutar los scripts SQL**.

### 2.1 Creación de Bases de Datos

```sql
CREATE DATABASE db_productos_dev;
CREATE DATABASE db_productos_qa;
CREATE DATABASE db_productos_prd;

CREATE DATABASE db_pedidos_dev;
CREATE DATABASE db_pedidos_qa;
CREATE DATABASE db_pedidos_prd;
```

---

### 2.2 Creación de Tablas (R2DBC no usa ddl-auto)

####  Script para `db_productos_*`

```sql
CREATE TABLE productos (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(255),
    descripcion TEXT,
    precio NUMERIC(10, 2),
    stock INTEGER,
    activo BOOLEAN,
    fecha_creacion TIMESTAMP
);
```

#### Script para `db_pedidos_*`

```sql
CREATE TABLE pedidos (
    id BIGSERIAL PRIMARY KEY,
    cliente VARCHAR(255),
    fecha TIMESTAMP,
    total NUMERIC(10, 2),
    estado VARCHAR(50)
);

CREATE TABLE detalle_pedidos (
    id BIGSERIAL PRIMARY KEY,
    pedido_id BIGINT REFERENCES pedidos(id),
    producto_id BIGINT,
    cantidad INTEGER,
    precio_unitario NUMERIC(10, 2)
);
```

---

### 2.3 Creación de Procedimientos Almacenados (SP)

####  Función 1: `actualizar_stock`

```sql
CREATE OR REPLACE FUNCTION actualizar_stock(
    p_producto_id BIGINT,
    p_cantidad INTEGER
) RETURNS VOID AS $$
BEGIN
    UPDATE productos 
    SET stock = stock - p_cantidad
    WHERE id = p_producto_id;
END;
$$ LANGUAGE plpgsql;
```

####  Función 2: `productos_bajo_stock`

```sql
CREATE OR REPLACE FUNCTION productos_bajo_stock(
    p_minimo INTEGER
) RETURNS TABLE(
    id BIGINT,
    nombre VARCHAR,
    stock INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.id, p.nombre, p.stock
    FROM productos p
    WHERE p.stock < p_minimo AND p.activo = true;
END;
$$ LANGUAGE plpgsql;
```

---

##  3. Configuración del `config-repo`

El **ms-config-server** obtiene la configuración desde un **repositorio Git local** llamado `config-repo`.

### Pasos de configuración

1. Navegar a la carpeta del repositorio local:
  
  ```bash
   cd ruta/a/tu/SistemaDePedidos/config-repo
  ```

2. Inicializar el repositorio Git:

   ```bash
   git init
   ```

3. Agregar los archivos `.yml` (dev, qa, prd) y realizar el commit inicial:

  ```bash
   git add .
   git commit -m "Commit inicial de configuraciones"
   ```

---

###  Ejemplo: `ms-productos-dev.yml`

```yaml
server:
  port: 8081

spring:
  r2dbc:
    url: r2dbc:postgresql://localhost:5432/db_productos_dev
    username: postgres
    password: [TU_PASSWORD_POSTGRES]
    pool:
      enabled: true
  jpa:
    show-sql: true
```

---

###  Ejemplo: `ms-pedidos-dev.yml`

```yaml
server:
  port: 8082

spring:
  r2dbc:
    url: r2dbc:postgresql://localhost:5432/db_pedidos_dev
    username: postgres
    password: [TU_PASSWORD_POSTGRES]
    pool:
      enabled: true
  sql:
    init:
      mode: always 

ms-productos:
  url: http://localhost:8081
```

>  Las configuraciones de **qa** y **prd** son similares, cambiando solo los **puertos** y las **bases de datos**.

---

## 4. Ejecución del Sistema

El orden de ejecución es importante debido a las dependencias entre servicios.

### 🪩 Paso 1: Ejecutar **ms-config-server**

1. Abrir el proyecto `ms-config-server` en IntelliJ.  
2. Ejecutar `MsConfigServerApplication.java`.  
3. Verificar en navegador:  
   ```
   http://localhost:8888/ms-productos/dev
   ```
   → Debería mostrar el contenido YAML del entorno `dev`.

---

###  Paso 2: Ejecutar **ms-productos**

1. Abrir el proyecto `ms-productos`.  
2. Ejecutar `MsProductosApplication.java`.  
3. Verificar en consola: puerto `8081` (configurado por el Config Server).

---

###  Paso 3: Ejecutar **ms-pedidos**

1. Abrir el proyecto `ms-pedidos`.  
2. Ejecutar `MsPedidosApplication.java`.  
3. Verificar en consola: puerto `8082`.

---

##  5. Pruebas y Endpoints (Swagger)

| Servicio | URL Swagger |
|-----------|--------------|
| **ms-productos** | http://localhost:8081/swagger-ui.html |
| **ms-pedidos** | http://localhost:8082/swagger-ui.html |

---

###  Flujo de Prueba Completo

#### 1 Crear Producto

- **Endpoint:** `POST /api/productos`
- **Ejemplo JSON:**

```json
{
  "nombre": "Laptop Dell",
  "descripcion": "Laptop profesional",
  "precio": 3500.00,
  "stock": 10,
  "activo": true
}
```

---

#### 2 Crear Pedido

- **Endpoint:** `POST /api/pedidos`
- **Ejemplo JSON:**

```json
{
  "cliente": "Juan Pérez",
  "detallePedidos": [
    {
      "productoId": 1,
      "cantidad": 2,
      "precioUnitario": 3500.00
    }
  ]
}
```

 **Resultado:** `201 Created` → Pedido creado correctamente.

---

#### 3 Verificar Stock

- **Endpoint:** `GET /api/productos/1`
- **Resultado esperado:**  
  El stock del producto “Laptop Dell” debe bajar de **10 → 8**, demostrando que se ejecutó el SP `actualizar_stock`.

---

#### 4 Validación de Stock Insuficiente

- **Endpoint:** `POST /api/pedidos`
- **Ejemplo JSON:**

```json
{
  "cliente": "Juan Pérez",
  "detallePedidos": [
    {
      "productoId": 1,
      "cantidad": 50
    }
  ]
}
```

 **Resultado esperado:**  
`500 Internal Server Error` con mensaje:  
> "Stock insuficiente para el producto solicitado."

---

##  Estructura de Carpetas (Referencia)

```
SistemaDePedidos/
│
├── config-repo/
│   ├── ms-productos-dev.yml
│   ├── ms-productos-qa.yml
│   ├── ms-productos-prd.yml
│   ├── ms-pedidos-dev.yml
│   ├── ms-pedidos-qa.yml
│   └── ms-pedidos-prd.yml
│
├── ms-config-server/
│   └── src/main/java/.../MsConfigServerApplication.java
│
├── ms-productos/
│   └── src/main/java/.../MsProductosApplication.java
│
└── ms-pedidos/
    └── src/main/java/.../MsPedidosApplication.java
```

---


---
