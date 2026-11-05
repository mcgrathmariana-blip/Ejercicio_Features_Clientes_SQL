
-- =====================================================
-- EJERCICIO: FEATURES DE CLIENTES PARA MACHINE LEARNING
-- Base de datos: features_clientes
-- Motor: SQLite
-- =====================================================

PRAGMA foreign_keys = ON;

-- 1. CREACION DE TABLAS

DROP TABLE IF EXISTS detalles_pedido;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;

CREATE TABLE clientes (
    cliente_id INTEGER PRIMARY KEY,
    nombre TEXT,
    ciudad TEXT
);

CREATE TABLE productos (
    producto_id INTEGER PRIMARY KEY,
    nombre TEXT,
    categoria TEXT
);

CREATE TABLE pedidos (
    pedido_id INTEGER PRIMARY KEY,
    cliente_id INTEGER,
    fecha TEXT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
);

CREATE TABLE detalles_pedido (
    detalle_id INTEGER PRIMARY KEY,
    pedido_id INTEGER,
    producto_id INTEGER,
    cantidad INTEGER,
    precio_unitario REAL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id),
    FOREIGN KEY (producto_id) REFERENCES productos(producto_id)
);

-- 2. INSERCION DE DATOS

INSERT INTO clientes VALUES
(101, 'Ana', 'Buenos Aires'),
(102, 'Bruno', 'Buenos Aires'),
(103, 'Carla', 'Cordoba'),
(104, 'Diego', 'Cordoba'),
(105, 'Elena', 'Buenos Aires');

INSERT INTO productos VALUES
(1, 'Arroz', 'Alimentos'),
(2, 'Leche', 'Alimentos'),
(3, 'Notebook', 'Tecnologia'),
(4, 'Mouse', 'Tecnologia');

INSERT INTO pedidos VALUES
(1, 101, '2026-01-01'),
(2, 101, '2026-01-05'),
(3, 101, '2026-01-10'),
(4, 101, '2026-01-15'),
(5, 102, '2026-01-03'),
(6, 102, '2026-01-08'),
(7, 103, '2026-01-02'),
(8, 103, '2026-01-06'),
(9, 103, '2026-01-11'),
(10, 103, '2026-01-16'),
(11, 103, '2026-01-20'),
(12, 105, '2026-01-04'),
(13, 105, '2026-01-09'),
(14, 105, '2026-01-14'),
(15, 105, '2026-01-19');

INSERT INTO detalles_pedido VALUES
(1, 1, 1, 2, 30),
(2, 2, 3, 1, 120),
(3, 3, 2, 2, 20),
(4, 4, 4, 2, 50),
(5, 5, 3, 1, 150),
(6, 6, 1, 2, 30),
(7, 7, 3, 1, 200),
(8, 8, 1, 2, 40),
(9, 9, 4, 2, 50),
(10, 10, 2, 3, 20),
(11, 11, 3, 1, 100),
(12, 12, 1, 1, 20),
(13, 13, 2, 1, 20),
(14, 14, 4, 1, 20),
(15, 15, 1, 2, 20);

-- =====================================================
-- 3. CONSULTA 1: LTV (GASTO TOTAL POR CLIENTE)
-- LEFT JOIN conserva clientes sin compras.
-- COALESCE reemplaza NULL por 0.
-- =====================================================

SELECT
    c.cliente_id,
    c.nombre,
    c.ciudad,
    COALESCE(SUM(dp.cantidad * dp.precio_unitario), 0) AS gasto_total
FROM clientes c
LEFT JOIN pedidos p
    ON c.cliente_id = p.cliente_id
LEFT JOIN detalles_pedido dp
    ON p.pedido_id = dp.pedido_id
GROUP BY c.cliente_id, c.nombre, c.ciudad
ORDER BY gasto_total DESC;

-- =====================================================
-- 4. CONSULTA 2: GASTO POR CATEGORIA
-- Agregacion condicional con CASE WHEN.
-- =====================================================

SELECT
    c.cliente_id,
    c.nombre,
    c.ciudad,
    COALESCE(SUM(
        CASE WHEN pr.categoria = 'Alimentos'
        THEN dp.cantidad * dp.precio_unitario ELSE 0 END
    ), 0) AS gasto_alimentos,
    COALESCE(SUM(
        CASE WHEN pr.categoria = 'Tecnologia'
        THEN dp.cantidad * dp.precio_unitario ELSE 0 END
    ), 0) AS gasto_tecnologia,
    COALESCE(SUM(dp.cantidad * dp.precio_unitario), 0) AS gasto_total
FROM clientes c
LEFT JOIN pedidos p
    ON c.cliente_id = p.cliente_id
LEFT JOIN detalles_pedido dp
    ON p.pedido_id = dp.pedido_id
LEFT JOIN productos pr
    ON dp.producto_id = pr.producto_id
GROUP BY c.cliente_id, c.nombre, c.ciudad
ORDER BY c.cliente_id;

-- =====================================================
-- 5. CONSULTA 3: SEGMENTACION DE CLIENTES ACTIVOS
-- Mas de 3 pedidos y gasto promedio superior a 50.
-- HAVING filtra despues de la agrupacion.
-- =====================================================

SELECT
    c.cliente_id,
    c.nombre,
    c.ciudad,
    COUNT(DISTINCT p.pedido_id) AS cantidad_pedidos,
    ROUND(
        SUM(dp.cantidad * dp.precio_unitario) * 1.0 /
        COUNT(DISTINCT p.pedido_id), 2
    ) AS gasto_promedio,
    SUM(dp.cantidad * dp.precio_unitario) AS gasto_total
FROM clientes c
INNER JOIN pedidos p
    ON c.cliente_id = p.cliente_id
INNER JOIN detalles_pedido dp
    ON p.pedido_id = dp.pedido_id
GROUP BY c.cliente_id, c.nombre, c.ciudad
HAVING COUNT(DISTINCT p.pedido_id) > 3
   AND SUM(dp.cantidad * dp.precio_unitario) * 1.0 /
       COUNT(DISTINCT p.pedido_id) > 50
ORDER BY gasto_total DESC;

-- =====================================================
-- 6. CONSULTA 4: RANKING DE CLIENTES POR CIUDAD
-- CTE para calcular el gasto antes de aplicar RANK.
-- =====================================================

WITH resumen_clientes AS (
    SELECT
        c.cliente_id,
        c.nombre,
        c.ciudad,
        COALESCE(SUM(dp.cantidad * dp.precio_unitario), 0) AS gasto_total
    FROM clientes c
    LEFT JOIN pedidos p
        ON c.cliente_id = p.cliente_id
    LEFT JOIN detalles_pedido dp
        ON p.pedido_id = dp.pedido_id
    GROUP BY c.cliente_id, c.nombre, c.ciudad
)

SELECT
    cliente_id,
    nombre,
    ciudad,
    gasto_total,
    RANK() OVER (
        PARTITION BY ciudad
        ORDER BY gasto_total DESC
    ) AS ranking_ciudad
FROM resumen_clientes
ORDER BY ciudad, ranking_ciudad;

-- =====================================================
-- FIN DEL EJERCICIO
-- =====================================================
