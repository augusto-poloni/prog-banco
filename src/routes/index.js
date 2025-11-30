const express = require('express');
const routes = express.Router();

const comandaController = require('../controllers/comandaController');
const itemCardapioController = require('../controllers/itemCardapioController');
const pedidoController = require('../controllers/pedidoController');
const viewKDSController = require('../controllers/viewKDSController');
const authController = require('../controllers/authController'); // <--- Importe aqui

routes.post('/login', authController.login);
routes.post('/register', authController.register);


routes.post('/cardapio', itemCardapioController.store);
routes.get('/cardapio', itemCardapioController.index);
routes.delete('/cardapio/:id', itemCardapioController.delete);

routes.post('/comandas', comandaController.abrir); 
routes.put('/comandas/:id/fechar', comandaController.fechar);
routes.get('/comandas/abertas', comandaController.indexAbertas);
routes.get('/comandas/:id', comandaController.show);
routes.post('/comandas/:id/adicionar', pedidoController.adicionarItem);

routes.get('/kds/cozinha', viewKDSController.getCozinha);
routes.get('/kds/copa', viewKDSController.getCopa);
routes.put('/pedidos/:itemId/status', pedidoController.atualizarStatus);

module.exports = routes;