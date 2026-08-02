exports.getGallery = async (req, res) => {
  res.status(200).json({ message: 'Gallery endpoint ready' });
};

exports.createGalleryItem = async (req, res) => {
  res.status(201).json({ message: 'Gallery creation endpoint ready' });
};
