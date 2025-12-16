-- ==============================================================
-- SISTEMA DE COMPRAS - BASE DE DATOS CORREGIDA
-- ==============================================================

CREATE DATABASE IF NOT EXISTS sistema_compras 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

USE sistema_compras;

-- ==============================================================
-- TABLA: usuario
-- ==============================================================
CREATE TABLE IF NOT EXISTS usuario (
  idUsuario INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  email VARCHAR(245) NOT NULL UNIQUE,
  passwordHash VARCHAR(255) NOT NULL,
  rol VARCHAR(45) NOT NULL,
  estado TINYINT(1) NOT NULL DEFAULT 1
);

-- ==============================================================
-- TABLA: categoria_producto
-- ==============================================================
CREATE TABLE IF NOT EXISTS categoria_producto (
  idCategoria INT PRIMARY KEY AUTO_INCREMENT,
  nombreCategoria VARCHAR(100) NOT NULL,
  descripcion VARCHAR(200),
  estado VARCHAR(1) NOT NULL DEFAULT 'A'
);

-- ==============================================================
-- TABLA: proveedor
-- ==============================================================
CREATE TABLE IF NOT EXISTS proveedor (
  idProveedor INT PRIMARY KEY AUTO_INCREMENT,
  ruc VARCHAR(11) UNIQUE,
  razonSocial VARCHAR(100) NOT NULL,
  nombreComercial VARCHAR(15),
  telefono VARCHAR(20),
  direccion VARCHAR(200),
  email VARCHAR(100),
  bancoTipoMoneda VARCHAR(20),
  condicionPago VARCHAR(100),
  estado VARCHAR(1) NOT NULL DEFAULT 'A'
);

-- ==============================================================
-- TABLA: producto
-- ==============================================================
CREATE TABLE IF NOT EXISTS producto (
  idProducto INT PRIMARY KEY AUTO_INCREMENT,
  codigo VARCHAR(50) UNIQUE NOT NULL,
  nombre VARCHAR(150) NOT NULL,
  descripcion VARCHAR(255),
  stockActual INT NOT NULL DEFAULT 0,
  stockMinimo INT NOT NULL DEFAULT 0,
  stockMaximo INT,
  unidadMedida VARCHAR(30) NOT NULL,
  precioCompra DECIMAL(10,2) NOT NULL DEFAULT 0,
  precioVenta DECIMAL(10,2) NOT NULL DEFAULT 0,
  ubicacion VARCHAR(50),
  lote VARCHAR(50),
  fechaVencimiento DATE,
  estado VARCHAR(1) NOT NULL DEFAULT 'A',
  idCategoria INT,
  INDEX idx_producto_nombre (nombre),
  INDEX idx_producto_codigo (codigo),
  INDEX idx_producto_idCategoria (idCategoria),
  FOREIGN KEY (idCategoria) REFERENCES categoria_producto(idCategoria)
);

-- ==============================================================
-- TABLA: recepcion
-- ==============================================================
CREATE TABLE IF NOT EXISTS recepcion (
  idRecepcion INT PRIMARY KEY AUTO_INCREMENT,
  fechaRecepcion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tipoComprobante VARCHAR(50),
  numComprobante VARCHAR(25),
  idProveedor INT NOT NULL,
  idUsuario INT NOT NULL,
  INDEX idx_recepcion_proveedor (idProveedor),
  INDEX idx_recepcion_usuario (idUsuario),
  FOREIGN KEY (idProveedor) REFERENCES proveedor(idProveedor),
  FOREIGN KEY (idUsuario) REFERENCES usuario(idUsuario)
);

