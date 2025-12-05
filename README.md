# Sistema de Compras — Inventario y Cotizaciones

Proyecto minimal para gestionar inventario y solicitudes de cotización. Arquitectura en tres servicios con Docker: frontend estático (Nginx), API REST (Node.js + Express) y MySQL.

## Arquitectura
- Repositorio: git clone --branch main --single-branch https://github.com/Darli963/INSO.git 
- Frontend: Nginx sirviendo HTML/CSS/JS en `http://localhost:8080/`
- Backend (API): Express en `http://localhost:3000/`
- Base de datos: MySQL 8 (puerto local `3307`, interno `3306`) con datos semilla por `database/init.sql`

## Requisitos
- Docker Desktop instalado y corriendo

## Puesta en marcha
- En la raíz del repo ejecutar:
  - `docker compose up -d`
- Accesos:
  - Frontend: `http://localhost:8080/`
  - API: `http://localhost:3000/`
  - MySQL (CLI host): `127.0.0.1:3307`, user `root`, pass `secret`, DB `sistema_compras`

## Frontend
- Páginas:
  - `index.html` — acceso a módulos
  - `revisar_faltantes.html` — lista inventario y faltantes, selección para cotizar
  - `interfaz_inventario.html` — CRUD de productos, búsqueda y filtros
  - `enviar_cotizacion.html` — selección de proveedor y envío de cotización

## API (principales endpoints)
- Inventario (`/inventario`):
  - `GET /inventario` — listado (query `nivel=todos|bajo|alto` opcional)
  - `GET /inventario/faltantes` — productos con `stockActual < stockMinimo`
  - `GET /inventario/buscar?q=texto` — búsqueda por nombre/desc/código
  - `POST /inventario` — crear producto
  - `PUT /inventario/:id` — actualizar producto
  - `DELETE /inventario/:id` — eliminar producto
- Cotizaciones (`/cotizaciones`):
  - `GET /cotizaciones/proveedores` — listar proveedores
  - `POST /cotizaciones/enviar` — crear cabecera y detalles
    - Validaciones: `proveedorId` existente, `productoId` existente, `cantidad > 0`

## Base de datos
- `database/init.sql` crea tablas del módulo y carga datos semilla.
- Índices clave:
  - `producto.codigo UNIQUE`, `idx_producto_nombre`, `idx_producto_idProveedor`
  - `detalle_cotizacion.idx_detalle_idCotizacion`

## Desarrollo local (opcional sin Docker)
- Backend:
  - `cd backend && npm ci && npm start`
- Asegura que MySQL esté disponible y variables de entorno:
  - `MYSQL_HOST=localhost`, `MYSQL_USER=root`, `MYSQL_PASSWORD`, `MYSQL_DATABASE=sistema_compras`

## Estructura
```

backend/
  controllers/ db/ routes/ Dockerfile app.js package.json
frontend/
  estilos/ *.html Dockerfile
database/
  init.sql
docker-compose.yml
.gitignore
```


