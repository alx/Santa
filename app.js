
/**
 * Module dependencies.
 */

var express = require('express'),
    http    = require('http'),
    path    = require('path'),
    routes  = require('./routes'),
    friend  = require('./routes/friend'),
    gift    = require('./routes/gift'),
    moment  = require('moment'),
    db      = require('./models');

var app = express();

// all environments
app.enable('trust proxy')
app.set('port', process.env.PORT || 3000);
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');
app.use(express.logger('dev'));
app.use(express.json());
app.use(express.urlencoded());
app.use(express.methodOverride());
app.use(app.router);
app.use(express.static(path.join(__dirname, 'public')));

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

app.get('/', routes.index)
app.get('/admin', routes.admin)

app.post('/friends/create', friend.create)
app.post('/friends/:friend_id/openGift', friend.openGift)

app.post('/friends/:friend_id/gifts/create', gift.create)
app.get('/friends/:friend_id/gifts/:gift_id/destroy', gift.destroy)

db
  .sequelize
  .sync()
  .complete(function(err) {
    if (err) {
      throw err
    } else {
      http.createServer(app).listen(app.get('port'), function(){
        console.log('Express server listening on port ' + app.get('port'))
      })
    }
  })
