# Features de Clientes para Machine Learning

## Descripción

Este proyecto utiliza SQL y SQLite para transformar datos relacionales de clientes, pedidos, detalles de pedidos y productos en métricas útiles para Machine Learning.

## Objetivos

- Calcular el gasto total histórico (LTV) de cada cliente.
- Calcular el gasto por categoría de producto.
- Identificar clientes activos mediante condiciones HAVING.
- Clasificar a los clientes según su gasto dentro de cada ciudad utilizando funciones de ventana.

## Tablas utilizadas

- clientes
- pedidos
- detalles_pedido
- productos

## Consultas SQL

1. **LTV:** utiliza LEFT JOIN, SUM y COALESCE para calcular el gasto total, incluyendo clientes sin compras.
2. **Gasto por categoría:** utiliza CASE WHEN y agregación condicional para calcular el gasto en Alimentos y Tecnología.
3. **Segmentación:** utiliza GROUP BY y HAVING para identificar clientes con más de tres pedidos y gasto promedio superior a 50.
4. **Ranking:** utiliza RANK() OVER (PARTITION BY ciudad) para ordenar a los clientes según su gasto dentro de cada ciudad.

## Tecnologías

- Python
- SQL
- SQLite
- Google Colab
- Pandas
