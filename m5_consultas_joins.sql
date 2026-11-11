-- ==========================================================
-- Semana 5 · Setup de práctica · TechStore_Clase5
-- Motor: SQL Server (SSMS)
-- Ejecutar completo con F5. Se puede correr las veces que quieras.
-- Usa una base aparte para NO tocar tu Ventas_Tech_DB del checkpoint.
-- Es la TechStore de la semana 4 con dos agregados:
--   * un cliente que nunca compró (109)
--   * una tabla de sucursales (para UNION)
-- ==========================================================

-- 0. BASE DE DATOS (se borra y se crea de nuevo)
USE master;
GO
IF DB_ID('TechStore_Clase5') IS NOT NULL
BEGIN
    ALTER DATABASE TechStore_Clase5 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TechStore_Clase5;
END
GO
CREATE DATABASE TechStore_Clase5;
GO
USE TechStore_Clase5;
GO

-- 1. CREATE TABLES (mismo modelo de la semana 4 + sucursales)
CREATE TABLE categorias (
    id_categoria     INT PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL,
    descripcion      VARCHAR(200)
);

CREATE TABLE clientes (
    id_cliente     INT PRIMARY KEY,
    nombre         VARCHAR(100) NOT NULL,
    email          VARCHAR(100) NOT NULL UNIQUE,
    ciudad         VARCHAR(50),
    fecha_registro DATE NOT NULL
);

