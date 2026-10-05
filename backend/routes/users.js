const express = require('express');
const bcrypt = require('bcryptjs');
const db = require('../config/db');

const router = express.Router();

/*
|--------------------------------------------------------------------------
| Helper: Get role by name
|--------------------------------------------------------------------------
*/
async function getRoleByName(roleName) {
  const [rows] = await db.query(
    `
    SELECT id, name
    FROM roles
    WHERE LOWER(name) = LOWER(?)
    LIMIT 1
    `,
    [roleName]
  );

  return rows.length ? rows[0] : null;
}

/*
|--------------------------------------------------------------------------
| GET /api/users/setup-status
|
| Checks whether the first Primary Super Admin still needs to be created.
|--------------------------------------------------------------------------
*/
router.get('/setup-status', async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT COUNT(*) AS total
      FROM users
    `);

    const totalUsers = Number(rows[0]?.total || 0);

    return res.json({
      success: true,
      data: {
        setupRequired: totalUsers === 0,
        totalUsers,
      },
    });
  } catch (error) {
    console.error('Setup status error:', error);

    return res.status(500).json({
      success: false,
      message: 'Failed to check setup status',
      error: error.message,
    });
  }
});

/*
|--------------------------------------------------------------------------
| POST /api/users/login
|
| Authenticate a user and return their role permissions.
|--------------------------------------------------------------------------
*/
router.post('/login', async (req, res) => {
  const email = typeof req.body.email === 'string'
    ? req.body.email.trim().toLowerCase()
    : '';
  const password = typeof req.body.password === 'string'
    ? req.body.password
    : '';

  if (!email || !password) {
    return res.status(400).json({
      success: false,
      message: 'Email and password are required.',
    });
  }

  try {
    const [rows] = await db.query(
      `
      SELECT
        u.id,
        u.email,
        u.password_hash AS passwordHash,
        u.role_id AS roleId,
        u.is_active AS active,
        u.is_primary_super_admin AS isPrimarySuperAdmin,
        r.name AS role,
        r.permissions
      FROM users u
      LEFT JOIN roles r
        ON r.id = u.role_id
      WHERE LOWER(u.email) = ?
      LIMIT 1
      `,
      [email]
    );

    if (!rows.length || !(await bcrypt.compare(password, rows[0].passwordHash))) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password.',
      });
    }

    const user = rows[0];

    if (!user.active) {
      return res.status(403).json({
        success: false,
        message: 'This account is inactive.',
      });
    }

    await db.query(
      'UPDATE users SET last_login_at = NOW() WHERE id = ?',
      [user.id]
    );

    let permissions = [];
    try {
      const rolePermissions = typeof user.permissions === 'string'
        ? JSON.parse(user.permissions)
        : user.permissions;
      if (Array.isArray(rolePermissions)) {
        permissions = rolePermissions.filter(
          (permission) => typeof permission === 'string'
        );
      }
    } catch (_) {
      permissions = [];
    }

    return res.status(200).json({
      success: true,
      message: 'Login successful.',
      data: {
        id: user.id,
        email: user.email,
        roleId: user.roleId,
        role: user.role,
        active: true,
        isPrimarySuperAdmin: Boolean(user.isPrimarySuperAdmin),
        permissions,
      },
    });
  } catch (error) {
    console.error('User login error:', error);
    return res.status(500).json({
      success: false,
      message: 'Unable to sign in right now.',
    });
  }
});

/*
|--------------------------------------------------------------------------
| POST /api/users/setup
|
| Creates the FIRST user.
|
| This user automatically becomes:
| - Super Admin
| - Primary Super Admin
| - Active
| - Cannot be deactivated
|
| This endpoint works ONLY when there are zero users.
|--------------------------------------------------------------------------
*/
router.post('/setup', async (req, res) => {
  const { email, password } = req.body;

  try {
    /*
    |--------------------------------------------------------------------------
    | Validate input
    |--------------------------------------------------------------------------
    */
    if (!email || !email.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Email is required.',
      });
    }

    if (!password || password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters.',
      });
    }

    const cleanEmail = email.trim().toLowerCase();

    /*
    |--------------------------------------------------------------------------
    | Check whether setup is already completed
    |--------------------------------------------------------------------------
    */
    const [userCountRows] = await db.query(`
      SELECT COUNT(*) AS total
      FROM users
    `);

    const totalUsers = Number(userCountRows[0]?.total || 0);

    if (totalUsers > 0) {
      return res.status(409).json({
        success: false,
        message: 'Initial setup has already been completed.',
      });
    }

    /*
    |--------------------------------------------------------------------------
    | Get Super Admin role
    |--------------------------------------------------------------------------
    */
    const superAdminRole = await getRoleByName('Super Admin');

    if (!superAdminRole) {
      return res.status(500).json({
        success: false,
        message: 'Super Admin role was not found in the roles table.',
      });
    }

    /*
    |--------------------------------------------------------------------------
    | Hash password
    |--------------------------------------------------------------------------
    */
    const passwordHash = await bcrypt.hash(password, 10);

    /*
    |--------------------------------------------------------------------------
    | Create Primary Super Admin
    |--------------------------------------------------------------------------
    */
    const [result] = await db.query(
      `
      INSERT INTO users (
        email,
        password_hash,
        role_id,
        is_active,
        can_deactivate,
        is_primary_super_admin,
        last_login_at,
        created_at,
        updated_at
      )
      VALUES (?, ?, ?, 1, 0, 1, NULL, NOW(), NOW())
      `,
      [
        cleanEmail,
        passwordHash,
        superAdminRole.id,
      ]
    );

    /*
    |--------------------------------------------------------------------------
    | Return created user
    |--------------------------------------------------------------------------
    */
    return res.status(201).json({
      success: true,
      message: 'Primary Super Admin created successfully.',
      data: {
        id: result.insertId,
        email: cleanEmail,
        roleId: superAdminRole.id,
        role: superAdminRole.name,
        active: true,
        canDeactivate: false,
        isPrimarySuperAdmin: true,
      },
    });
  } catch (error) {
    console.error('Initial setup error:', error);

    return res.status(500).json({
      success: false,
      message: 'Failed to create Primary Super Admin.',
      error: error.message,
    });
  }
});

/*
|--------------------------------------------------------------------------
| GET /api/users
|
| Get all users.
|--------------------------------------------------------------------------
*/
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT
        u.id,
        u.email,
        u.role_id AS roleId,
        r.name AS role,
        u.is_active AS active,
        u.can_deactivate AS canDeactivate,
        u.is_primary_super_admin AS isPrimarySuperAdmin,
        u.last_login_at AS lastLoginAt,
        u.created_at AS createdAt,
        u.updated_at AS updatedAt
      FROM users u
      LEFT JOIN roles r
        ON r.id = u.role_id
      ORDER BY u.id ASC
    `);

    return res.json({
      success: true,
      data: rows,
    });
  } catch (error) {
    console.error('Get users error:', error);

    return res.status(500).json({
      success: false,
      message: 'Failed to load users',
      error: error.message,
    });
  }
});

