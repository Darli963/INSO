CREATE DATABASE IF NOT EXISTS sistema_compras 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

USE sistema_compras;

CREATE TABLE IF NOT EXISTS proveedor (
  idProveedor INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(150) NOT NULL,
  email VARCHAR(120),
  telefono VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS producto (
  idProducto INT PRIMARY KEY AUTO_INCREMENT,
  codigo VARCHAR(50) UNIQUE,
  nombre VARCHAR(150) NOT NULL,
  descripcion VARCHAR(255),
  stockActual INT NOT NULL DEFAULT 0,
  stockMinimo INT NOT NULL DEFAULT 0,
  stockMaximo INT,
  precioVenta DECIMAL(10,2) NOT NULL DEFAULT 0,
  precioCompra DECIMAL(10,2) NOT NULL DEFAULT 0,
  ubicacion VARCHAR(100),
  fechaVencimiento DATE,
  idCategoria INT,
  idProveedor INT,
  INDEX idx_producto_nombre (nombre),
  INDEX idx_producto_idProveedor (idProveedor),
  FOREIGN KEY (idProveedor) REFERENCES proveedor(idProveedor)
);

CREATE TABLE IF NOT EXISTS cotizacion (
  idCotizacion INT PRIMARY KEY AUTO_INCREMENT,
  fechaSolicitud DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  idProveedor INT NOT NULL,
  estado ENUM('PENDIENTE','APROBADA','RECHAZADA') NOT NULL DEFAULT 'PENDIENTE',
  observaciones TEXT,
  FOREIGN KEY (idProveedor) REFERENCES proveedor(idProveedor)
);

CREATE TABLE IF NOT EXISTS detalle_cotizacion (
  idDetalle INT PRIMARY KEY AUTO_INCREMENT,
  idCotizacion INT NOT NULL,
  idProducto INT NOT NULL,
  cantidad INT NOT NULL,
  precioUnitario DECIMAL(10,2),
  INDEX idx_detalle_idCotizacion (idCotizacion),
  FOREIGN KEY (idCotizacion) REFERENCES cotizacion(idCotizacion),
  FOREIGN KEY (idProducto) REFERENCES producto(idProducto)
);

INSERT INTO proveedor (nombre, email, telefono) VALUES
('Proveedor 1', 'prov1@example.com', '111-111'),
('Proveedor 2', 'prov2@example.com', '222-222');

INSERT INTO producto (codigo, nombre, descripcion, stockActual, stockMinimo, stockMaximo, precioVenta, precioCompra, ubicacion, fechaVencimiento, idCategoria, idProveedor) VALUES
('P001','Alcohol 70%','Desinfectante',20,10,100,12.50,8.00,'A1',NULL,1,1),
('P002','Guantes Nitrilo','Talla M',5,10,200,0.50,0.30,'B2',NULL,1,2),
('P003','Mascarilla','Quirurgica',50,30,300,0.20,0.10,'C3',NULL,2,1),
('P004','Gasas','Esteriles',8,15,150,2.00,1.20,'D4',NULL,2,2),
('P005','Jeringas 5ml','Descartables',100,50,500,0.80,0.40,'E5',NULL,3,1),
('P006','Suero Fisiologico','500ml',12,20,200,4.00,2.20,'F6',NULL,3,2),
('P007','Termómetro','Digital',3,5,50,15.00,9.00,'G7',NULL,4,1),
('P008','Desinfectante piso','Industrial',40,20,200,6.00,3.50,'H8',NULL,4,2),
('P009','Toallas','Papel',25,10,150,1.50,0.90,'I9',NULL,5,1),
('P010','Batas','Desechables',7,12,100,3.00,1.80,'J10',NULL,5,2);

-- DATOS DE PRUEBA

CREATE TABLE IF NOT EXISTS roles (
  id_rol TINYINT PRIMARY KEY AUTO_INCREMENT,
  nombre_rol VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS usuarios (
  id_usuario INT PRIMARY KEY AUTO_INCREMENT,
  nombre_completo VARCHAR(120) NOT NULL,
  correo VARCHAR(120) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  id_rol TINYINT NOT NULL,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
);

CREATE TABLE IF NOT EXISTS proveedores (
  id_proveedor INT PRIMARY KEY AUTO_INCREMENT,
  razon_social VARCHAR(150) NOT NULL,
  ruc VARCHAR(11),
  telefono VARCHAR(20),
  correo VARCHAR(120),
  direccion VARCHAR(200),
  estado ENUM('ACTIVO','INACTIVO') NOT NULL DEFAULT 'ACTIVO'
);

CREATE TABLE IF NOT EXISTS productos (
  id_producto INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(150) NOT NULL,
  descripcion VARCHAR(255),
  unidad_medida VARCHAR(30) NOT NULL,
  stock_minimo INT NOT NULL DEFAULT 0,
  estado ENUM('ACTIVO','INACTIVO') NOT NULL DEFAULT 'ACTIVO'
);

CREATE TABLE IF NOT EXISTS catalogo_productos (
  id_catalogo INT PRIMARY KEY AUTO_INCREMENT,
  id_proveedor INT NOT NULL,
  id_producto INT NOT NULL,
  presentacion VARCHAR(100),
  precio_unitario DECIMAL(10,2) NOT NULL,
  tiempo_entrega_dias INT,
  FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor),
  FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
  UNIQUE KEY uk_prov_prod (id_proveedor, id_producto)
);

CREATE TABLE IF NOT EXISTS cotizaciones (
  id_cotizacion INT PRIMARY KEY AUTO_INCREMENT,
  fecha_solicitud DATE NOT NULL,
  fecha_respuesta DATE,
  id_proveedor INT NOT NULL,
  id_usuario_solicita INT NOT NULL,
  estado ENUM('PENDIENTE','APROBADA','RECHAZADA') NOT NULL DEFAULT 'PENDIENTE',
  observaciones TEXT,
  FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor),
  FOREIGN KEY (id_usuario_solicita) REFERENCES usuarios(id_usuario)
);

