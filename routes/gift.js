var db = require('../models')

exports.create = function(req, res) {
  db.Friend.find({ where: { id: req.param('friend_id') } }).success(function(friend) {
    db.Gift.create({
      name: req.param('name'),
      link: req.param('link'),
      img: req.param('img'),
      wrap: "wrap-" + Math.floor(Math.random() * 16) + ".png"
    }).success(function(gift) {
      gift.setFriend(friend).success(function() {
        res.redirect('/');
      })
    })
  })
}

exports.destroy = function(req, res) {
  db.Friend.find({ where: { id: req.param('friend_id') } }).success(function(friend) {
    db.Gift.find({ where: { id: req.param('gift_id') } }).success(function(gift) {
      gift.setFriend(null).success(function() {
        res.redirect('/');
      })
    })
  })
}