-- ==============================================================
-- TABLA: detalle_recepcion
-- ==============================================================
CREATE TABLE IF NOT EXISTS detalle_recepcion (
  idDetalleRecepcion INT PRIMARY KEY AUTO_INCREMENT,
  cantidad INT NOT NULL,
  costoUnitario DECIMAL(10,2) NOT NULL,
  observacion VARCHAR(255),
  idRecepcion INT NOT NULL,
  idProducto INT NOT NULL,
  INDEX idx_detalle_recepcion_idRecepcion (idRecepcion),
  INDEX idx_detalle_recepcion_idProducto (idProducto),
  FOREIGN KEY (idRecepcion) REFERENCES recepcion(idRecepcion),
  FOREIGN KEY (idProducto) REFERENCES producto(idProducto)
);

-- ==============================================================
-- TABLA: orden_compra
-- ==============================================================
CREATE TABLE IF NOT EXISTS orden_compra (
  idOrden INT PRIMARY KEY AUTO_INCREMENT,
  codigo VARCHAR(20) NOT NULL UNIQUE,
  fecha DATE NOT NULL,
  fechaEntregaEstimada DATE,
  subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
  totalImpuesto DECIMAL(10,2) NOT NULL DEFAULT 0,
  total DECIMAL(10,2) NOT NULL DEFAULT 0,
  observaciones VARCHAR(255),
  idProveedor INT NOT NULL,
  idUsuario INT NOT NULL,
  INDEX idx_orden_compra_proveedor (idProveedor),
  INDEX idx_orden_compra_usuario (idUsuario),
  FOREIGN KEY (idProveedor) REFERENCES proveedor(idProveedor),
  FOREIGN KEY (idUsuario) REFERENCES usuario(idUsuario)
);

-- ==============================================================
-- TABLA: detalle_orden_compra
-- ==============================================================
CREATE TABLE IF NOT EXISTS detalle_orden_compra (
  idDetalleOC INT PRIMARY KEY AUTO_INCREMENT,
  cantidad INT NOT NULL,
  precioUnitario DECIMAL(10,2) NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  idOrden INT NOT NULL,
  idProducto INT NOT NULL,
  INDEX idx_detalle_oc_idOrden (idOrden),
  INDEX idx_detalle_oc_idProducto (idProducto),
  FOREIGN KEY (idOrden) REFERENCES orden_compra(idOrden),
  FOREIGN KEY (idProducto) REFERENCES producto(idProducto)
);

-- ==============================================================
-- TABLA: nota_pago
-- ==============================================================
CREATE TABLE IF NOT EXISTS nota_pago (
  idPago INT PRIMARY KEY AUTO_INCREMENT,
  num VARCHAR(10),
  codigo VARCHAR(20) UNIQUE,
  fechaPago DATE NOT NULL,
  idOrden INT NOT NULL,
  INDEX idx_nota_pago_idOrden (idOrden),
  FOREIGN KEY (idOrden) REFERENCES orden_compra(idOrden)
);

-- ==============================================================
-- TABLA: cotizacion
-- ==============================================================
CREATE TABLE IF NOT EXISTS cotizacion (
  idCotizacion INT PRIMARY KEY AUTO_INCREMENT,
  codigo VARCHAR(20),
  fechaSolicitud DATE NOT NULL,
  fechaRespuesta DATE,
  estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
  total DECIMAL(10,2),
  observaciones VARCHAR(255),
  idProveedor INT NOT NULL,
  INDEX idx_cotizacion_proveedor (idProveedor),
  FOREIGN KEY (idProveedor) REFERENCES proveedor(idProveedor)
);

-- ==============================================================
-- TABLA: detalle_cotizacion
-- ==============================================================
CREATE TABLE IF NOT EXISTS detalle_cotizacion (
  idDetalle INT PRIMARY KEY AUTO_INCREMENT,
  cantidad INT NOT NULL,
  precioUnitario DECIMAL(10,2) NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  observacion VARCHAR(255),
  idCotizacion INT NOT NULL,
  idProducto INT NOT NULL,
  INDEX idx_detalle_cotizacion_idCotizacion (idCotizacion),
  INDEX idx_detalle_cotizacion_idProducto (idProducto),
  FOREIGN KEY (idCotizacion) REFERENCES cotizacion(idCotizacion),
  FOREIGN KEY (idProducto) REFERENCES producto(idProducto)
);