/*
|--------------------------------------------------------------------------
| GET /api/users/:id
|
| Get one user.
|--------------------------------------------------------------------------
*/
router.get('/:id', async (req, res) => {
  try {
    const userId = Number(req.params.id);

    if (!Number.isInteger(userId) || userId <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Invalid user ID.',
      });
    }

    const [rows] = await db.query(
      `
      SELECT
        u.id,
        u.email,
        u.role_id AS roleId,
        r.name AS role,
        u.is_active AS active,
        u.can_deactivate AS canDeactivate,
        u.is_primary_super_admin AS isPrimarySuperAdmin,
        u.last_login_at AS lastLoginAt,
        u.created_at AS createdAt,
        u.updated_at AS updatedAt
      FROM users u
      LEFT JOIN roles r
        ON r.id = u.role_id
      WHERE u.id = ?
      LIMIT 1
      `,
      [userId]
    );

    if (!rows.length) {
      return res.status(404).json({
        success: false,
        message: 'User not found.',
      });
    }

    return res.json({
      success: true,
      data: rows[0],
    });
  } catch (error) {
    console.error('Get user error:', error);

    return res.status(500).json({
      success: false,
      message: 'Failed to load user',
      error: error.message,
    });
  }
});

/*
|--------------------------------------------------------------------------
| POST /api/users
|
| Add a normal user from Manage Users.
|
| This endpoint NEVER creates another Primary Super Admin.
|--------------------------------------------------------------------------
*/
router.post('/', async (req, res) => {
  const {
    email,
    password,
    role,
    roleId,
    canDeactivate,
  } = req.body;

  try {
    /*
    |--------------------------------------------------------------------------
    | Validate email
    |--------------------------------------------------------------------------
    */
    if (!email || !email.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Email is required.',
      });
    }

    /*
    |--------------------------------------------------------------------------
    | Validate password
    |--------------------------------------------------------------------------
    */
    if (!password || password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters.',
      });
    }

    const cleanEmail = email.trim().toLowerCase();

    /*
    |--------------------------------------------------------------------------
    | Make sure at least one user already exists.
    |
    | The first user MUST be created through /setup.
    |--------------------------------------------------------------------------
    */
    const [userCountRows] = await db.query(`
      SELECT COUNT(*) AS total
      FROM users
    `);

    const totalUsers = Number(userCountRows[0]?.total || 0);

    if (totalUsers === 0) {
      return res.status(409).json({
        success: false,
        message:
          'No users exist yet. Create the Primary Super Admin through the initial setup.',
      });
    }

    /*
    |--------------------------------------------------------------------------
    | Check duplicate email
    |--------------------------------------------------------------------------
    */
    const [existingRows] = await db.query(
      `
      SELECT id
      FROM users
      WHERE LOWER(email) = LOWER(?)
      LIMIT 1
      `,
      [cleanEmail]
    );

    if (existingRows.length) {
      return res.status(409).json({
        success: false,
        message: 'A user with this email already exists.',
      });
    }

    /*
    |--------------------------------------------------------------------------
    | Find role
    |--------------------------------------------------------------------------
    */
    let selectedRole = null;

    if (roleId !== undefined && roleId !== null && roleId !== '') {
      const numericRoleId = Number(roleId);

      if (!Number.isInteger(numericRoleId) || numericRoleId <= 0) {
        return res.status(400).json({
          success: false,
          message: 'Invalid role ID.',
        });
      }

      const [roleRows] = await db.query(
        `
        SELECT id, name
        FROM roles
        WHERE id = ?
        LIMIT 1
        `,
        [numericRoleId]
      );

      if (roleRows.length) {
        selectedRole = roleRows[0];
      }
    } else if (role && String(role).trim()) {
      selectedRole = await getRoleByName(String(role).trim());
    }

    if (!selectedRole) {
      return res.status(400).json({
        success: false,
        message: 'Valid role is required.',
      });
    }

    /*
    |--------------------------------------------------------------------------
    | Hash password
    |--------------------------------------------------------------------------
    */
    const passwordHash = await bcrypt.hash(password, 10);

    /*
    |--------------------------------------------------------------------------
    | can_deactivate
    |--------------------------------------------------------------------------
    */
    const deactivateValue =
      canDeactivate === true ||
      canDeactivate === 1 ||
      canDeactivate === '1' ||
      canDeactivate === 'true'
        ? 1
        : 0;

    /*
    |--------------------------------------------------------------------------
    | Normal users are NEVER Primary Super Admins.
    |--------------------------------------------------------------------------
    */
    const [result] = await db.query(
      `
      INSERT INTO users (
        email,
        password_hash,
        role_id,
        is_active,
        can_deactivate,
        is_primary_super_admin,
        last_login_at,
        created_at,
        updated_at
      )
      VALUES (?, ?, ?, 1, ?, 0, NULL, NOW(), NOW())
      `,
      [
        cleanEmail,
        passwordHash,
        selectedRole.id,
        deactivateValue,
      ]
    );

    return res.status(201).json({
      success: true,
      message: 'User created successfully.',
      data: {
        id: result.insertId,
        email: cleanEmail,
        roleId: selectedRole.id,
        role: selectedRole.name,
        active: true,
        canDeactivate: Boolean(deactivateValue),
        isPrimarySuperAdmin: false,
      },
    });
  } catch (error) {
    console.error('Create user error:', error);

    return res.status(500).json({
      success: false,
      message: 'Failed to create user',
      error: error.message,
    });
  }
});

