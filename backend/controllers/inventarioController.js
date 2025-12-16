
const db = require('../db/mysqlAdapter');

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



const listarInventario = async (req, res) => {
  
  try {
    const result = await db.query(
      `SELECT idProducto AS id, codigo, nombre, descripcion, stockActual, stockMinimo, stockMaximo,
              unidadMedida, precioCompra, precioVenta, ubicacion, lote, fechaVencimiento, estado, idCategoria
       FROM producto ORDER BY idProducto DESC`
    );

    const rows = getRows(result);
    res.json({ ok: true, data: rows });

  } catch (error) {
    res.status(500).json({ ok: false, message: 'Error al obtener inventario', error: error.message });
  }
};


const listarFaltantes = async (req, res) => {
  try {
    const result = await db.query(
      `SELECT idProducto AS id, codigo, nombre, descripcion, stockActual, stockMinimo, stockMaximo,
              unidadMedida, precioCompra, precioVenta, ubicacion, lote, fechaVencimiento, estado, idCategoria
       FROM producto WHERE stockActual < stockMinimo ORDER BY stockActual ASC`
    );
    const rows = getRows(result);
    res.json({ ok: true, data: rows });
  } catch (error) {
    res.status(500).json({ ok: false, message: 'Error al revisar faltantes', error: error.message });
  }
};

const buscarInventario = async (req, res) => {
  const term = (req.query.q || req.query.nombre || '').trim();
  if (!term) {
    return res.status(400).json({ ok: false, message: 'Parametro de busqueda vacio' });
  }

  try {
    const likeTerm = `%${term}%`;
    const result = await db.query(
      `SELECT idProducto AS id, codigo, nombre, descripcion, stockActual, stockMinimo, stockMaximo,
              unidadMedida, precioCompra, precioVenta, ubicacion, lote, fechaVencimiento, estado, idCategoria
       FROM producto WHERE nombre LIKE ? OR descripcion LIKE ? OR codigo LIKE ? ORDER BY nombre ASC`,
      [likeTerm, likeTerm, likeTerm]
    );
    const rows = getRows(result);
    res.json({ ok: true, data: rows });
  } catch (error) {
    res.status(500).json({ ok: false, message: 'Error al buscar productos', error: error.message });
  }
};

const crearProducto = async (req, res) => {
  const {
    codigo = null,
    nombre,
    descripcion = '',
    stockActual = 0,
    stockMinimo = 0,
    stockMaximo = null,
    unidadMedida,
    precioCompra = 0,
    precioVenta = 0,
    ubicacion = '',
    lote = null,
    fechaVencimiento = null,
    idCategoria = null,
  } = req.body || {};

  if (!nombre) {
    return res.status(400).json({ ok: false, message: 'El nombre del producto es obligatorio' });
  }
  if (!unidadMedida) {
    return res.status(400).json({ ok: false, message: 'La unidad de medida es obligatoria' });
  }

  try {
    const payload = [
      codigo || null,
      nombre,
      descripcion,
      toNumber(stockActual),
      toNumber(stockMinimo),
      stockMaximo !== null ? toNumber(stockMaximo) : null,
      toNumber(precioCompra),
      toNumber(precioVenta),
      unidadMedida,
      ubicacion || '',
      lote || null,
      fechaVencimiento || null,
      idCategoria || null,
    ];

    const packet = getPacket(
      await db.query(
        `INSERT INTO producto
        (codigo, nombre, descripcion, stockActual, stockMinimo, stockMaximo, precioCompra, precioVenta, unidadMedida, ubicacion, lote, fechaVencimiento, idCategoria)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
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

const actualizarProducto = async (req, res) => {
  const id = Number(req.params.id);
  const {
    codigo = null,
    nombre,
    descripcion = '',
    stockActual = 0,
    stockMinimo = 0,
    stockMaximo = null,
    unidadMedida,
    precioCompra = 0,
    precioVenta = 0,
    ubicacion = '',
    lote = null,
    fechaVencimiento = null,
    idCategoria = null,
  } = req.body || {};

  if (!id) {
    return res.status(400).json({ ok: false, message: 'ID invalido' });
  }

  if (!nombre) {
    return res.status(400).json({ ok: false, message: 'El nombre del producto es obligatorio' });
  }
  if (!unidadMedida) {
    return res.status(400).json({ ok: false, message: 'La unidad de medida es obligatoria' });
  }

  try {
    const payload = [
      codigo || null,
      nombre,
      descripcion,
      toNumber(stockActual),
      toNumber(stockMinimo),
      stockMaximo !== null ? toNumber(stockMaximo) : null,
      toNumber(precioCompra),
      toNumber(precioVenta),
      unidadMedida,
      ubicacion || '',
      lote || null,
      fechaVencimiento || null,
      idCategoria || null,
      id,
    ];

    const packet = getPacket(
      await db.query(
        `UPDATE producto
         SET codigo = ?, nombre = ?, descripcion = ?, stockActual = ?, stockMinimo = ?, stockMaximo = ?,
             precioCompra = ?, precioVenta = ?, unidadMedida = ?, ubicacion = ?, lote = ?, fechaVencimiento = ?, idCategoria = ?
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
