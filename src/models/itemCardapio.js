const { Model, DataTypes } = require('sequelize');

class ItemCardapio extends Model {
  static init(sequelize) {
    super.init({
      nome: DataTypes.STRING,
      descricao: DataTypes.TEXT,
      preco: DataTypes.DECIMAL(10, 2),
      tipo: DataTypes.ENUM('PRATO', 'BEBIDA'), 
      disponivel: DataTypes.BOOLEAN
    }, { 
      sequelize,
      tableName: 'produtos', 
      underscored: true 
    });
  }
}
module.exports = ItemCardapio;