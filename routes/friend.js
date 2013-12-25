var db = require('../models')

exports.create = function(req, res) {
  db.Friend.create({
    name: req.param('name'),
    img: req.param('img'),
    openingCode: req.param('openingCode'),
    message: req.param('message')
  }).success(function() {
    res.redirect('/');
  })
}

exports.openGift = function(req, res) {
  db.Friend.find({
    where: { id: req.param('friend_id') }
  }).success(function(friend) {
    if(friend.openingCode == parseInt(req.param('openingCode')) ) {
      db.Gift.findAll({ where: {friendId: friend.id} }).success(function(gifts) {
        for(i = 0; i < gifts.length; i++) {
          gifts[i].isOpened = true;
          gifts[i].save().success(function(){});
        }
      });
    }
    res.redirect('/');
  });
}
