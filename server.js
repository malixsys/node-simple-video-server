var mime = require('mime');
var express = require('express'),
ffmpeg = require('fluent-ffmpeg');

var app = express();

app.use(express.static(__dirname + '../../files'));

app.get('/', function(req, res) {
  res.send('index.html');
});

app.get('/video/:filename', function(req, res) {
  
  // make sure you set the correct path to your video file storage
  var pathToMovie = '/home/malix/files/' + req.params.filename; 
  var type = mime.lookup(pathToMovie);
  res.contentType(type);
  var proc = new ffmpeg({ source: pathToMovie, nolog: true })
    // use the 'flashvideo' preset (located in /lib/presets/flashvideo.js)
    .usingPreset('divx')
    // save to stream
    .writeToStream(res, function(retcode, error){
      console.log('file has been converted succesfully');
    });
});

app.listen(7777);