const express = require('express')
const { listarProveedores, enviarCotizacion } = require('../controllers/cotizacionController')

const router = express.Router()

router.get('/proveedores', listarProveedores)
router.post('/enviar', enviarCotizacion)

module.exports = router
