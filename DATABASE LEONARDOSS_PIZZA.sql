CREATE DATABASE leonardoss_pizza;
CREATE TABLE ordenes (
id_order varchar(10) PRIMARY KEY not null,
id_item varchar(10) not null,
id_cliente int not null,
id_direccion int not null,
fecha datetime not null,
cantidad int not null,
entregado boolean not null
);
CREATE TABLE cliente (
id_cliente int PRIMARY KEY not null,
1er_nombre varchar(20) not null,
2do_nombre varchar(20) null
);
CREATE TABLE direccion (
id_direccion int PRIMARY KEY not null,
direccion_1 varchar(200) not null,
direccion_2 varchar(200) null,
ciudad varchar (50) not null,
zipcode_ciudad varchar (20) not null
);
CREATE TABLE producto (
id_item varchar(10) PRIMARY KEY not null,
id_descripcion varchar (50) not null,
item_nombre varchar (100) not null,
item_cant varchar (100) not null,
item_tamaño varchar (100) not null,
item_precio decimal (5,2) not null
);
CREATE TABLE receta (
id_row int PRIMARY KEY not null,
id_descripcion varchar(50) not null,
id_ingrediente varchar(20) not null,
cantidad int not null
);
CREATE TABLE ingrediente (
id_ingrediente varchar(20) not null,
ingredie_nombre varchar(50) not null,
ingredie_peso int not null,
ingredie_unidad varchar(20) not null,
ingredie_precio decimal (5,2) not null
);
CREATE TABLE inventario (
id_inventario int PRIMARY KEY not null,
id_item varchar(10) not null,
cantidad int
);
CREATE TABLE empleados(
id_empleado int PRIMARY KEY not null,
1er_nombre varchar(50) not null,
apellido varchar(50),
puesto varchar(100) not null,
salario_hora int not null
);
CREATE TABLE turno(
id_turno varchar(20) PRIMARY KEY not null,
dia varchar(20) not null,
empieza_turno time not null,
termina_turno time not null
);
CREATE TABLE rotacion(
id_rotacion varchar(20) PRIMARY KEY not null,
id_orden varchar(10) not null,
fecha datetime not null,
id_turno varchar(20) not null,
id_empleado varchar (20) not null
);

ALTER TABLE ordenes
ADD CONSTRAINT fk_cliente
FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE ordenes
ADD CONSTRAINT fk_direccion
FOREIGN KEY (id_direccion) REFERENCES direccion(id_direccion)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE ordenes
ADD CONSTRAINT fk_item
FOREIGN KEY (id_item) REFERENCES producto(id_item)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE receta
ADD CONSTRAINT fk_id_descripcion
FOREIGN KEY (id_descripcion)
REFERENCES producto(id_descripcion)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE inventario
ADD CONSTRAINT fk_producto
FOREIGN KEY (id_item)
reference producto(id_item)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE receta
ADD CONSTRAINT fk_id_ingrediente
FOREIGN KEY (id_ingrediente)
REFERENCES ingrediente(id_ingrediente)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE rotacion
ADD CONSTRAINT fk_empleado
FOREIGN KEY (id_empleado)
REFERENCES empleado(id_empleado)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE rotacion
ADD CONSTRAINT fk_turno
FOREIGN KEY (id_turno)
REFERENCES turno(id_turno)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE orden
ADD CONSTRAINT fk_rotacion
FOREIGN KEY (fecha)
REFERENCES rotacion(fecha)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE rotacion
ADD CONSTRAINT fk_orden
FOREIGN KEY (id_orden) REFERENCES orden(id_orden)
ON DELETE CASCADE
ON UPDATE CASCADE;

# query1 -> ordenes totales
SELECT 
COUNT(DISTINCT id_orden) AS total_id_orden
FROM orden;

# query2 -> ganancias totales
SELECT
SUM(precio_venta) AS GANANCIA_TOTAL
FROM (
SELECT
p.item_precio AS precio_venta
FROM producto p
LEFT JOIN orden o ON p.id_item = o.id_item
) AS subconsulta;

# query3 -> cantidad de pizzas
SELECT
SUM(o.cantidad) AS TOTAL_PIZZAS
FROM orden o;

# query4 -> venta de pizzas
SELECT
p.item_nombre,
SUM(o.cantidad) AS cantidad_total
FROM producto p
LEFT JOIN orden o ON p.id_item = o.id_item
GROUP BY o.id_item, p.item_nombre;

# query5 -> ganancias por pizzas
SELECT
p.item_nombre,
SUM(p.item_precio) AS precio_venta
FROM producto p
LEFT JOIN orden o ON p.id_item = o.id_item
GROUP BY p.item_nombre;

# query6 -> direccion
SELECT
    CONCAT(direccion_1,', ', ciudad,', ','Colombia') AS direccion_completa
FROM direccion;

