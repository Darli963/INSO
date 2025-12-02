const express = require('express')
const {
  listarInventario,
  listarFaltantes,
  buscarInventario,
  crearProducto,
  actualizarProducto,
  eliminarProducto
} = require('../controllers/inventarioController')

const router = express.Router()

router.get('/', listarInventario)
router.get('/faltantes', listarFaltantes)
router.get('/buscar', buscarInventario)
router.post('/', crearProducto)
router.put('/:id', actualizarProducto)
router.delete('/:id', eliminarProducto)

module.exports = router
