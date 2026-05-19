const pool = require('../config/db');

// Get all books
const getBooks = async () => {
  const result = await pool.query('SELECT * FROM books ORDER BY id DESC');
  return result.rows;
};

// Create a new book
const createBook = async (title, author, price) => {
  const result = await pool.query(
    'INSERT INTO books (title, author, price) VALUES ($1, $2, $3) RETURNING *',
    [title, author, price]
  );
  return result.rows[0];
};

// Update a book
const updateBook = async (id, title, author, price) => {
  const result = await pool.query(
    'UPDATE books SET title=$1, author=$2, price=$3 WHERE id=$4 RETURNING *',
    [title, author, price, id]
  );
  return result.rows[0];
};

// Delete a book
const deleteBook = async (id) => {
  await pool.query('DELETE FROM books WHERE id=$1', [id]);
};

module.exports = {
  getBooks,
  createBook,
  updateBook,
  deleteBook,
};