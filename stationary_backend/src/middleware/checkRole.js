// middleware/checkRole.js
const checkRole = (role) => (req, res, next) => {
  if (req.user.role !== role) {
    return res.status(403).json({ message: 'Forbidden: not allowed' });
  }
  next();
};

module.exports = checkRole;