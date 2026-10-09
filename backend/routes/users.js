const express = require('express');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');

const db = require('../config/db');
const { sendEmail } = require('../utils/email');
const { issueWorkflowToken } = require('../middleware/workflow_auth');

const router = express.Router();

/*
|--------------------------------------------------------------------------
| Helper: Get role by name
|--------------------------------------------------------------------------
*/

async function getRoleByName(roleName) {
  const [rows] = await db.query(
    `
    SELECT
      id,
      name
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
| Helper: Parse permissions
|--------------------------------------------------------------------------
*/

function parsePermissions(permissionValue) {
  if (!permissionValue) {
    return [];
  }

  try {
    const parsed =
      typeof permissionValue === 'string'
        ? JSON.parse(permissionValue)
        : permissionValue;

    return Array.isArray(parsed)
      ? parsed.filter(
          (item) => typeof item === 'string'
        )
      : [];
  } catch (error) {
    return [];
  }
}

/*
|--------------------------------------------------------------------------
| Helper: Generate 6 digit OTP
|--------------------------------------------------------------------------
*/

function generateOtp() {
  return crypto
    .randomInt(100000, 1000000)
    .toString();
}

/*
|--------------------------------------------------------------------------
| Helper: Hash OTP
|--------------------------------------------------------------------------
*/

function hashOtp(otp) {
  return crypto
    .createHash('sha256')
    .update(String(otp))
    .digest('hex');
}

/*
|--------------------------------------------------------------------------
| Helper: Compare hashes safely
|--------------------------------------------------------------------------
*/

function hashesMatch(hashA, hashB) {
  if (
    typeof hashA !== 'string' ||
    typeof hashB !== 'string'
  ) {
    return false;
  }

  if (hashA.length !== hashB.length) {
    return false;
  }

  try {
    return crypto.timingSafeEqual(
      Buffer.from(hashA, 'utf8'),
      Buffer.from(hashB, 'utf8')
    );
  } catch (error) {
    return false;
  }
}

/*
|--------------------------------------------------------------------------
| Helper: Send password reset OTP email
|--------------------------------------------------------------------------
*/

async function sendPasswordResetOtp(email, otp) {
  const html = `
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="UTF-8" />
        <title>CODExIA Password Reset</title>
      </head>

      <body
        style="
          margin:0;
          padding:0;
          background:#f5f7fb;
          font-family:Arial,Helvetica,sans-serif;
        "
      >
        <div
          style="
            max-width:600px;
            margin:40px auto;
            background:#ffffff;
            border-radius:12px;
            padding:32px;
            box-sizing:border-box;
          "
        >
          <h2
            style="
              margin-top:0;
              color:#111827;
            "
          >
            CODExIA Password Reset
          </h2>

          <p
            style="
              color:#374151;
              font-size:15px;
              line-height:1.6;
            "
          >
            We received a request to reset your CODExIA account
            password.
          </p>

          <p
            style="
              color:#374151;
              font-size:15px;
              line-height:1.6;
            "
          >
            Use the following OTP to reset your password:
          </p>

          <div
            style="
              margin:24px 0;
              text-align:center;
            "
          >
            <span
              style="
                display:inline-block;
                padding:16px 28px;
                background:#f3f4f6;
                border-radius:10px;
                font-size:30px;
                font-weight:bold;
                letter-spacing:8px;
                color:#111827;
              "
            >
              ${otp}
            </span>
          </div>

          <p
            style="
              color:#374151;
              font-size:15px;
              line-height:1.6;
            "
          >
            This OTP will expire in
            <strong>10 minutes</strong>.
          </p>

          <p
            style="
              color:#6b7280;
              font-size:14px;
              line-height:1.6;
            "
          >
            If you did not request a password reset,
            you can safely ignore this email.
          </p>

          <hr
            style="
              border:none;
              border-top:1px solid #e5e7eb;
              margin:28px 0;
            "
          />

          <p
            style="
              color:#9ca3af;
              font-size:12px;
              margin-bottom:0;
            "
          >
            This is an automated email from CODExIA.
            Please do not reply to this email.
          </p>
        </div>
      </body>
    </html>
  `;

  const text = `
CODExIA Password Reset

Your password reset OTP is:

${otp}

This OTP will expire in 10 minutes.

If you did not request a password reset, you can safely ignore this email.

This is an automated email from CODExIA.
  `.trim();

  await sendEmail(
    email,
    'CODExIA Password Reset OTP',
    html
  );

  return text;
}

/*
|--------------------------------------------------------------------------
| POST /api/users/login
|--------------------------------------------------------------------------
*/

router.post('/login', async (req, res) => {
  const email =
    typeof req.body.email === 'string'
      ? req.body.email.trim().toLowerCase()
      : '';

  const password =
    typeof req.body.password === 'string'
      ? req.body.password
      : '';

  try {
    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email is required.',
      });
    }

    if (!password) {
      return res.status(400).json({
        success: false,
        message: 'Password is required.',
      });
    }

    const [rows] = await db.query(
      `
      SELECT
        u.id,
        u.email,
        u.password_hash AS passwordHash,
        u.role_id AS roleId,
        r.name AS role,
        r.permissions AS rolePermissions,
        u.is_active AS active,
        u.can_deactivate AS canDeactivate,
        u.is_primary_super_admin AS isPrimarySuperAdmin,
        u.last_login_at AS lastLoginAt,
        u.created_at AS createdAt,
        u.updated_at AS updatedAt
      FROM users u
      LEFT JOIN roles r
        ON r.id = u.role_id
      WHERE LOWER(u.email) = LOWER(?)
      LIMIT 1
      `,
      [email]
    );

    if (!rows.length) {
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

    const passwordMatches =
      await bcrypt.compare(
        password,
        user.passwordHash
      );

    if (!passwordMatches) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password.',
      });
    }

    const permissions =
      parsePermissions(
        user.rolePermissions
      );

    await db.query(
      `
      UPDATE users
      SET
        last_login_at = NOW(),
        updated_at = NOW()
      WHERE id = ?
      `,
      [user.id]
    );

    return res.status(200).json({
      success: true,
      message: 'Login successful.',
      data: {
        id: user.id,
        email: user.email,
        roleId: user.roleId,
        role: user.role,
        active: Boolean(user.active),
        canDeactivate:
          Boolean(user.canDeactivate),
        isPrimarySuperAdmin:
          Boolean(user.isPrimarySuperAdmin),
        lastLoginAt:
          new Date().toISOString(),
        permissions,
        workflowToken: issueWorkflowToken(user.id),
      },
    });
  } catch (error) {
    console.error(
      'Login error:',
      error
    );

    return res.status(500).json({
      success: false,
      message: 'Failed to log in.',
      error: error.message,
    });
  }
});

/*
|--------------------------------------------------------------------------
| GET /api/users/setup-status
|--------------------------------------------------------------------------
*/

router.get(
  '/setup-status',
  async (req, res) => {
    try {
      const [rows] = await db.query(`
        SELECT COUNT(*) AS total
        FROM users
      `);

      const totalUsers =
        Number(rows[0]?.total || 0);

      return res.json({
        success: true,
        data: {
          setupRequired:
            totalUsers === 0,
          totalUsers,
        },
      });
    } catch (error) {
      console.error(
        'Setup status error:',
        error
      );

      return res.status(500).json({
        success: false,
        message:
          'Failed to check setup status',
        error: error.message,
      });
    }
  }
);

/*
|--------------------------------------------------------------------------
| POST /api/users/setup
|--------------------------------------------------------------------------
| Creates the FIRST user.
|--------------------------------------------------------------------------
*/

router.post(
  '/setup',
  async (req, res) => {
    const {
      email,
      password,
    } = req.body;

    try {
      if (
        !email ||
        !String(email).trim()
      ) {
        return res.status(400).json({
          success: false,
          message: 'Email is required.',
        });
      }

      if (
        !password ||
        String(password).length < 6
      ) {
        return res.status(400).json({
          success: false,
          message:
            'Password must be at least 6 characters.',
        });
      }

      const cleanEmail =
        String(email)
          .trim()
          .toLowerCase();

      const [userCountRows] =
        await db.query(`
          SELECT COUNT(*) AS total
          FROM users
        `);

      const totalUsers =
        Number(
          userCountRows[0]?.total || 0
        );

      if (totalUsers > 0) {
        return res.status(409).json({
          success: false,
          message:
            'Initial setup has already been completed.',
        });
      }

      const superAdminRole =
        await getRoleByName(
          'Super Admin'
        );

      if (!superAdminRole) {
        return res.status(500).json({
          success: false,
          message:
            'Super Admin role was not found in the roles table.',
        });
      }

      const passwordHash =
        await bcrypt.hash(
          String(password),
          10
        );

      const [result] =
        await db.query(
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
          VALUES (
            ?,
            ?,
            ?,
            1,
            0,
            1,
            NULL,
            NOW(),
            NOW()
          )
          `,
          [
            cleanEmail,
            passwordHash,
            superAdminRole.id,
          ]
        );

      return res.status(201).json({
        success: true,
        message:
          'Primary Super Admin created successfully.',
        data: {
          id: result.insertId,
          email: cleanEmail,
          roleId:
            superAdminRole.id,
          role:
            superAdminRole.name,
          active: true,
          canDeactivate: false,
          isPrimarySuperAdmin: true,
        },
      });
    } catch (error) {
      console.error(
        'Initial setup error:',
        error
      );

      return res.status(500).json({
        success: false,
        message:
          'Failed to create Primary Super Admin.',
        error: error.message,
      });
    }
  }
);

