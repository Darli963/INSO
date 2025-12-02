const db = require('../db/mysqlAdapter')

const getRows = (result) => {
  if (Array.isArray(result) && Array.isArray(result[0])) return result[0]
  if (Array.isArray(result)) return result
  return []
}

const listarProveedores = async (req, res) => {
  try {
    const result = await db.query(
      'SELECT idProveedor AS id, nombre, email, telefono FROM proveedor ORDER BY nombre ASC'
    )
    const rows = getRows(result)
    res.json({ ok: true, data: rows })
  } catch (error) {
    res.status(500).json({ ok: false, message: 'Error al listar proveedores', error: error.message })
  }
}

const enviarCotizacion = async (req, res) => {
  const { proveedorId, items = [], observaciones = null } = req.body || {}
  if (!proveedorId || !Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ ok: false, message: 'Datos de cotizacion incompletos' })
  }
  try {
    const provRows = getRows(
      await db.query('SELECT idProveedor FROM proveedor WHERE idProveedor = ?', [Number(proveedorId)])
    )
    if (!provRows.length) {
      return res.status(404).json({ ok: false, message: 'Proveedor no existe' })
    }

    for (const item of items) {
      const productoId = Number(item.productoId)
      const cantidad = Number(item.cantidad)
      if (!productoId) {
        return res.status(400).json({ ok: false, message: 'productoId es obligatorio' })
      }
      if (!Number.isFinite(cantidad) || cantidad <= 0) {
        return res.status(400).json({ ok: false, message: 'cantidad debe ser mayor a cero' })
      }
      const prodRows = getRows(
        await db.query('SELECT idProducto FROM producto WHERE idProducto = ?', [productoId])
      )
      if (!prodRows.length) {
        return res.status(404).json({ ok: false, message: `Producto ${productoId} no existe` })
      }
    }

    const insertRes = await db.query(
      'INSERT INTO cotizacion (idProveedor, estado, observaciones) VALUES (?, ?, ?)',
      [Number(proveedorId), 'PENDIENTE', observaciones]
    )
    const idCotizacion = Array.isArray(insertRes) && insertRes[0]?.insertId ? insertRes[0].insertId : null
    if (!idCotizacion) {
      return res.status(500).json({ ok: false, message: 'No se pudo crear la cotizacion' })
    }

    for (const item of items) {
      const productoId = Number(item.productoId)
      const cantidad = Number(item.cantidad)
      const precioUnitario = item.precioUnitario != null ? Number(item.precioUnitario) : null
      await db.query(
        'INSERT INTO detalle_cotizacion (idCotizacion, idProducto, cantidad, precioUnitario) VALUES (?, ?, ?, ?)',
        [idCotizacion, productoId, cantidad, precioUnitario]
      )
    }

    res.status(201).json({ ok: true, id: idCotizacion, message: 'Cotizacion enviada' })
  } catch (error) {
    res.status(500).json({ ok: false, message: 'Error al enviar cotizacion', error: error.message })
  }
}

module.exports = { listarProveedores, enviarCotizacion }