/*
|--------------------------------------------------------------------------
| PUT /api/users/:id
|
| Edit user details.
|--------------------------------------------------------------------------
*/
router.put('/:id', async (req, res) => {
  const userId = Number(req.params.id);

  const {
    email,
    password,
    role,
    roleId,
    canDeactivate,
  } = req.body;

  try {
    if (!Number.isInteger(userId) || userId <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Invalid user ID.',
      });
    }

    /*
    |--------------------------------------------------------------------------
    | Get existing user
    |--------------------------------------------------------------------------
    */
    const [userRows] = await db.query(
      `
      SELECT
        id,
        email,
        role_id,
        is_active,
        can_deactivate,
        is_primary_super_admin
      FROM users
      WHERE id = ?
      LIMIT 1
      `,
      [userId]
    );

    if (!userRows.length) {
      return res.status(404).json({
        success: false,
        message: 'User not found.',
      });
    }

    const existingUser = userRows[0];

    /*
    |--------------------------------------------------------------------------
    | Email
    |--------------------------------------------------------------------------
    */
    let newEmail = existingUser.email;

    if (email !== undefined) {
      if (!String(email).trim()) {
        return res.status(400).json({
          success: false,
          message: 'Email cannot be empty.',
        });
      }

      newEmail = String(email).trim().toLowerCase();

      /*
      |--------------------------------------------------------------------------
      | Check duplicate email
      |--------------------------------------------------------------------------
      */
      const [duplicateRows] = await db.query(
        `
        SELECT id
        FROM users
        WHERE LOWER(email) = LOWER(?)
          AND id <> ?
        LIMIT 1
        `,
        [newEmail, userId]
      );

      if (duplicateRows.length) {
        return res.status(409).json({
          success: false,
          message: 'A user with this email already exists.',
        });
      }
    }

    /*
    |--------------------------------------------------------------------------
    | Role
    |--------------------------------------------------------------------------
    */
    let selectedRoleId = existingUser.role_id;

    if (roleId !== undefined && roleId !== null && roleId !== '') {
      const numericRoleId = Number(roleId);

      if (!Number.isInteger(numericRoleId) || numericRoleId <= 0) {
        return res.status(400).json({
          success: false,
          message: 'Invalid role ID.',
        });
      }

      const [roleRows] = await db.query(
        `
        SELECT id
        FROM roles
        WHERE id = ?
        LIMIT 1
        `,
        [numericRoleId]
      );

      if (!roleRows.length) {
        return res.status(400).json({
          success: false,
          message: 'Selected role does not exist.',
        });
      }

      selectedRoleId = numericRoleId;
    } else if (role !== undefined && String(role).trim()) {
      const selectedRole = await getRoleByName(String(role).trim());

      if (!selectedRole) {
        return res.status(400).json({
          success: false,
          message: 'Selected role does not exist.',
        });
      }

      selectedRoleId = selectedRole.id;
    }

    /*
    |--------------------------------------------------------------------------
    | can_deactivate
    |
    | Primary Super Admin MUST always remain 0.
    |--------------------------------------------------------------------------
    */
    let newCanDeactivate = existingUser.can_deactivate;

    if (Boolean(existingUser.is_primary_super_admin)) {
      newCanDeactivate = 0;
    } else if (canDeactivate !== undefined) {
      newCanDeactivate =
        canDeactivate === true ||
        canDeactivate === 1 ||
        canDeactivate === '1' ||
        canDeactivate === 'true'
          ? 1
          : 0;
    }

    /*
    |--------------------------------------------------------------------------
    | Build update
    |--------------------------------------------------------------------------
    */
    let passwordHash = null;

    if (password !== undefined && password !== '') {
      if (password.length < 6) {
        return res.status(400).json({
          success: false,
          message: 'Password must be at least 6 characters.',
        });
      }

      passwordHash = await bcrypt.hash(password, 10);
    }

    if (passwordHash) {
      await db.query(
        `
        UPDATE users
        SET
          email = ?,
          password_hash = ?,
          role_id = ?,
          can_deactivate = ?,
          updated_at = NOW()
        WHERE id = ?
        `,
        [
          newEmail,
          passwordHash,
          selectedRoleId,
          newCanDeactivate,
          userId,
        ]
      );
    } else {
      await db.query(
        `
        UPDATE users
        SET
          email = ?,
          role_id = ?,
          can_deactivate = ?,
          updated_at = NOW()
        WHERE id = ?
        `,
        [
          newEmail,
          selectedRoleId,
          newCanDeactivate,
          userId,
        ]
      );
    }

    /*
    |--------------------------------------------------------------------------
    | Return updated user
    |--------------------------------------------------------------------------
    */
    const [updatedRows] = await db.query(
      `
      SELECT
        u.id,
        u.email,
        u.role_id AS roleId,
        r.name AS role,
        u.is_active AS active,
        u.can_deactivate AS canDeactivate,
        u.is_primary_super_admin AS isPrimarySuperAdmin,
        u.last_login_at AS lastLoginAt,
        u.created_at AS createdAt,
        u.updated_at AS updatedAt
      FROM users u
      LEFT JOIN roles r
        ON r.id = u.role_id
      WHERE u.id = ?
      LIMIT 1
      `,
      [userId]
    );

    return res.json({
      success: true,
      message: 'User updated successfully.',
      data: updatedRows[0],
    });
  } catch (error) {
    console.error('Update user error:', error);

    return res.status(500).json({
      success: false,
      message: 'Failed to update user',
      error: error.message,
    });
  }
});