/*
|--------------------------------------------------------------------------
| POST /api/users/forgot-password
|--------------------------------------------------------------------------
|
| User enters email.
| Backend generates a 6 digit OTP.
| OTP hash is stored in password_reset_tokens.
| OTP is sent to the user's email.
|--------------------------------------------------------------------------
*/

router.post(
  '/forgot-password',
  async (req, res) => {
    const email =
      typeof req.body.email === 'string'
        ? req.body.email.trim().toLowerCase()
        : '';

    try {
      if (!email) {
        return res.status(400).json({
          success: false,
          message:
            'Email address is required.',
        });
      }

      /*
      |--------------------------------------------------------------------------
      | Find user
      |--------------------------------------------------------------------------
      */

      const [userRows] =
        await db.query(
          `
          SELECT
            id,
            email,
            is_active
          FROM users
          WHERE LOWER(email) = LOWER(?)
          LIMIT 1
          `,
          [email]
        );

      /*
      |--------------------------------------------------------------------------
      | Do not reveal whether account exists.
      |--------------------------------------------------------------------------
      */

      if (
        !userRows.length ||
        !Boolean(
          userRows[0].is_active
        )
      ) {
        return res.status(200).json({
          success: true,
          message:
            'If an account exists for this email, a password reset code has been sent.',
        });
      }

      const user =
        userRows[0];

      /*
      |--------------------------------------------------------------------------
      | Delete previous unused OTPs
      |--------------------------------------------------------------------------
      */

      await db.query(
        `
        DELETE FROM password_reset_tokens
        WHERE user_id = ?
          AND used_at IS NULL
        `,
        [user.id]
      );

      /*
      |--------------------------------------------------------------------------
      | Generate OTP
      |--------------------------------------------------------------------------
      */

      const otp =
        generateOtp();

      const tokenHash =
        hashOtp(otp);

      /*
      |--------------------------------------------------------------------------
      | Save hashed OTP
      |--------------------------------------------------------------------------
      |
      | IMPORTANT:
      | MySQL calculates the expiry time using NOW().
      | This keeps the OTP expiration time in the database's
      | own time context.
      |--------------------------------------------------------------------------
      */

      await db.query(
        `
        INSERT INTO password_reset_tokens (
          user_id,
          token_hash,
          expires_at,
          used_at,
          created_at
        )
        VALUES (
          ?,
          ?,
          DATE_ADD(NOW(), INTERVAL 10 MINUTE),
          NULL,
          NOW()
        )
        `,
        [
          user.id,
          tokenHash,
        ]
      );

      /*
      |--------------------------------------------------------------------------
      | Send OTP
      |--------------------------------------------------------------------------
      */

      try {
        await sendPasswordResetOtp(
          user.email,
          otp
        );
      } catch (emailError) {
        /*
        |--------------------------------------------------------------------------
        | If email fails, remove the OTP that was just created.
        |--------------------------------------------------------------------------
        */

        await db.query(
          `
          DELETE FROM password_reset_tokens
          WHERE user_id = ?
            AND token_hash = ?
          `,
          [
            user.id,
            tokenHash,
          ]
        );

        throw emailError;
      }

      return res.status(200).json({
        success: true,
        message:
          'A password reset code has been sent to your email.',
      });
    } catch (error) {
      console.error(
        'Forgot password error:',
        error
      );

      return res.status(500).json({
        success: false,
        message:
          'Unable to send password reset code.',
        error: error.message,
      });
    }
  }
);

