const express = require('express');

const app = express();

const inventarioRouter = express.Router();
const cotizacionRouter = express.Router();

app.use('/inventario', inventarioRouter);
app.use('/cotizacion', cotizacionRouter);

module.exports = app;