#query7 -> costos de ingredientes
SELECT
SUM(costo_total) AS gasto_total_ingredientes
FROM (
SELECT
o.id_item,
o.cantidad,
i.ingredie_nombre,
o.cantidad * r.cantidad AS cantidad_total,
i.ingredie_precio / i.ingredie_peso AS precio_unidad,
(o.cantidad * r.cantidad) * (i.ingredie_precio / i.ingredie_peso) AS costo_total
FROM
producto p
LEFT JOIN orden o ON p.id_item = o.id_item
LEFT JOIN receta r ON p.id_descripcion = r.id_descripcion
LEFT JOIN ingrediente i ON r.id_ingrediente = i.id_ingrediente) AS total_costo;

# query 8 informacion orden
SELECT
o.id_orden,
p.item_precio,
o.cantidad,
p.item_nombre,
o.fecha,
d.direccion_1,
d.ciudad
FROM orden o
LEFT JOIN producto p on o.id_item = p.id_item
LEFT JOIN direccion d on o.id_direccion = d.id_direccion;


# query 9 inventario
CREATE VIEW inventario1 AS
SELECT 
    s1.item_nombre,
    s1.id_item, 
    s1.id_ingrediente,
    s1.ingredie_nombre,
    s1.ingredie_peso,
    s1.ingredie_precio,
    s1.cantidad_ordenes AS orden_cantidad,
    s1.cantidad AS receta_cantidad,
    s1.cantidad_ordenes * s1.cantidad AS orden_peso,
    s1.ingredie_precio / s1.ingredie_peso AS precio_unidad,
    (s1.cantidad_ordenes * s1.cantidad) * (s1.ingredie_precio / s1.ingredie_peso) AS ingrediente_costo
FROM (
    SELECT
        o.id_item,
        p.id_descripcion,
        p.item_nombre,
        r.id_ingrediente,
        ing.ingredie_nombre,
        r.cantidad,
        SUM(o.cantidad) AS cantidad_ordenes,
        ing.ingredie_peso,
        ing.ingredie_precio
    FROM orden o
    LEFT JOIN producto p ON o.id_item = p.id_item
    LEFT JOIN receta r ON p.id_descripcion = r.id_descripcion
    LEFT JOIN ingrediente ing ON r.id_ingrediente = ing.id_ingrediente
    GROUP BY o.id_item, p.id_descripcion, p.item_nombre, r.id_ingrediente, r.cantidad, ing.ingredie_nombre, ing.ingredie_peso, ing.ingredie_precio
) s1;

# query 10 inventario requerido
SELECT 
    s2.id_item,
    s2.item_nombre,
    s2.peso_ordenado,
    inv.id_inventario,
    inv.cantidad AS inventario_cantidad
FROM 
    (SELECT
        id_item,
        item_nombre,
     SUM(orden_peso) AS peso_ordenado
    FROM
        inventario1
    GROUP BY
        id_item,item_nombre
    ) s2
LEFT JOIN 
    inventario inv ON inv.id_item = s2.id_item
GROUP BY
    s2.id_item, 
    s2.item_nombre,
    inv.id_inventario, 
    inv.cantidad;

# query 11 empleado
SELECT
    r.fecha,
    e.1er_nombre,
    e.apellido,
    e.salario_hora,
    t.empieza_turno,
    t.termina_turno,
    ROUND(TIMESTAMPDIFF(MINUTE, t.empieza_turno, t.termina_turno) / 60, 2) AS horas_trabajadas,
    ROUND((TIMESTAMPDIFF(MINUTE, t.empieza_turno, t.termina_turno) / 60) * e.salario_hora, 2) AS salario_empleado
FROM rotacion r
LEFT JOIN empleado e ON r.id_empleado = e.id_empleado
LEFT JOIN turno t ON r.id_turno = t.id_turno;

# query 12 gasto total de nomina
SELECT
SUM(
ROUND(
(TIMESTAMPDIFF(MINUTE, t.empieza_turno, t.termina_turno) / 60) * e.salario_hora,2)
    ) AS salario_empleado
FROM
    rotacion r
    LEFT JOIN empleado e ON r.id_empleado = e.id_empleado
    LEFT JOIN turno t ON r.id_turno = t.id_turno;

# query 13 salario empleado
SELECT
CONCAT(e.1er_nombre, '(', e.puesto, ')') AS empleado_puesto,
SUM(
ROUND((TIMESTAMPDIFF(MINUTE, t.empieza_turno, t.termina_turno) / 60) * e.salario_hora,2
)) AS salario_empleado
FROM rotacion r
LEFT JOIN empleado e ON r.id_empleado = e.id_empleado
LEFT JOIN turno t ON r.id_turno = t.id_turno
GROUP BY e.1er_nombre, e.puesto
ORDER BY salario_empleado DESC;




















 