/*
|--------------------------------------------------------------------------
| PUT /api/users/:id/status
|
| Activate / deactivate user.
|--------------------------------------------------------------------------
*/
router.put('/:id/status', async (req, res) => {
  const userId = Number(req.params.id);
  const { active } = req.body;

  try {
    if (!Number.isInteger(userId) || userId <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Invalid user ID.',
      });
    }

    /*
    |--------------------------------------------------------------------------
    | Convert active value
    |--------------------------------------------------------------------------
    */
    const newStatus =
      active === true ||
      active === 1 ||
      active === '1' ||
      active === 'true';

    /*
    |--------------------------------------------------------------------------
    | Get user
    |--------------------------------------------------------------------------
    */
    const [userRows] = await db.query(
      `
      SELECT
        id,
        email,
        is_active,
        can_deactivate,
        is_primary_super_admin
      FROM users
      WHERE id = ?
      LIMIT 1
      `,
      [userId]
    );

    if (!userRows.length) {
      return res.status(404).json({
        success: false,
        message: 'User not found.',
      });
    }

    const user = userRows[0];

    /*
    |--------------------------------------------------------------------------
    | Primary Super Admin protection
    |--------------------------------------------------------------------------
    */
    if (!newStatus && Boolean(user.is_primary_super_admin)) {
      return res.status(400).json({
        success: false,
        message: 'The Primary Super Admin cannot be deactivated.',
      });
    }

    /*
    |--------------------------------------------------------------------------
    | Check can_deactivate
    |--------------------------------------------------------------------------
    */
    if (!newStatus && !Boolean(user.can_deactivate)) {
      return res.status(400).json({
        success: false,
        message: 'This user is not allowed to be deactivated.',
      });
    }

    /*
    |--------------------------------------------------------------------------
    | Update status
    |--------------------------------------------------------------------------
    */
    await db.query(
      `
      UPDATE users
      SET
        is_active = ?,
        updated_at = NOW()
      WHERE id = ?
      `,
      [newStatus ? 1 : 0, userId]
    );

    return res.json({
      success: true,
      message: newStatus
        ? 'User activated successfully.'
        : 'User deactivated successfully.',
      data: {
        id: userId,
        active: newStatus,
      },
    });
  } catch (error) {
    console.error('Update user status error:', error);

    return res.status(500).json({
      success: false,
      message: 'Failed to update user status',
      error: error.message,
    });
  }
});

