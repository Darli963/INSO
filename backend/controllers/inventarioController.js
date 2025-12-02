
const db = require('../db/mysqlAdapter');

// Helpers to normalize mysql2 outputs without assuming adapter internals
const getRows = (result) => {
  if (Array.isArray(result) && Array.isArray(result[0])) {
    return result[0];
  }
  if (Array.isArray(result)) {
    return result;
  }
  return [];
};

const getPacket = (result) => (Array.isArray(result) ? result[0] : result);

const toNumber = (value, fallback = 0) => {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
};

// Armamos filtros según nivel de stock (tomando columnas del diagrama de BD: stockActual, stockMinimo, stockMaximo)
const buildNivelFiltro = (nivel) => {
  const n = (nivel || '').toLowerCase();
  if (n === 'bajo') return { where: 'WHERE stockActual < stockMinimo', params: [] };
  if (n === 'alto') return { where: 'WHERE stockMaximo IS NOT NULL AND stockActual > stockMaximo', params: [] };
  return { where: '', params: [] };
};

// GET /inventario?nivel=todos|bajo|alto
const listarInventario = async (req, res) => {
  const { where, params } = buildNivelFiltro(req.query.nivel);
  try {
    const result = await db.query(
      `SELECT idProducto AS id, codigo, nombre, descripcion, stockActual, stockMinimo, stockMaximo,
              precioVenta, precioCompra, ubicacion, fechaVencimiento, idCategoria, idProveedor
       FROM producto ${where} ORDER BY idProducto DESC`,
      params
    );
    const rows = getRows(result);
    res.json({ ok: true, data: rows });
  } catch (error) {
    res.status(500).json({ ok: false, message: 'Error al obtener inventario', error: error.message });
  }
};

// GET /inventario/faltantes
const listarFaltantes = async (req, res) => {
  try {
    const result = await db.query(
      `SELECT idProducto AS id, codigo, nombre, descripcion, stockActual, stockMinimo, stockMaximo,
              precioVenta, precioCompra, ubicacion, fechaVencimiento, idCategoria, idProveedor
       FROM producto WHERE stockActual < stockMinimo ORDER BY stockActual ASC`
    );
    const rows = getRows(result);
    res.json({ ok: true, data: rows });
  } catch (error) {
    res.status(500).json({ ok: false, message: 'Error al revisar faltantes', error: error.message });
  }
};

// GET /inventario/buscar?q=texto
const buscarInventario = async (req, res) => {
  const term = (req.query.q || req.query.nombre || '').trim();
  if (!term) {
    return res.status(400).json({ ok: false, message: 'Parametro de busqueda vacio' });
  }

  try {
    const likeTerm = `%${term}%`;
    const result = await db.query(
      `SELECT idProducto AS id, codigo, nombre, descripcion, stockActual, stockMinimo, stockMaximo,
              precioVenta, precioCompra, ubicacion, fechaVencimiento, idCategoria, idProveedor
       FROM producto WHERE nombre LIKE ? OR descripcion LIKE ? OR codigo LIKE ? ORDER BY nombre ASC`,
      [likeTerm, likeTerm, likeTerm]
    );
    const rows = getRows(result);
    res.json({ ok: true, data: rows });
  } catch (error) {
    res.status(500).json({ ok: false, message: 'Error al buscar productos', error: error.message });
  }
};

// POST /inventario
const crearProducto = async (req, res) => {
  const {
    codigo = null,
    nombre,
    descripcion = '',
    stockActual = 0,
    stockMinimo = 0,
    stockMaximo = null,
    precioCompra = 0,
    precioVenta = 0,
    ubicacion = '',
    fechaVencimiento = null,
    idCategoria = null,
    idProveedor = null,
  } = req.body || {};

  if (!nombre) {
    return res.status(400).json({ ok: false, message: 'El nombre del producto es obligatorio' });
  }

  try {
    const payload = [
      codigo || null,
      nombre,
      descripcion,
      toNumber(stockActual),
      toNumber(stockMinimo),
      stockMaximo !== null ? toNumber(stockMaximo) : null,
      toNumber(precioVenta),
      toNumber(precioCompra),
      ubicacion || '',
      fechaVencimiento || null,
      idCategoria || null,
      idProveedor || null,
    ];

    const packet = getPacket(
      await db.query(
        `INSERT INTO producto
        (codigo, nombre, descripcion, stockActual, stockMinimo, stockMaximo, precioVenta, precioCompra, ubicacion, fechaVencimiento, idCategoria, idProveedor)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        payload
      )
    );

    res.status(201).json({
      ok: true,
      id: packet?.insertId,
      message: 'Producto creado',
    });
  } catch (error) {
    res.status(500).json({ ok: false, message: 'Error al crear producto', error: error.message });
  }
};

// PUT /inventario/:id
const actualizarProducto = async (req, res) => {
  const id = Number(req.params.id);
  const {
    codigo = null,
    nombre,
    descripcion = '',
    stockActual = 0,
    stockMinimo = 0,
    stockMaximo = null,
    precioCompra = 0,
    precioVenta = 0,
    ubicacion = '',
    fechaVencimiento = null,
    idCategoria = null,
    idProveedor = null,
  } = req.body || {};

  if (!id) {
    return res.status(400).json({ ok: false, message: 'ID invalido' });
  }

  if (!nombre) {
    return res.status(400).json({ ok: false, message: 'El nombre del producto es obligatorio' });
  }

  try {
    const payload = [
      codigo || null,
      nombre,
      descripcion,
      toNumber(stockActual),
      toNumber(stockMinimo),
      stockMaximo !== null ? toNumber(stockMaximo) : null,
      toNumber(precioVenta),
      toNumber(precioCompra),
      ubicacion || '',
      fechaVencimiento || null,
      idCategoria || null,
      idProveedor || null,
      id,
    ];

    const packet = getPacket(
      await db.query(
        `UPDATE producto
         SET codigo = ?, nombre = ?, descripcion = ?, stockActual = ?, stockMinimo = ?, stockMaximo = ?,
             precioVenta = ?, precioCompra = ?, ubicacion = ?, fechaVencimiento = ?, idCategoria = ?, idProveedor = ?
         WHERE idProducto = ?`,
        payload
      )
    );

    if (!packet || packet.affectedRows === 0) {
      return res.status(404).json({ ok: false, message: 'Producto no encontrado' });
    }

    res.json({ ok: true, message: 'Producto actualizado' });
  } catch (error) {
    res.status(500).json({ ok: false, message: 'Error al actualizar producto', error: error.message });
  }
};

// DELETE /inventario/:id
const eliminarProducto = async (req, res) => {
  const id = Number(req.params.id);

  if (!id) {
    return res.status(400).json({ ok: false, message: 'ID invalido' });
  }

  try {
    const packet = getPacket(await db.query('DELETE FROM producto WHERE idProducto = ?', [id]));

    if (!packet || packet.affectedRows === 0) {
      return res.status(404).json({ ok: false, message: 'Producto no encontrado' });
    }

    res.json({ ok: true, message: 'Producto eliminado' });
  } catch (error) {
    res.status(500).json({ ok: false, message: 'Error al eliminar producto', error: error.message });
  }
};

module.exports = {
  listarInventario,
  listarFaltantes,
  buscarInventario,
  crearProducto,
  actualizarProducto,
  eliminarProducto,
};
