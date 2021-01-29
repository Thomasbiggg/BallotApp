var express = require('express');
var router = express.Router();

/* GET voter listing. */
router.get('/', function(req, res, next) {
  res.render('voter.html');
});

module.exports = router;
