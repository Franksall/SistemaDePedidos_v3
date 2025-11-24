/* ===========================================================
   SCRIPT AUTOMATIZADO PARA DOCKER (SOLO ENTORNO DEV)
   Crea todas las tablas para ambos microservicios
   en una sola base de datos.
   =========================================================== */

/* --- Tablas para MS-PRODUCTOS --- */
CREATE TABLE productos (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(255),
    descripcion TEXT,
    precio NUMERIC(10, 2),
    stock INTEGER,
    activo BOOLEAN,
    fecha_creacion TIMESTAMP
);

/* --- Tablas para MS-PEDIDOS --- */
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

/* --- Funciones para MS-PRODUCTOS --- */
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

/* --- Datos de Prueba para MS-PRODUCTOS --- */
INSERT INTO productos (nombre, descripcion, precio, stock, activo, fecha_creacion)
VALUES 
('Laptop Dell (Docker)', 'Laptop i7 16GB RAM', 1200.00, 10, true, NOW()),
('Mouse Logitech (Docker)', 'Mouse inalámbrico', 25.00, 50, true, NOW()),
('Teclado Mecánico (Docker)', 'Teclado RGB', 80.00, 30, true, NOW());

/* --- FIN DEL SCRIPT --- */