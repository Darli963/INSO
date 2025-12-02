const express = require('express')
const cors = require('cors')
const inventarioRouter = require('./routes/inventarioRoutes')
const cotizacionRouter = require('./routes/cotizacionRoutes')

const app = express()

app.use(cors())
app.use(express.json())

app.use('/inventario', inventarioRouter)
app.use('/cotizaciones', cotizacionRouter)

const port = process.env.PORT || 3000
app.listen(port, () => {})

module.exports = app