CREATE TABLE IF NOT EXISTS detalle_cotizaciones (
  id_detalle INT PRIMARY KEY AUTO_INCREMENT,
  id_cotizacion INT NOT NULL,
  id_producto INT NOT NULL,
  cantidad INT NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (id_cotizacion) REFERENCES cotizaciones(id_cotizacion),
  FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

CREATE TABLE IF NOT EXISTS ordenes_compra (
  id_orden INT PRIMARY KEY AUTO_INCREMENT,
  codigo VARCHAR(20) NOT NULL UNIQUE,
  fecha_emision DATE NOT NULL,
  id_proveedor INT NOT NULL,
  id_cotizacion INT,
  id_usuario_solicita INT NOT NULL,
  id_usuario_aprueba INT,
  estado ENUM('PENDIENTE','APROBADA','ENVIADA','RECIBIDA','CANCELADA') NOT NULL DEFAULT 'PENDIENTE',
  total DECIMAL(12,2) DEFAULT 0,
  FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor),
  FOREIGN KEY (id_cotizacion) REFERENCES cotizaciones(id_cotizacion),
  FOREIGN KEY (id_usuario_solicita) REFERENCES usuarios(id_usuario),
  FOREIGN KEY (id_usuario_aprueba) REFERENCES usuarios(id_usuario)
);