/*
|--------------------------------------------------------------------------
| POST /api/users/verify-reset-otp
|--------------------------------------------------------------------------
|
| Verify OTP without consuming it.
|
| IMPORTANT:
| Expiry is checked by MySQL using:
|
|     expires_at <= NOW()
|
| This avoids JavaScript/MySQL timezone conversion problems.
|--------------------------------------------------------------------------
*/

router.post(
  '/verify-reset-otp',
  async (req, res) => {
    const email =
      typeof req.body.email === 'string'
        ? req.body.email.trim().toLowerCase()
        : '';

    const otp =
      typeof req.body.otp === 'string'
        ? req.body.otp.trim()
        : String(
            req.body.otp || ''
          ).trim();

    try {
      if (!email || !otp) {
        return res.status(400).json({
          success: false,
          message:
            'Email and OTP are required.',
        });
      }

      if (!/^\d{6}$/.test(otp)) {
        return res.status(400).json({
          success: false,
          message:
            'OTP must be a 6-digit code.',
        });
      }

      const [rows] =
        await db.query(
          `
          SELECT
            prt.id,
            prt.user_id,
            prt.token_hash,
            prt.expires_at,
            prt.used_at,
            CASE
              WHEN prt.expires_at <= NOW() THEN 1
              ELSE 0
            END AS isExpired
          FROM password_reset_tokens prt
          INNER JOIN users u
            ON u.id = prt.user_id
          WHERE LOWER(u.email) = LOWER(?)
          ORDER BY prt.id DESC
          LIMIT 1
          `,
          [email]
        );

      if (!rows.length) {
        return res.status(400).json({
          success: false,
          message:
            'Invalid or expired OTP.',
        });
      }

      const resetToken =
        rows[0];

      /*
      |--------------------------------------------------------------------------
      | Check used
      |--------------------------------------------------------------------------
      */

      if (resetToken.used_at) {
        return res.status(400).json({
          success: false,
          message:
            'This OTP has already been used.',
        });
      }

      /*
      |--------------------------------------------------------------------------
      | Check expiry using MySQL
      |--------------------------------------------------------------------------
      */

      if (Boolean(resetToken.isExpired)) {
        return res.status(400).json({
          success: false,
          message:
            'This OTP has expired.',
        });
      }

      /*
      |--------------------------------------------------------------------------
      | Verify OTP
      |--------------------------------------------------------------------------
      */

      const providedHash =
        hashOtp(otp);

      const otpMatches =
        hashesMatch(
          providedHash,
          resetToken.token_hash
        );

      if (!otpMatches) {
        return res.status(400).json({
          success: false,
          message:
            'Invalid or expired OTP.',
        });
      }

      return res.status(200).json({
        success: true,
        message:
          'OTP verified successfully.',
      });
    } catch (error) {
      console.error(
        'Verify reset OTP error:',
        error
      );

      return res.status(500).json({
        success: false,
        message:
          'Unable to verify OTP.',
        error: error.message,
      });
    }
  }
);

