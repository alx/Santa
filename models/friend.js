module.exports = function(sequelize, DataTypes) {
  var Friend = sequelize.define('Friend', {
    name: DataTypes.STRING,
    img: DataTypes.STRING,
    openingCode: DataTypes.INTEGER,
    message: DataTypes.TEXT
  }, {
    associate: function(models) {
      Friend.hasMany(models.Gift)
    }
  })

  return Friend
}