-- ==============================================================
-- DATOS DE PRUEBA
-- ==============================================================

-- Insertar usuarios
INSERT INTO usuario (nombre, email, passwordHash, rol, estado) VALUES
('Juan Torres (Gerente)', 'juan.gerente@botica.com', 'hash123', 'GERENTE', 1),
('Kiara Aguilar (Asistente)', 'kiara.asistente@botica.com', 'hash123', 'ASISTENTE', 1),
('Lorena Vásquez (Resp. Almacén)', 'lorena.almacen@botica.com', 'hash123', 'RESPONSABLE_ALMACEN', 1),
('Jorge López (Contabilidad)', 'jorge.conta@botica.com', 'hash123', 'CONTABILIDAD', 1);

-- Insertar categorías
INSERT INTO categoria_producto (nombreCategoria, descripcion, estado) VALUES
('Medicamentos', 'Productos farmacéuticos', 'A'),
('Material Médico', 'Instrumentos y material médico', 'A'),
('Insumos', 'Insumos hospitalarios', 'A'),
('Equipamiento', 'Equipos médicos', 'A'),
('Limpieza', 'Productos de limpieza y desinfección', 'A');

-- Insertar proveedores
INSERT INTO proveedor (ruc, razonSocial, nombreComercial, telefono, direccion, email, bancoTipoMoneda, condicionPago, estado) VALUES
('20123456789', 'Distribuidora Farma Norte S.A.C.', 'Farma Norte', '944111222', 'Av. Salud 123 - Trujillo', 'contacto@farmanorte.com', 'BCP - Soles', 'Crédito 30 días', 'A'),
('20456789123', 'Servicios Médicos del Norte S.A.C.', 'Med Norte', '944333444', 'Jr. Bienestar 456 - Trujillo', 'ventas@serviciosmednorte.com', 'BBVA - Soles', 'Contado', 'A'),
('20987654321', 'Productos Naturales Vitales S.A.', 'Vitales', '944555666', 'Av. Naturaleza 789 - Trujillo', 'info@vitales.com', 'Interbank - Soles', 'Crédito 15 días', 'A');

-- Insertar productos
INSERT INTO producto (codigo, nombre, descripcion, stockActual, stockMinimo, stockMaximo, unidadMedida, precioCompra, precioVenta, ubicacion, estado, idCategoria) VALUES
('P001', 'Paracetamol 500mg', 'Tabletas analgésicas', 200, 50, 500, 'tableta', 0.40, 0.80, 'A1-EST1', 'A', 1),
('P002', 'Ibuprofeno 400mg', 'Tabletas antiinflamatorias', 150, 40, 400, 'tableta', 0.45, 0.90, 'A1-EST2', 'A', 1),
('P003', 'Amoxicilina 500mg', 'Cápsulas antibiótico', 100, 30, 300, 'cápsula', 0.55, 1.10, 'A2-EST1', 'A', 1),
('P004', 'Omeprazol 20mg', 'Cápsulas gastroresistentes', 80, 25, 250, 'cápsula', 0.50, 1.00, 'A2-EST2', 'A', 1),
('P005', 'Jarabe para la tos', 'Jarabe pediátrico 120ml', 50, 15, 150, 'frasco', 18.90, 35.00, 'B1-EST1', 'A', 1),
('P006', 'Guantes Nitrilo', 'Talla M, caja x100', 20, 10, 100, 'caja', 25.00, 45.00, 'C1-EST1', 'A', 2),
('P007', 'Mascarilla Quirúrgica', 'Caja x50 unidades', 150, 50, 300, 'caja', 8.50, 15.00, 'C1-EST2', 'A', 2),
('P008', 'Termómetro Digital', 'Termómetro infrarrojo', 15, 5, 30, 'unidad', 45.00, 85.00, 'D1-EST1', 'A', 4),
('P009', 'Alcohol 70%', 'Desinfectante 1 litro', 80, 30, 200, 'litro', 8.00, 15.00, 'E1-EST1', 'A', 5),
('P010', 'Gasas Estériles', 'Paquete x100 unidades', 60, 20, 150, 'paquete', 12.00, 22.00, 'C2-EST1', 'A', 2);