/*
|--------------------------------------------------------------------------
| POST /api/users/reset-password
|--------------------------------------------------------------------------
|
| Verify OTP and update password.
|--------------------------------------------------------------------------
*/

router.post(
  '/reset-password',
  async (req, res) => {
    const email =
      typeof req.body.email === 'string'
        ? req.body.email.trim().toLowerCase()
        : '';

    const otp =
      typeof req.body.otp === 'string'
        ? req.body.otp.trim()
        : String(
            req.body.otp || ''
          ).trim();

    const newPassword =
      typeof req.body.newPassword === 'string'
        ? req.body.newPassword
        : '';

    try {
      if (!email) {
        return res.status(400).json({
          success: false,
          message:
            'Email address is required.',
        });
      }

      if (!/^\d{6}$/.test(otp)) {
        return res.status(400).json({
          success: false,
          message:
            'OTP must be a 6-digit code.',
        });
      }

      if (newPassword.length < 6) {
        return res.status(400).json({
          success: false,
          message:
            'Password must be at least 6 characters.',
        });
      }

      /*
      |--------------------------------------------------------------------------
      | Get latest OTP
      |--------------------------------------------------------------------------
      */

      const [rows] =
        await db.query(
          `
          SELECT
            prt.id,
            prt.user_id,
            prt.token_hash,
            prt.expires_at,
            prt.used_at,
            CASE
              WHEN prt.expires_at <= NOW() THEN 1
              ELSE 0
            END AS isExpired
          FROM password_reset_tokens prt
          INNER JOIN users u
            ON u.id = prt.user_id
          WHERE LOWER(u.email) = LOWER(?)
          ORDER BY prt.id DESC
          LIMIT 1
          `,
          [email]
        );

      if (!rows.length) {
        return res.status(400).json({
          success: false,
          message:
            'Invalid or expired OTP.',
        });
      }

      const resetToken =
        rows[0];

      /*
      |--------------------------------------------------------------------------
      | Check used
      |--------------------------------------------------------------------------
      */

      if (resetToken.used_at) {
        return res.status(400).json({
          success: false,
          message:
            'This OTP has already been used.',
        });
      }

      /*
      |--------------------------------------------------------------------------
      | Check expiry using MySQL
      |--------------------------------------------------------------------------
      */

      if (Boolean(resetToken.isExpired)) {
        return res.status(400).json({
          success: false,
          message:
            'This OTP has expired.',
        });
      }

      /*
      |--------------------------------------------------------------------------
      | Verify OTP
      |--------------------------------------------------------------------------
      */

      const providedHash =
        hashOtp(otp);

      const otpMatches =
        hashesMatch(
          providedHash,
          resetToken.token_hash
        );

      if (!otpMatches) {
        return res.status(400).json({
          success: false,
          message:
            'Invalid or expired OTP.',
        });
      }

      /*
      |--------------------------------------------------------------------------
      | Hash new password
      |--------------------------------------------------------------------------
      */

      const passwordHash =
        await bcrypt.hash(
          newPassword,
          10
        );

      /*
      |--------------------------------------------------------------------------
      | Update password
      |--------------------------------------------------------------------------
      */

      await db.query(
        `
        UPDATE users
        SET
          password_hash = ?,
          updated_at = NOW()
        WHERE id = ?
        `,
        [
          passwordHash,
          resetToken.user_id,
        ]
      );

      /*
      |--------------------------------------------------------------------------
      | Mark OTP as used
      |--------------------------------------------------------------------------
      */

      await db.query(
        `
        UPDATE password_reset_tokens
        SET used_at = NOW()
        WHERE id = ?
        `,
        [resetToken.id]
      );

      /*
      |--------------------------------------------------------------------------
      | Remove other reset tokens
      |--------------------------------------------------------------------------
      */

      await db.query(
        `
        DELETE FROM password_reset_tokens
        WHERE user_id = ?
          AND id <> ?
        `,
        [
          resetToken.user_id,
          resetToken.id,
        ]
      );

      return res.status(200).json({
        success: true,
        message:
          'Password reset successfully.',
      });
    } catch (error) {
      console.error(
        'Reset password error:',
        error
      );

      return res.status(500).json({
        success: false,
        message:
          'Unable to reset password.',
        error: error.message,
      });
    }
  }
);