CREATE TABLE IF NOT EXISTS detalle_orden_compra (
  id_detalle INT PRIMARY KEY AUTO_INCREMENT,
  id_orden INT NOT NULL,
  id_producto INT NOT NULL,
  cantidad INT NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (id_orden) REFERENCES ordenes_compra(id_orden),
  FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

CREATE TABLE IF NOT EXISTS recepciones (
  id_recepcion INT PRIMARY KEY AUTO_INCREMENT,
  id_orden INT NOT NULL,
  fecha_recepcion DATE NOT NULL,
  id_usuario_recepciona INT NOT NULL,
  estado ENUM('PENDIENTE','COMPLETA','PARCIAL','CON_RECLAMO') NOT NULL DEFAULT 'PENDIENTE',
  observaciones TEXT,
  FOREIGN KEY (id_orden) REFERENCES ordenes_compra(id_orden),
  FOREIGN KEY (id_usuario_recepciona) REFERENCES usuarios(id_usuario)
);

CREATE TABLE IF NOT EXISTS productos_recepcion (
  id_detalle INT PRIMARY KEY AUTO_INCREMENT,
  id_recepcion INT NOT NULL,
  id_producto INT NOT NULL,
  cantidad_recibida INT NOT NULL,
  lote VARCHAR(50),
  fecha_vencimiento DATE,
  estado_producto ENUM('OK','DANADO') DEFAULT 'OK',
  FOREIGN KEY (id_recepcion) REFERENCES recepciones(id_recepcion),
  FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

CREATE TABLE IF NOT EXISTS notas_pago (
  id_pago INT PRIMARY KEY AUTO_INCREMENT,
  id_orden INT NOT NULL,
  fecha_pago DATE NOT NULL,
  monto_total DECIMAL(12,2) NOT NULL,
  medio_pago ENUM('TRANSFERENCIA','EFECTIVO','TARJETA') NOT NULL,
  estado ENUM('PENDIENTE','PAGADO','ANULADO') NOT NULL DEFAULT 'PENDIENTE',
  referencia VARCHAR(100),
  FOREIGN KEY (id_orden) REFERENCES ordenes_compra(id_orden)
);

CREATE TABLE IF NOT EXISTS incidencias_recepcion (
  id_incidencia INT PRIMARY KEY AUTO_INCREMENT,
  id_recepcion INT NOT NULL,
  tipo ENUM('FALTANTE','DANADO','VENCIDO','OTRO') NOT NULL,
  descripcion TEXT NOT NULL,
  resuelto TINYINT(1) NOT NULL DEFAULT 0,
  FOREIGN KEY (id_recepcion) REFERENCES recepciones(id_recepcion)
);

INSERT INTO roles (nombre_rol) VALUES 
 ('GERENTE'), 
 ('ASISTENTE'), 
 ('RESPONSABLE_ALMACEN'), 
 ('CONTABILIDAD');

INSERT INTO usuarios (nombre_completo, correo, password_hash, id_rol) VALUES 
 ('Juan Torres (Gerente)', 'juan.gerente@botica.com', 'hash123', 1), 
 ('Kiara Aguilar (Asistente)', 'kiara.asistente@botica.com', 'hash123', 2), 
 ('Lorena Vásquez (Resp. Almacén)', 'lorena.almacen@botica.com', 'hash123', 3), 
 ('Jorge López (Contabilidad)', 'jorge.conta@botica.com', 'hash123', 4);

INSERT INTO proveedores (razon_social, ruc, telefono, correo, direccion) VALUES 
 ('Distribuidora Farma Norte S.A.C.', '20123456789', '944111222', 'contacto@farmanorte.com', 'Av. Salud 123 - Trujillo'), 
 ('Servicios Médicos del Norte S.A.C.', '20456789123', '944333444', 'ventas@serviciosmednorte.com', 'Jr. Bienestar 456 - Trujillo'), 
 ('Productos Naturales Vitales S.A.', '20987654321', '944555666', 'info@vitales.com', 'Av. Naturaleza 789 - Trujillo');

INSERT INTO productos (nombre, descripcion, unidad_medida, stock_minimo) VALUES 
 ('Paracetamol 500 mg',       'Tabletas analgésicas', 'tableta', 20), 
 ('Ibuprofeno 400 mg',        'Tabletas antiinflamatorias', 'tableta', 15), 
 ('Amoxicilina 500 mg',       'Cápsulas antibiótico', 'cápsula', 10), 
 ('Omeprazol 20 mg',          'Cápsulas gastroresistentes', 'cápsula', 10), 
 ('Jarabe para la tos 120 ml','Jarabe pediátrico', 'frasco', 8);

INSERT INTO catalogo_productos 
 (id_proveedor, id_producto, presentacion, precio_unitario, tiempo_entrega_dias) 
 VALUES 
 (1, 1, 'Caja x 100 tabletas', 35.50, 2), 
 (1, 2, 'Caja x 100 tabletas', 40.90, 2), 
 (2, 3, 'Caja x 50 cápsulas',  55.00, 3), 
 (2, 4, 'Caja x 50 cápsulas',  52.50, 3), 
 (3, 5, 'Frasco 120 ml',       18.90, 4);

INSERT INTO cotizaciones 
 (fecha_solicitud, fecha_respuesta, id_proveedor, id_usuario_solicita, estado, observaciones) 
 VALUES 
 ('2025-05-10', '2025-05-11', 1, 1, 'APROBADA', 'Mejores precios para analgésicos'), 
 ('2025-05-12', NULL,         2, 1, 'PENDIENTE', 'Cotización antibióticos');

INSERT INTO detalle_cotizaciones 
(id_cotizacion, id_producto, cantidad, precio_unitario) 
VALUES 
(1, 1, 200, 0.40), 
(1, 2, 150, 0.45), 
(2, 3, 100, 0.55);

INSERT INTO ordenes_compra 
 (codigo, fecha_emision, id_proveedor, id_cotizacion, 
  id_usuario_solicita, id_usuario_aprueba, estado, total) 
 VALUES 
 ('OC-2025-001', '2025-05-12', 1, 1, 3, 1, 'ENVIADA', 155.00);

INSERT INTO detalle_orden_compra 
 (id_orden, id_producto, cantidad, precio_unitario) 
 VALUES 
 (1, 1, 200, 0.40), 
 (1, 2, 150, 0.45);

INSERT INTO recepciones 
 (id_orden, fecha_recepcion, id_usuario_recepciona, estado, observaciones) 
 VALUES 
 (1, '2025-05-14', 3, 'COMPLETA', 'Todo recibido correctamente');

INSERT INTO productos_recepcion 
 (id_recepcion, id_producto, cantidad_recibida, lote, fecha_vencimiento, estado_producto) 
 VALUES 
 (1, 1, 200, 'L2025PARA01', '2027-05-01', 'OK'), 
 (1, 2, 150, 'L2025IBU01',  '2027-06-01', 'OK');

INSERT INTO notas_pago 
 (id_orden, fecha_pago, monto_total, medio_pago, estado, referencia) 
 VALUES 
 (1, '2025-05-15', 155.00, 'TRANSFERENCIA', 'PAGADO', 'TRX-000123');

INSERT INTO recepciones 
 (id_orden, fecha_recepcion, id_usuario_recepciona, estado, observaciones) 
 VALUES 
 (1, '2025-05-16', 3, 'CON_RECLAMO', '10 unidades de Amoxicilina dañadas');

INSERT INTO incidencias_recepcion 
 (id_recepcion, tipo, descripcion, resuelto) 
 VALUES 
 (2, 'DANADO', 'Blísteres aplastados en el transporte', 0);
