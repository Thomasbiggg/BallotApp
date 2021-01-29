var express = require('express');
var router = express.Router();

/* GET manager page. */
router.get('/', function (req, res, next) {
    res.render('manager.html');
});

module.exports = router;