const router = require('express').Router();
const loginRoutes = require('./login.route');
const signupRoute = require('./signup.route');
const placeRoutes = require('./recommendation.route');

router.use('/login', loginRoutes);
router.use('/signup', signupRoute);
router.use('/places',placeRoutes);

module.exports = router;
