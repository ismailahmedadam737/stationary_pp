const Book = require('../models/bookModel');

const getBooks = async (req, res) => {
  try {
    const books = await Book.getBooks();
    res.json(books);
  } catch (err) {
    console.error("DEBUG GET BOOKS ERROR: ", err);
    res.status(500).json({ error: err.message });
  }
};

const addBook = async (req, res) => {
  try {
    const { title, author, price, type } = req.body;
    if (!title || !price) {
      return res.status(400).json({ message: 'Title and price are required' });
    }
    const newBook = await Book.createBook(title, author, price, type);
    res.status(201).json(newBook);
  } catch (err) {
    console.error("DEBUG ADD BOOK ERROR: ", err);
    res.status(500).json({ error: err.message });
  }
};

const updateBook = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, author, price, type } = req.body;
    if (!title || !price) {
      return res.status(400).json({ message: 'Title and price are required' });
    }
    const updatedBook = await Book.updateBook(id, title, author, price, type);
    if (!updatedBook) return res.status(404).json({ message: 'Book not found' });
    res.json(updatedBook);
  } catch (err) {
    console.error("DEBUG UPDATE BOOK ERROR: ", err);
    res.status(500).json({ error: err.message });
  }
};

const deleteBook = async (req, res) => {
  try {
    const { id } = req.params;
    await Book.deleteBook(id);
    res.json({ message: 'Book deleted successfully' });
  } catch (err) {
    console.error("DEBUG DELETE BOOK ERROR: ", err);
    res.status(500).json({ error: err.message });
  }
};

module.exports = { getBooks, addBook, updateBook, deleteBook };