CREATE TABLE productos (
    id_producto     INT PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    id_categoria    INT,
    precio          DECIMAL(10,2) NOT NULL,
    stock           INT DEFAULT 0,
    activo          BIT DEFAULT 1,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

CREATE TABLE ventas (
    id_venta        INT PRIMARY KEY,
    id_cliente      INT NULL,              -- NULL = venta de mostrador, sin cliente identificado
    id_producto     INT NOT NULL,
    cantidad        INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    fecha_venta     DATE NOT NULL,
    FOREIGN KEY (id_cliente)  REFERENCES clientes(id_cliente),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

CREATE TABLE sucursales (                  -- nueva: no se relaciona con ventas, es para UNION
    id_sucursal INT PRIMARY KEY,
    nombre      VARCHAR(50) NOT NULL,
    ciudad      VARCHAR(50) NOT NULL
);

-- 2. INSERT DATA (primero las tablas sin dependencias)
INSERT INTO categorias VALUES
(1, 'Computacion', 'Laptops, monitores y almacenamiento'),
(2, 'Accesorios',  'Perifericos y complementos'),
(3, 'Audio',       'Auriculares y parlantes');

INSERT INTO clientes VALUES
(101, 'Maria Lopez',     'maria@mail.com',   'Posadas',      '2025-03-10'),
(102, 'Juan Benitez',    'juan@mail.com',    'Obera',        '2025-05-22'),
(103, 'Carla Gimenez',   'carla@mail.com',   'Resistencia',  '2025-06-01'),
(104, 'Diego Ramirez',   'diego@mail.com',   'Corrientes',   '2025-08-15'),
(105, 'Lucia Fernandez', 'lucia@mail.com',   'Posadas',      '2025-11-03'),
(106, 'Pablo Acosta',    'pablo@mail.com',   'Buenos Aires', '2026-01-09'),
(107, 'Sofia Romero',    'sofia@mail.com',   'Cordoba',      '2026-02-14'),
(108, 'Martin Sosa',     'martin@mail.com',  'Obera',        '2026-03-30'),
(109, 'Ana Duarte',      'ana@mail.com',     'Posadas',      '2026-05-02');   -- se registro y nunca compro

INSERT INTO productos VALUES
(1, 'Laptop Pro 15',     1, 1200.00, 15, 1),
(2, 'Monitor 24',        1,  150.00, 30, 1),
(3, 'Teclado mecanico',  2,   80.00, 40, 1),
(4, 'Auriculares BT',    3,  250.00, 25, 1),
(5, 'Mouse inalambrico', 2,   50.00, 90, 1),
(6, 'Webcam HD',         2,   70.00, 20, 1),
(7, 'Parlante BT',       3,  120.00, 18, 1),
(8, 'Disco SSD 1TB',     1,   95.00, 12, 1);   -- nunca se vendio

INSERT INTO sucursales VALUES
(1, 'Casa Central',   'Obera'),
(2, 'Posadas Centro', 'Posadas'),
(3, 'Corrientes',     'Corrientes'),
(4, 'Eldorado',       'Eldorado');             -- la unica ciudad sin clientes

-- Las mismas 28 ventas de la semana 4.
-- Fechas en formato 'AAAAMMDD': no depende del idioma del servidor.
INSERT INTO ventas VALUES
(1,  101, 1, 2, 1200.00, '20260115'),
(2,  102, 2, 1,  150.00, '20260120'),
(3,  101, 3, 3,   80.00, '20260122'),
(4,  103, 1, 1, 1200.00, '20260205'),
(5,  104, 4, 2,  250.00, '20260210'),
(6,  102, 1, 1, 1200.00, '20260218'),
(7,  105, 5, 5,   50.00, '20260301'),
(8,  101, 2, 2,  150.00, '20260312'),
(9,  106, 1, 1, 1200.00, '20260315'),
(10, 103, 3, 4,   80.00, '20260320'),
(11, 107, 5, 3,   50.00, '20260402'),
(12, 101, 1, 1, 1150.00, '20260408'),   -- con descuento
(13, 108, 2, 2,  150.00, '20260411'),
(14, 103, 6, 2,   70.00, '20260419'),
(15, NULL, 5, 1,  50.00, '20260425'),   -- mostrador
(16, 104, 1, 2, 1200.00, '20260503'),
(17, 102, 4, 1,  250.00, '20260507'),
(18, 102, 3, 2,   80.00, '20260514'),
(19, 101, 7, 1,  120.00, '20260520'),
(20, 103, 2, 3,  150.00, '20260522'),
(21, NULL, 6, 1,  70.00, '20260528'),   -- mostrador
(22, 107, 1, 1, 1200.00, '20260602'),
(23, 103, 4, 2,  250.00, '20260609'),
(24, 104, 5, 4,   50.00, '20260612'),
(25, 101, 2, 1,  150.00, '20260618'),
(26, 102, 7, 2,  120.00, '20260625'),
(27, 104, 3, 1,   80.00, '20260627'),
(28, 103, 1, 1, 1200.00, '20251220');   -- del anio anterior

-- 3. VALIDACION: tiene que dar 3 / 9 / 8 / 4 / 28
SELECT 'categorias' AS tabla, COUNT(*) AS filas FROM categorias
UNION ALL SELECT 'clientes',   COUNT(*) FROM clientes
UNION ALL SELECT 'productos',  COUNT(*) FROM productos
UNION ALL SELECT 'sucursales', COUNT(*) FROM sucursales
UNION ALL SELECT 'ventas',     COUNT(*) FROM ventas;

-- Pre Entrega 5 : Consultas con JOINs para el proyecto
-- Silvina Pampin

-- Consulta 1 — Vista base del proyecto (INNER JOIN)
-- Sirve para tener una base general que me permita ver la cantidad de ventas, fechas, datos del cliente y del producto vendido junto con cantidad y monto total facturado

SELECT v.id_venta,
       v.fecha_venta,
       c.nombre            AS cliente,
       c.id_cliente,
       c.ciudad,
       p.nombre_producto   AS producto,
       cat.nombre_categoria AS categoria,
       v.cantidad,
       v.precio_unitario,
       v.cantidad * v.precio_unitario AS total
FROM ventas v
INNER JOIN clientes   c   ON v.id_cliente   = c.id_cliente
INNER JOIN productos  p   ON v.id_producto  = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY v.id_venta;

-- Hallazgo: nos muestra el detalle buscado de 26 ventas. Faltan 2 sobre el total ya que no tienen id de cliente. Tenemos un total de $16.450 facturados en 51 unidades vendidas. Laptop Pro 15 es el producto más vendido con un total facturado de $11.950.


-- Consulta 2 — Clientes sin ventas (LEFT JOIN) 
-- Sirve para saber los clientes que ingresaron en nuestra base, lo que implica que se pusieron en contacto con la compañia pero que finalmente no terminaron efectivamente comprando. Se podría contactar a los mismos y entender que sucedió a efectos de posibilidades de mejora

SELECT c.nombre, c.email, c.fecha_registro
FROM clientes c
left JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;

-- Hallazgo: de un total de 9 clientes solo uno no realizó ninguna compra. Como mencioné anteriormente se podría contactar al mismo para entender que sucedió. es falta de stock, mala atención, precio?


-- Consulta 3 — Productos sin ventas (LEFT JOIN)
-- Sirve para entender que producto no tuvo salida

SELECT p.nombre_producto, p.id_categoria, p.precio
FROM productos p
LEFT JOIN ventas v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;

-- Hallazago: Solo 1 producto de 8 no tuvo ninguna venta asociada. Se puede imvestigar a que se debe. Es un tema de precio vs el mercado? o es poca la demanda en general del mismo? tengo mucho stock del mismo? puedo poner una promoción del mismo?


-- Consulta 4 — Consolidado por canal (UNION ALL)
-- Sirve para tener una visión del mix de canales de la compañia.

WITH por_canal AS (
  SELECT   
        fecha_venta, 
        cantidad * precio_unitario AS total,
        'Presencial' AS canal
  FROM ventas WHERE id_cliente IS NOT NULL
  UNION ALL
  SELECT fecha_venta, cantidad * precio_unitario,
         'Online'
  FROM ventas WHERE id_cliente IS NULL
)
SELECT 
    canal, 
    COUNT(*) AS ventas, 
    SUM(total) AS facturado
FROM por_canal
GROUP BY canal;

-- Hallazgo: El 93% de las ventas fueron realizadas de forma presencial. Es el canal más económico? que se puede hacer para incentivar el online?

-- gracias