-- Insertar recepciones
INSERT INTO recepcion (fechaRecepcion, tipoComprobante, numComprobante, idProveedor, idUsuario) VALUES
('2025-05-14 10:30:00', 'FACTURA', 'F001-00123', 1, 3),
('2025-05-16 14:15:00', 'FACTURA', 'F001-00145', 2, 3);

-- Insertar detalles de recepción
INSERT INTO detalle_recepcion (cantidad, costoUnitario, observacion, idRecepcion, idProducto) VALUES
(200, 0.40, 'Lote L2025PARA01, Venc: 2027-05-01', 1, 1),
(150, 0.45, 'Lote L2025IBU01, Venc: 2027-06-01', 1, 2),
(100, 0.55, 'Lote L2025AMX01, Venc: 2026-12-01', 2, 3),
(50, 18.90, 'Lote L2025JAR01, Venc: 2026-08-01', 2, 5);

-- Insertar órdenes de compra
INSERT INTO orden_compra (codigo, fecha, fechaEntregaEstimada, subtotal, totalImpuesto, total, observaciones, idProveedor, idUsuario) VALUES
('OC-2025-001', '2025-05-12', '2025-05-14', 147.50, 26.55, 174.05, 'Pedido urgente de analgésicos', 1, 1),
('OC-2025-002', '2025-05-15', '2025-05-18', 1000.00, 180.00, 1180.00, 'Pedido mensual de insumos', 2, 1);

-- Insertar detalles de orden de compra
INSERT INTO detalle_orden_compra (cantidad, precioUnitario, subtotal, idOrden, idProducto) VALUES
(200, 0.40, 80.00, 1, 1),
(150, 0.45, 67.50, 1, 2),
(100, 0.55, 55.00, 2, 3),
(50, 18.90, 945.00, 2, 5);

-- Insertar notas de pago
INSERT INTO nota_pago (num, codigo, fechaPago, idOrden) VALUES
('0001', 'NP-2025-001', '2025-05-15', 1),
('0002', 'NP-2025-002', '2025-05-20', 2);

-- Insertar cotizaciones
INSERT INTO cotizacion (codigo, fechaSolicitud, fechaRespuesta, estado, total, observaciones, idProveedor) VALUES
('COT-2025-001', '2025-05-10', '2025-05-11', 'APROBADA', 147.50, 'Cotización analgésicos - Aprobada', 1),
('COT-2025-002', '2025-05-12', NULL, 'PENDIENTE', 1000.00, 'Cotización mensual insumos', 2);

-- Insertar detalles de cotización
INSERT INTO detalle_cotizacion (cantidad, precioUnitario, subtotal, observacion, idCotizacion, idProducto) VALUES
(200, 0.40, 80.00, 'Paracetamol 500mg', 1, 1),
(150, 0.45, 67.50, 'Ibuprofeno 400mg', 1, 2),
(100, 0.55, 55.00, 'Amoxicilina 500mg', 2, 3),
(50, 18.90, 945.00, 'Jarabe para la tos', 2, 5);

-- ==============================================================
-- CONSULTAS DE VERIFICACIÓN
-- ==============================================================

-- Verificar estructura de la base de datos
-- SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, COLUMN_KEY
-- FROM INFORMATION_SCHEMA.COLUMNS
-- WHERE TABLE_SCHEMA = 'sistema_compras'
-- ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- Verificar relaciones (claves foráneas)
-- SELECT 
--   TABLE_NAME,
--   COLUMN_NAME,
--   REFERENCED_TABLE_NAME,
--   REFERENCED_COLUMN_NAME
-- FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
-- WHERE TABLE_SCHEMA = 'sistema_compras'
--   AND REFERENCED_TABLE_NAME IS NOT NULL;