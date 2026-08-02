exports.createPayment = async (req, res) => {
  res.status(201).json({ message: 'Payment endpoint ready' });
};

exports.getPayments = async (req, res) => {
  res.status(200).json({ message: 'Payments listing endpoint ready' });
};
