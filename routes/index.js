var db = require('../models')

exports.index = function(req, res){
  db.Friend.findAll({
    include: [ db.Gift ]
  }).success(function(friends) {
    res.render('index', {
      friends: friends
    })
  })
}

exports.admin = function(req, res){
  db.Friend.findAll({
    include: [ db.Gift ]
  }).success(function(friends) {
    res.render('index', {
      isAdmin: true,
      friends: friends
    })
  })
}
