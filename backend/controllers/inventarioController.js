
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

const ALLOWED_UNITS = new Set(['unidad','caja','paquete','tableta','cápsula','litro','frasco']);
const ALLOWED_LOCATIONS = new Set(['A1-EST1','A1-EST2','A2-EST1','A2-EST2','B1-EST1','C1-EST1','C1-EST2','C2-EST1','D1-EST1','E1-EST1']);



const listarInventario = async (req, res) => {
  
  try {
    const result = await db.query(
      `SELECT idProducto AS id, codigo, nombre, descripcion, stockActual, stockMinimo, stockMaximo,
              unidadMedida, precioCompra, precioVenta, ubicacion, fechaVencimiento, estado
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
              unidadMedida, precioCompra, precioVenta, ubicacion, fechaVencimiento, estado
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
              unidadMedida, precioCompra, precioVenta, ubicacion, fechaVencimiento, estado
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
    fechaVencimiento = null,
    
  } = req.body || {};

  if (!nombre) {
    return res.status(400).json({ ok: false, message: 'El nombre del producto es obligatorio' });
  }
  if (!unidadMedida) {
    return res.status(400).json({ ok: false, message: 'La unidad de medida es obligatoria' });
  }
  if (!ALLOWED_UNITS.has(String(unidadMedida))) {
    return res.status(400).json({ ok: false, message: 'Unidad de medida inválida. Usa unidad, caja, paquete, tableta, cápsula, litro o frasco' });
  }
  if (ubicacion && String(ubicacion).trim() && !ALLOWED_LOCATIONS.has(String(ubicacion))) {
    return res.status(400).json({ ok: false, message: 'Ubicación inválida. Selecciona una ubicación predefinida' });
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
      fechaVencimiento || null,
    ];

    const packet = getPacket(
      await db.query(
        `INSERT INTO producto
        (codigo, nombre, descripcion, stockActual, stockMinimo, stockMaximo, precioCompra, precioVenta, unidadMedida, ubicacion, fechaVencimiento)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
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
  const body = req.body || {};

  if (!id) {
    return res.status(400).json({ ok: false, message: 'ID invalido' });
  }

  const fields = {};
  if (body.codigo !== undefined) fields.codigo = body.codigo || null;
  if (body.nombre !== undefined) fields.nombre = body.nombre;
  if (body.descripcion !== undefined) fields.descripcion = body.descripcion || '';
  if (body.stockActual !== undefined) fields.stockActual = toNumber(body.stockActual);
  if (body.stockMinimo !== undefined) fields.stockMinimo = toNumber(body.stockMinimo);
  if (body.stockMaximo !== undefined) fields.stockMaximo = body.stockMaximo !== null ? toNumber(body.stockMaximo) : null;
  if (body.precioCompra !== undefined) fields.precioCompra = toNumber(body.precioCompra);
  if (body.precioVenta !== undefined) fields.precioVenta = toNumber(body.precioVenta);
  if (body.unidadMedida !== undefined) fields.unidadMedida = body.unidadMedida;
  if (body.ubicacion !== undefined) fields.ubicacion = body.ubicacion || '';
  if (body.fechaVencimiento !== undefined) fields.fechaVencimiento = body.fechaVencimiento || null;

  if (fields.unidadMedida !== undefined) {
    if (!fields.unidadMedida) {
      return res.status(400).json({ ok: false, message: 'La unidad de medida es obligatoria' });
    }
    if (!ALLOWED_UNITS.has(String(fields.unidadMedida))) {
      return res.status(400).json({ ok: false, message: 'Unidad de medida inválida. Usa unidad, caja, paquete, tableta, cápsula, litro o frasco' });
    }
  }
  if (fields.ubicacion !== undefined) {
    if (fields.ubicacion && String(fields.ubicacion).trim() && !ALLOWED_LOCATIONS.has(String(fields.ubicacion))) {
      return res.status(400).json({ ok: false, message: 'Ubicación inválida. Selecciona una ubicación predefinida' });
    }
  }

  const keys = Object.keys(fields);
  if (keys.length === 0) {
    return res.status(400).json({ ok: false, message: 'No hay campos para actualizar' });
  }

  const setClause = keys.map((k) => `${k} = ?`).join(', ');
  const params = keys.map((k) => fields[k]);
  params.push(id);

  try {
    const packet = getPacket(
      await db.query(
        `UPDATE producto SET ${setClause} WHERE idProducto = ?`,
        params
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
