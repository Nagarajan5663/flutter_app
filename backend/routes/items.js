const express = require('express');
const db = require('../config/db');

const router = express.Router();

// GET ALL ITEMS
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT
        id,
        name,
        sku,
        purchase_price,
        sales_price,
        tax,
        description,
        created_at,
        updated_at
      FROM items
      ORDER BY id DESC
    `);

    res.status(200).json({
      success: true,
      data: rows,
    });
  } catch (error) {
    console.error('Get items error:', error);

    res.status(500).json({
      success: false,
      message: 'Failed to fetch items',
    });
  }
});

// CREATE ITEM
router.post('/', async (req, res) => {
  try {
    const {
      name,
      sku,
      purchase_price,
      sales_price,
      tax,
      description,
    } = req.body;

    if (!name || !sku || purchase_price === undefined || sales_price === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Name, SKU, purchase price and sales price are required',
      });
    }

    const purchasePrice = Number(purchase_price);
    const salesPrice = Number(sales_price);

    if (
      !Number.isFinite(purchasePrice) ||
      !Number.isFinite(salesPrice) ||
      purchasePrice < 0 ||
      salesPrice < 0
    ) {
      return res.status(400).json({
        success: false,
        message: 'Invalid price value',
      });
    }

    const [result] = await db.query(
      `
      INSERT INTO items
      (
        name,
        sku,
        purchase_price,
        sales_price,
        tax,
        description
      )
      VALUES (?, ?, ?, ?, ?, ?)
      `,
      [
        name.trim(),
        sku.trim(),
        purchasePrice,
        salesPrice,
        tax || null,
        description || null,
      ]
    );

    const [rows] = await db.query(
      'SELECT * FROM items WHERE id = ?',
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      message: 'Item created successfully',
      data: rows[0],
    });
  } catch (error) {
    console.error('Create item error:', error);

    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({
        success: false,
        message: 'SKU already exists',
      });
    }

    res.status(500).json({
      success: false,
      message: 'Failed to create item',
    });
  }
});

// UPDATE ITEM
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const {
      name,
      sku,
      purchase_price,
      sales_price,
      tax,
      description,
    } = req.body;

    const [result] = await db.query(
      `
      UPDATE items
      SET
        name = ?,
        sku = ?,
        purchase_price = ?,
        sales_price = ?,
        tax = ?,
        description = ?
      WHERE id = ?
      `,
      [
        name,
        sku,
        purchase_price,
        sales_price,
        tax || null,
        description || null,
        id,
      ]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Item not found',
      });
    }

    const [rows] = await db.query(
      'SELECT * FROM items WHERE id = ?',
      [id]
    );

    res.status(200).json({
      success: true,
      message: 'Item updated successfully',
      data: rows[0],
    });
  } catch (error) {
    console.error('Update item error:', error);

    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({
        success: false,
        message: 'SKU already exists',
      });
    }

    res.status(500).json({
      success: false,
      message: 'Failed to update item',
    });
  }
});

// DELETE ITEM
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const [result] = await db.query(
      'DELETE FROM items WHERE id = ?',
      [id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Item not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Item deleted successfully',
    });
  } catch (error) {
    console.error('Delete item error:', error);

    res.status(500).json({
      success: false,
      message: 'Failed to delete item',
    });
  }
});

module.exports = router;