/*
|--------------------------------------------------------------------------
| DELETE /api/users/:id
|--------------------------------------------------------------------------
*/
router.delete('/:id', async (req, res) => {
  const userId = Number(req.params.id);

  try {
    if (!Number.isInteger(userId) || userId <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Invalid user ID.',
      });
    }

    /*
    |--------------------------------------------------------------------------
    | Get user
    |--------------------------------------------------------------------------
    */
    const [userRows] = await db.query(
      `
      SELECT
        id,
        email,
        is_primary_super_admin
      FROM users
      WHERE id = ?
      LIMIT 1
      `,
      [userId]
    );

    if (!userRows.length) {
      return res.status(404).json({
        success: false,
        message: 'User not found.',
      });
    }

    const user = userRows[0];

    /*
    |--------------------------------------------------------------------------
    | Primary Super Admin protection
    |--------------------------------------------------------------------------
    */
    if (Boolean(user.is_primary_super_admin)) {
      return res.status(400).json({
        success: false,
        message: 'The Primary Super Admin cannot be deleted.',
      });
    }

    /*
    |--------------------------------------------------------------------------
    | Delete normal user
    |--------------------------------------------------------------------------
    */
    await db.query(
      `
      DELETE FROM users
      WHERE id = ?
      `,
      [userId]
    );

    return res.json({
      success: true,
      message: 'User deleted successfully.',
    });
  } catch (error) {
    console.error('Delete user error:', error);

    return res.status(500).json({
      success: false,
      message: 'Failed to delete user',
      error: error.message,
    });
  }
});

module.exports = router;