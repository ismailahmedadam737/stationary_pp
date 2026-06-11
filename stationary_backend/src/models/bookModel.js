const pool = require('../config/db');

// Get all books and items
const getBooks = async () => {
  const result = await pool.query('SELECT * FROM books ORDER BY id DESC');
  return result.rows;
};

// Create a new book or item
const createBook = async (title, author, price, type) => {
  const result = await pool.query(
    'INSERT INTO books (title, author, price, type) VALUES ($1, $2, $3, $4) RETURNING *',
    [title, author, price, type || 'book'] // Haddii type la waayo wuxuu noqonayaa 'book'
  );
  return result.rows[0];
};

// Update a book or item
const updateBook = async (id, title, author, price, type) => {
  const result = await pool.query(
    'UPDATE books SET title=$1, author=$2, price=$3, type=$4 WHERE id=$5 RETURNING *',
    [title, author, price, type, id]
  );
  return result.rows[0];
};

// Delete a book or item
const deleteBook = async (id) => {
  await pool.query('DELETE FROM books WHERE id=$1', [id]);
};

module.exports = {
  getBooks,
  createBook,
  updateBook,
  deleteBook,
};