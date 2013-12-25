module.exports = function(sequelize, DataTypes) {
  var Gift = sequelize.define('Gift', {
    name: DataTypes.TEXT,
    link: DataTypes.TEXT,
    img: DataTypes.STRING,
    wrap: DataTypes.STRING,
    isOpened: {type: DataTypes.BOOLEAN, defaultValue: false}
  }, {
    associate: function(models) {
      Gift.belongsTo(models.Friend)
    }
  })

  return Gift
}
