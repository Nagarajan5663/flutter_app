const express = require('express');
const db = require('../config/db');

const router = express.Router();

// GET ALL PARTS
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT
        id,
        name,
        sku,
        purchase_price,
        description,
        created_at,
        updated_at
      FROM parts
      ORDER BY id DESC
    `);

    res.status(200).json({
      success: true,
      data: rows,
    });
  } catch (error) {
    console.error('Get parts error:', error);

    res.status(500).json({
      success: false,
      message: 'Failed to fetch parts',
    });
  }
});

// CREATE PART
router.post('/', async (req, res) => {
  try {
    const {
      name,
      sku,
      purchase_price,
      description,
    } = req.body;

    if (!name || !sku || purchase_price === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Name, SKU and purchase price are required',
      });
    }

    const purchasePrice = Number(purchase_price);

    if (!Number.isFinite(purchasePrice) || purchasePrice < 0) {
      return res.status(400).json({
        success: false,
        message: 'Invalid purchase price',
      });
    }

    const [result] = await db.query(
      `
      INSERT INTO parts
      (
        name,
        sku,
        purchase_price,
        description
      )
      VALUES (?, ?, ?, ?)
      `,
      [
        name.trim(),
        sku.trim(),
        purchasePrice,
        description || null,
      ]
    );

    const [rows] = await db.query(
      'SELECT * FROM parts WHERE id = ?',
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      message: 'Part created successfully',
      data: rows[0],
    });
  } catch (error) {
    console.error('Create part error:', error);

    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({
        success: false,
        message: 'SKU already exists',
      });
    }

    res.status(500).json({
      success: false,
      message: 'Failed to create part',
    });
  }
});

// UPDATE PART
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const {
      name,
      sku,
      purchase_price,
      description,
    } = req.body;

    const [result] = await db.query(
      `
      UPDATE parts
      SET
        name = ?,
        sku = ?,
        purchase_price = ?,
        description = ?
      WHERE id = ?
      `,
      [
        name,
        sku,
        purchase_price,
        description || null,
        id,
      ]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Part not found',
      });
    }

    const [rows] = await db.query(
      'SELECT * FROM parts WHERE id = ?',
      [id]
    );

    res.status(200).json({
      success: true,
      message: 'Part updated successfully',
      data: rows[0],
    });
  } catch (error) {
    console.error('Update part error:', error);

    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({
        success: false,
        message: 'SKU already exists',
      });
    }

    res.status(500).json({
      success: false,
      message: 'Failed to update part',
    });
  }
});

// DELETE PART
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const [result] = await db.query(
      'DELETE FROM parts WHERE id = ?',
      [id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Part not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Part deleted successfully',
    });
  } catch (error) {
    console.error('Delete part error:', error);

    res.status(500).json({
      success: false,
      message: 'Failed to delete part',
    });
  }
});

module.exports = router;