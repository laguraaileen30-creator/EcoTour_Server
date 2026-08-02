exports.createReservation = async (req, res) => {
  res.status(201).json({ message: 'Reservation creation endpoint ready' });
};

exports.getReservations = async (req, res) => {
  res.status(200).json({ message: 'Reservations listing endpoint ready' });
};

exports.getReservationById = async (req, res) => {
  res.status(200).json({ message: `Reservation ${req.params.id} endpoint ready` });
};
