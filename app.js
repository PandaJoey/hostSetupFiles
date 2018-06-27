var express = require('express');
var app = express();
app.get('/', function (req, res) {
  res.send('Hello World! from Host');
});
app.listen(3012, function () {
  console.log('Example app listening on port 3012!');
});