/*
|--------------------------------------------------------------------------
| GET /api/users
|--------------------------------------------------------------------------
*/

router.get('/', async (req, res) => {
  try {
    const [rows] =
      await db.query(`
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
    console.error(
      'Get users error:',
      error
    );

    return res.status(500).json({
      success: false,
      message:
        'Failed to load users',
      error: error.message,
    });
  }
});

/*
|--------------------------------------------------------------------------
| GET /api/users/:id
|--------------------------------------------------------------------------
*/

router.get(
  '/:id',
  async (req, res) => {
    try {
      const userId =
        Number(req.params.id);

      if (
        !Number.isInteger(userId) ||
        userId <= 0
      ) {
        return res.status(400).json({
          success: false,
          message:
            'Invalid user ID.',
        });
      }

      const [rows] =
        await db.query(
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
          message:
            'User not found.',
        });
      }

      return res.json({
        success: true,
        data: rows[0],
      });
    } catch (error) {
      console.error(
        'Get user error:',
        error
      );

      return res.status(500).json({
        success: false,
        message:
          'Failed to load user',
        error: error.message,
      });
    }
  }
);

/*
|--------------------------------------------------------------------------
| POST /api/users
|--------------------------------------------------------------------------
| Create normal user.
|--------------------------------------------------------------------------
*/

router.post(
  '/',
  async (req, res) => {
    const {
      email,
      password,
      role,
      roleId,
      canDeactivate,
    } = req.body;

    try {
      if (
        !email ||
        !String(email).trim()
      ) {
        return res.status(400).json({
          success: false,
          message:
            'Email is required.',
        });
      }

      if (
        !password ||
        String(password).length < 6
      ) {
        return res.status(400).json({
          success: false,
          message:
            'Password must be at least 6 characters.',
        });
      }

      const cleanEmail =
        String(email)
          .trim()
          .toLowerCase();

      const [userCountRows] =
        await db.query(`
          SELECT COUNT(*) AS total
          FROM users
        `);

      const totalUsers =
        Number(
          userCountRows[0]?.total || 0
        );

      if (totalUsers === 0) {
        return res.status(409).json({
          success: false,
          message:
            'No users exist yet. Create the Primary Super Admin through the initial setup.',
        });
      }

      const [existingRows] =
        await db.query(
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
          message:
            'A user with this email already exists.',
        });
      }

      let selectedRole = null;

      if (
        roleId !== undefined &&
        roleId !== null &&
        roleId !== ''
      ) {
        const numericRoleId =
          Number(roleId);

        if (
          !Number.isInteger(
            numericRoleId
          ) ||
          numericRoleId <= 0
        ) {
          return res.status(400).json({
            success: false,
            message:
              'Invalid role ID.',
          });
        }

        const [roleRows] =
          await db.query(
            `
            SELECT
              id,
              name
            FROM roles
            WHERE id = ?
            LIMIT 1
            `,
            [numericRoleId]
          );

        if (roleRows.length) {
          selectedRole =
            roleRows[0];
        }
      } else if (
        role &&
        String(role).trim()
      ) {
        selectedRole =
          await getRoleByName(
            String(role).trim()
          );
      }

      if (!selectedRole) {
        return res.status(400).json({
          success: false,
          message:
            'Valid role is required.',
        });
      }

      const passwordHash =
        await bcrypt.hash(
          String(password),
          10
        );

      const deactivateValue =
        canDeactivate === true ||
        canDeactivate === 1 ||
        canDeactivate === '1' ||
        canDeactivate === 'true'
          ? 1
          : 0;

      const [result] =
        await db.query(
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
          VALUES (
            ?,
            ?,
            ?,
            1,
            ?,
            0,
            NULL,
            NOW(),
            NOW()
          )
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
        message:
          'User created successfully.',
        data: {
          id: result.insertId,
          email: cleanEmail,
          roleId:
            selectedRole.id,
          role:
            selectedRole.name,
          active: true,
          canDeactivate:
            Boolean(
              deactivateValue
            ),
          isPrimarySuperAdmin:
            false,
        },
      });
    } catch (error) {
      console.error(
        'Create user error:',
        error
      );

      return res.status(500).json({
        success: false,
        message:
          'Failed to create user',
        error: error.message,
      });
    }
  }
);

/*
|--------------------------------------------------------------------------
| PUT /api/users/:id
|--------------------------------------------------------------------------
*/

router.put(
  '/:id',
  async (req, res) => {
    const userId =
      Number(req.params.id);

    const {
      email,
      password,
      role,
      roleId,
      canDeactivate,
    } = req.body;

    try {
      if (
        !Number.isInteger(userId) ||
        userId <= 0
      ) {
        return res.status(400).json({
          success: false,
          message:
            'Invalid user ID.',
        });
      }

      const [userRows] =
        await db.query(
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
          message:
            'User not found.',
        });
      }

      const existingUser =
        userRows[0];

      let newEmail =
        existingUser.email;

      if (email !== undefined) {
        if (!String(email).trim()) {
          return res.status(400).json({
            success: false,
            message:
              'Email cannot be empty.',
          });
        }

        newEmail =
          String(email)
            .trim()
            .toLowerCase();

        const [duplicateRows] =
          await db.query(
            `
            SELECT id
            FROM users
            WHERE LOWER(email) = LOWER(?)
              AND id <> ?
            LIMIT 1
            `,
            [
              newEmail,
              userId,
            ]
          );

        if (duplicateRows.length) {
          return res.status(409).json({
            success: false,
            message:
              'A user with this email already exists.',
          });
        }
      }

      let selectedRoleId =
        existingUser.role_id;

      if (
        roleId !== undefined &&
        roleId !== null &&
        roleId !== ''
      ) {
        const numericRoleId =
          Number(roleId);

        if (
          !Number.isInteger(
            numericRoleId
          ) ||
          numericRoleId <= 0
        ) {
          return res.status(400).json({
            success: false,
            message:
              'Invalid role ID.',
          });
        }

        const [roleRows] =
          await db.query(
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
            message:
              'Selected role does not exist.',
          });
        }

        selectedRoleId =
          numericRoleId;
      } else if (
        role !== undefined &&
        String(role).trim()
      ) {
        const selectedRole =
          await getRoleByName(
            String(role).trim()
          );

        if (!selectedRole) {
          return res.status(400).json({
            success: false,
            message:
              'Selected role does not exist.',
          });
        }

        selectedRoleId =
          selectedRole.id;
      }

      let newCanDeactivate =
        existingUser.can_deactivate;

      if (
        Boolean(
          existingUser.is_primary_super_admin
        )
      ) {
        newCanDeactivate = 0;
      } else if (
        canDeactivate !== undefined
      ) {
        newCanDeactivate =
          canDeactivate === true ||
          canDeactivate === 1 ||
          canDeactivate === '1' ||
          canDeactivate === 'true'
            ? 1
            : 0;
      }

      let passwordHash = null;

      if (
        password !== undefined &&
        password !== ''
      ) {
        if (
          String(password).length < 6
        ) {
          return res.status(400).json({
            success: false,
            message:
              'Password must be at least 6 characters.',
          });
        }

        passwordHash =
          await bcrypt.hash(
            String(password),
            10
          );
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

      const [updatedRows] =
        await db.query(
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
        message:
          'User updated successfully.',
        data:
          updatedRows[0],
      });
    } catch (error) {
      console.error(
        'Update user error:',
        error
      );

      return res.status(500).json({
        success: false,
        message:
          'Failed to update user',
        error: error.message,
      });
    }
  }
);

/*
|--------------------------------------------------------------------------
| PUT /api/users/:id/status
|--------------------------------------------------------------------------
*/

router.put(
  '/:id/status',
  async (req, res) => {
    const userId =
      Number(req.params.id);

    const { active } =
      req.body;

    try {
      if (
        !Number.isInteger(userId) ||
        userId <= 0
      ) {
        return res.status(400).json({
          success: false,
          message:
            'Invalid user ID.',
        });
      }

      const newStatus =
        active === true ||
        active === 1 ||
        active === '1' ||
        active === 'true';

      const [userRows] =
        await db.query(
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
          message:
            'User not found.',
        });
      }

      const user =
        userRows[0];

      if (
        !newStatus &&
        Boolean(
          user.is_primary_super_admin
        )
      ) {
        return res.status(400).json({
          success: false,
          message:
            'The Primary Super Admin cannot be deactivated.',
        });
      }

      if (
        !newStatus &&
        !Boolean(
          user.can_deactivate
        )
      ) {
        return res.status(400).json({
          success: false,
          message:
            'This user is not allowed to be deactivated.',
        });
      }

      await db.query(
        `
        UPDATE users
        SET
          is_active = ?,
          updated_at = NOW()
        WHERE id = ?
        `,
        [
          newStatus ? 1 : 0,
          userId,
        ]
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
      console.error(
        'Update user status error:',
        error
      );

      return res.status(500).json({
        success: false,
        message:
          'Failed to update user status',
        error: error.message,
      });
    }
  }
);

/*
|--------------------------------------------------------------------------
| DELETE /api/users/:id
|--------------------------------------------------------------------------
*/

router.delete(
  '/:id',
  async (req, res) => {
    const userId =
      Number(req.params.id);

    try {
      if (
        !Number.isInteger(userId) ||
        userId <= 0
      ) {
        return res.status(400).json({
          success: false,
          message:
            'Invalid user ID.',
        });
      }

      const [userRows] =
        await db.query(
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
          message:
            'User not found.',
        });
      }

      const user =
        userRows[0];

      if (
        Boolean(
          user.is_primary_super_admin
        )
      ) {
        return res.status(400).json({
          success: false,
          message:
            'The Primary Super Admin cannot be deleted.',
        });
      }

      await db.query(
        `
        DELETE FROM users
        WHERE id = ?
        `,
        [userId]
      );

      return res.json({
        success: true,
        message:
          'User deleted successfully.',
      });
    } catch (error) {
      console.error(
        'Delete user error:',
        error
      );

      return res.status(500).json({
        success: false,
        message:
          'Failed to delete user',
        error: error.message,
      });
    }
  }
);

module.exports = router;
