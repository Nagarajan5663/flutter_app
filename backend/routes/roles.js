const express = require('express');
const db = require('../config/db');

const router = express.Router();

function mapRole(row) {
  let permissions = [];

  try {
    permissions = JSON.parse(row.permissions);
  } catch (_) {
    permissions = [];
  }

  return {
    id: row.id,
    name: row.name,
    description: row.description,
    permissions: Array.isArray(permissions) ? permissions : [],
  };
}

function validateRole(body) {
  const name = typeof body.name === 'string' ? body.name.trim() : '';
  const description = typeof body.description === 'string'
    ? body.description.trim()
    : '';
  const permissions = body.permissions;

  if (!name || name.length > 100 || !Array.isArray(permissions)) {
    return null;
  }

  if (!permissions.every((permission) => typeof permission === 'string')) {
    return null;
  }

  return { name, description, permissions };
}

router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT id, name, description, permissions FROM roles ORDER BY id DESC'
    );

    res.status(200).json({
      success: true,
      data: rows.map(mapRole),
    });
  } catch (error) {
    console.error('Get roles error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch roles' });
  }
});

router.post('/', async (req, res) => {
  const role = validateRole(req.body);

  if (!role) {
    return res.status(400).json({
      success: false,
      message: 'A role name and a permissions list are required',
    });
  }

  try {
    const [result] = await db.query(
      'INSERT INTO roles (name, description, permissions) VALUES (?, ?, ?)',
      [role.name, role.description, JSON.stringify(role.permissions)]
    );
    const [rows] = await db.query('SELECT * FROM roles WHERE id = ?', [result.insertId]);

    res.status(201).json({
      success: true,
      message: 'Role created successfully',
      data: mapRole(rows[0]),
    });
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ success: false, message: 'Role name already exists' });
    }

    console.error('Create role error:', error);
    res.status(500).json({ success: false, message: 'Failed to create role' });
  }
});

router.put('/:id', async (req, res) => {
  const id = Number(req.params.id);
  const role = validateRole(req.body);

  if (!Number.isSafeInteger(id) || id < 1 || !role) {
    return res.status(400).json({
      success: false,
      message: 'A valid role ID, name, and permissions list are required',
    });
  }

  try {
    const [result] = await db.query(
      'UPDATE roles SET name = ?, description = ?, permissions = ? WHERE id = ?',
      [role.name, role.description, JSON.stringify(role.permissions), id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Role not found' });
    }

    const [rows] = await db.query('SELECT * FROM roles WHERE id = ?', [id]);
    res.status(200).json({ success: true, data: mapRole(rows[0]) });
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ success: false, message: 'Role name already exists' });
    }

    console.error('Update role error:', error);
    res.status(500).json({ success: false, message: 'Failed to update role' });
  }
});

router.delete('/:id', async (req, res) => {
  const id = Number(req.params.id);

  if (!Number.isSafeInteger(id) || id < 1) {
    return res.status(400).json({ success: false, message: 'A valid role ID is required' });
  }

  try {
    const [result] = await db.query('DELETE FROM roles WHERE id = ?', [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Role not found' });
    }

    res.status(200).json({ success: true, message: 'Role deleted successfully' });
  } catch (error) {
    console.error('Delete role error:', error);
    res.status(500).json({ success: false, message: 'Failed to delete role' });
  }
});

module.exports = router;