# 🏗️ Sistema de Pedidos v3 — Fundamentos Técnicos

Este documento resume los principios esenciales del **Sistema de Pedidos v3**, orientado a una arquitectura moderna basada en **microservicios reactivos**, **Spring WebFlux**, **PostgreSQL R2DBC**, y preparado para su despliegue en **Kubernetes**.

---

## 1. 🧩 Stack Tecnológico Central

## 0. 🗂️ Estructura de Archivos del Entorno Kubernetes (v3)

Todo tu despliegue en **Minikube/Kubernetes** se organiza en módulos claros que representan infraestructura, configuración centralizada, microservicios y parámetros externos cargados por el Config Server.

---

### ### 0.1 **00-infra (Infraestructura Principal)**

| Archivo                     | Contenido                          | Propósito                                                                 |
| --------------------------- | ---------------------------------- | ------------------------------------------------------------------------- |
| `database/postgres.yaml`    | Deployment + Service de PostgreSQL | Crea la base de datos relacional usada por `ms-productos` y `ms-pedidos`. |
| `harbor/harbor-values.yaml` | Configuración Helm para Harbor     | Define dominio, contraseñas y acceso por Ingress (`harbor.local.test`).   |

---

### ### 0.2 **01-config (Configuración Central)**

| Archivo              | Contenido                              | Propósito                                                                            |
| -------------------- | -------------------------------------- | ------------------------------------------------------------------------------------ |
| `config-server.yaml` | Deployment + Service del Config Server | Permite que tus microservicios obtengan configuración desde el `config-repo` de Git. |

---

### ### 0.3 **03-backend, 04-gateway, 05-security (Microservicios)**

| Archivo                        | Microservicio           | Componentes                      | Función                                                                |
| ------------------------------ | ----------------------- | -------------------------------- | ---------------------------------------------------------------------- |
| `03-backend/ms-productos.yaml` | ms-productos            | Deployment + Service (ClusterIP) | API reactiva de productos. Acceso interno: `http://ms-productos:8081`. |
| `03-backend/ms-pedidos.yaml`   | ms-pedidos              | Deployment + Service (ClusterIP) | API de pedidos. Usa WebClient para comunicarse con ms-productos.       |
| `05-security/auth-server.yaml` | ms-authorization-server | Deployment + Service             | Emisión de tokens OAuth 2.0.                                           |
| `04-gateway/gateway.yaml`      | gateway-service         | Deployment + Service             | API Gateway, entrada principal del sistema.                            |
| `04-gateway/ingress.yaml`      | Ingress                 | Reglas de enrutamiento           | Mapea rutas externas → Services internos.                              |

---

### ### 0.4 **clean-config (Configuración del Config Server)**

Estos archivos son descargados dinámicamente por el Config Server desde tu `config-repo`.

Incluyen:

* `gateway-service.yml`
* `ms-authorization-server.yml`
* `ms-pedidos-dev.yml`
* `ms-productos-dev.yml`

**Función clave:**

* Definir URLs de base de datos (R2DBC)
* Configurar puertos
* Configurar comunicación interna, ejemplo:

```yaml
ms-productos:
  url: http://ms-productos:8081
```

Este punto es crítico para que `ms-pedidos` pueda consumir `ms-productos` dentro de Kubernetes.

---

## 1. 🧩 Stack Tecnológico Central

###

## 1. 🧩 Stack Tecnológico Central

| **Componente**                 | **Tecnología**           | **Relevancia en v3 (K8s)**                                                                            |
| ------------------------------ | ------------------------ | ----------------------------------------------------------------------------------------------------- |
| **Arquitectura**               | Microservicios Reactivos | Uso de **Spring WebFlux** y **Spring Data R2DBC** para operaciones no bloqueantes y alto rendimiento. |
| **Comunicación**               | WebClient                | `ms-pedidos` consume `ms-productos` para validar stock.                                               |
| **Base de Datos**              | PostgreSQL + R2DBC       | Control total del esquema (tablas + SP). **R2DBC no crea esquema automáticamente**.                   |
| **Configuración Centralizada** | Spring Cloud Config      | `ms-config-server` carga `.yml` desde `config-repo`.                                                  |
| (K8s)                          |                          |                                                                                                       |
| --------------                 | ------------             | -------------------------                                                                             |
| **Arquitectura**               | Microservicios Reactivos | Uso de **Spring WebFlux** y **Spring Data R2DBC** para operaciones no bloqueantes y alto rendimiento. |
| **Comunicación**               | WebClient                | `ms-pedidos` consume `ms-productos` para validar stock.                                               |
| **Base de Datos**              | PostgreSQL + R2DBC       | Control total del esquema (tablas + SP). Sin auto-creación.                                           |
| **Configuración Centralizada** | Spring Cloud Config      | El `ms-config-server` carga `.yml` desde `config-repo`.                                               |

---

## 2. ⚙️ Puntos Críticos de Configuración y Código

### 🛑 2.1 Dependencia de Base de Datos y SQL

R2DBC **no** crea tablas ni ejecuta scripts. Debes inicializar todo manualmente.

### Tablas obligatorias

* `productos`
* `pedidos`
* `detalle_pedidos`

### Procedimientos Almacenados (SP) obligatorios

#### **1. actualizar_stock**

Reduce el stock luego de un pedido correcto.
Se invoca desde `ms-pedidos`.

#### **2. productos_bajo_stock**

Retorna lista de productos con stock mínimo.
Ejemplo de endpoint: `GET /api/productos/bajo-stock`.

---

## ⚙️ 2.2 Configuración del Microservicio ms-pedidos

El servicio **cliente** es `ms-pedidos`, por lo que su configuración debe ser exacta.

### Archivo: `ms-pedidos-dev.yml` (en config-repo)

#### En local (v1/v2):

```yaml\ms-productos:
  url: http://localhost:8081
```

#### En Kubernetes (v3):

```yaml\ms-productos:
  url: http://ms-productos:8081
```

Usa el **nombre del Service** de Kubernetes.

---

## 3. 🔄 Flujo de Prueba Funcional (Reactivo)

Este flujo demuestra el correcto funcionamiento del sistema.

### **1️⃣ Crear un producto**

```
POST /api/productos
{
  "nombre": "Laptop Gamer",
  "stock": 10,
  "precio": 2500
}
```

### **2️⃣ Crear un pedido de 2 unidades**

```
POST /api/pedidos
{
  "productoId": 1,
  "cantidad": 2
}
```

### Acción Interna Automática

* `ms-pedidos` llama a `ms-productos` usando WebClient.
* Valida stock.
* Invoca el SP `actualizar_stock`.

### Resultado Esperado

* Stock final: **8**.

---

## ❌ Validación de Stock Insuficiente

### Intento:

```
POST /api/pedidos
{
  "productoId": 1,
  "cantidad": 50
}
```

### Resultado Esperado

* `500 Internal Server Error`
* Mensaje claro: **"Stock insuficiente"**.

---

## ✅ Conclusión

Este README centraliza lo esencial para que tu **Sistema de Pedidos v3** funcione correctamente en entornos locales y Kubernetes. La clave está en:

* WebFlux + R2DBC
* SP obligatorios
* Configuración centralizada
* Interacción WebClient entre ms-pedidos y ms-productos

Si quieres, puedo añadir:
✔️ Diagramas de arquitectura (ASCII o imagen)
✔️ Scripts SQL completos
✔️ Ejemplos de Docker Compose
✔️ Sección de despliegue en Kubernetes
✔️ Pruebas con WebTestClient
