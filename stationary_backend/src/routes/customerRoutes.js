const express = require('express');
const router = express.Router();
const controller = require('../controllers/customerController');

// Function-ka validation-ka (Hubinta in magaca yahay xarfo oo kaliya)
const validateName = (req, res, next) => {
    const { name } = req.body;
    // Hubi haddii name uu yahay number ama uu ka kooban yahay lambaro
    // RegExp-kan wuxuu u oggolaanayaa xarfo iyo meelaha banaan (spaces)
    const isOnlyLetters = /^[a-zA-Z\s]+$/;

    if (name && !isOnlyLetters.test(name)) {
        return res.status(400).json({ 
            error: "Khalad: Magaca waa inuu ahaadaa xarfo oo kaliya, lambaro lama oggola." 
        });
    }
    next();
};

router.get('/', controller.getCustomers);
// Waxaan ku darnay validateName-ka middleware ahaan
router.post('/', validateName, controller.addCustomer); 
router.put('/:id', validateName, controller.editCustomer);
router.delete('/:id', controller.removeCustomer);

module.exports = router;