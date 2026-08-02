exports.getDailyRevenue = async (req, res) => {
  res.status(200).json({ message: 'Daily revenue report endpoint ready' });
};

exports.getMonthlyRevenue = async (req, res) => {
  res.status(200).json({ message: 'Monthly revenue report endpoint ready' });
};
