const Book = require('../models/bookModel');

// Get all books
const getBooks = async (req, res) => {
  try {
    const books = await Book.getBooks();
    res.json(books);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Add a new book or item
const addBook = async (req, res) => {
  try {
    const { title, author, price, type } = req.body; // Waxaa lagu daray type
    if (!title || !price) {
      return res.status(400).json({ message: 'Title and price are required' });
    }
    const newBook = await Book.createBook(title, author, price, type);
    res.status(201).json(newBook);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Update a book or item
const updateBook = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, author, price, type } = req.body; // Waxaa lagu daray type
    if (!title || !price) {
      return res.status(400).json({ message: 'Title and price are required' });
    }
    const updatedBook = await Book.updateBook(id, title, author, price, type);
    res.json(updatedBook);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Delete a book or item
const deleteBook = async (req, res) => {
  try {
    const { id } = req.params;
    await Book.deleteBook(id);
    res.json({ message: 'Book deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = {
  getBooks,
  addBook,
  updateBook,
  deleteBook,
};