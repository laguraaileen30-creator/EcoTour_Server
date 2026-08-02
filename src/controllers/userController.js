exports.getProfile = async (req, res) => {
  res.status(200).json({
    message: 'Profile endpoint ready',
    user: req.user,
  });
};

exports.updateProfile = async (req, res) => {
  res.status(200).json({ message: 'Profile update endpoint ready' });
};
