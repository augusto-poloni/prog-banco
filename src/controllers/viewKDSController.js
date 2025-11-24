const { ItemPedido, ItemCardapio, Comanda } = require('../models');
const { Op } = require('sequelize');

module.exports = {
  async getCozinha(req, res) {
    const pedidosCozinha = await ItemPedido.findAll({
      where: {
        status: { [Op.in]: ['PENDENTE', 'EM_PREPARO', 'PRONTO'] }
      },
      include: [
        {
          model: ItemCardapio,
          as: 'item',
          where: { tipo: 'PRATO' }, 
          attributes: ['nome']
        },
        {
          model: Comanda,
          as: 'comanda',
          attributes: ['numeroMesa']
        }
      ],
      order: [['createdAt', 'ASC']] 
    });

    const agrupado = groupByComanda(pedidosCozinha);
    return res.json(agrupado);
  },

  async getCopa(req, res) {
    const pedidosCopa = await ItemPedido.findAll({
      where: {
        status: { [Op.in]: ['PENDENTE', 'EM_PREPARO', 'PRONTO'] }
      },
      include: [
        {
          model: ItemCardapio,
          as: 'item',
          where: { tipo: 'BEBIDA' },
          attributes: ['nome']
        },
        {
          model: Comanda,
          as: 'comanda',
          attributes: ['numeroMesa']
        }
      ],
      order: [['createdAt', 'ASC']]
    });

    const agrupado = groupByComanda(pedidosCopa);
    return res.json(agrupado);
  }
};

function groupByComanda(pedidos) {
  return pedidos.reduce((acc, pedido) => {
    const comandaNum = pedido.comanda.numeroMesa;
    if (!acc[comandaNum]) {
      acc[comandaNum] = [];
    }
    acc[comandaNum].push(pedido);
    return acc;
  }, {});
}
