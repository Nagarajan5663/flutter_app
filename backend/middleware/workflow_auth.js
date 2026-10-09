const crypto = require('crypto');
const db = require('../config/db');

const TOKEN_TTL_SECONDS = 12 * 60 * 60;

function signingSecret() {
  const secret = process.env.WORKFLOW_TOKEN_SECRET || process.env.DB_PASSWORD;
  if (!secret) throw new Error('Workflow token signing secret is not configured');
  return secret;
}

function sign(value) {
  return crypto.createHmac('sha256', signingSecret()).update(value).digest('base64url');
}

function issueWorkflowToken(userId) {
  const payload = Buffer.from(JSON.stringify({
    sub: Number(userId),
    exp: Math.floor(Date.now() / 1000) + TOKEN_TTL_SECONDS,
  })).toString('base64url');
  return `${payload}.${sign(payload)}`;
}

function safeEqual(left, right) {
  const a = Buffer.from(left);
  const b = Buffer.from(right);
  return a.length === b.length && crypto.timingSafeEqual(a, b);
}

async function requireSalesWorkflowUser(req, res, next) {
  try {
    const authorization = req.get('Authorization') || '';
    const match = authorization.match(/^Bearer\s+([A-Za-z0-9_.-]+)$/i);
    if (!match) return res.status(401).json({ success: false, message: 'Authentication is required.' });

    const [payloadPart, signaturePart] = match[1].split('.');
    if (!payloadPart || !signaturePart || !safeEqual(sign(payloadPart), signaturePart)) {
      return res.status(401).json({ success: false, message: 'Invalid authentication token.' });
    }

    const payload = JSON.parse(Buffer.from(payloadPart, 'base64url').toString('utf8'));
    const userId = Number(payload.sub);
    if (!Number.isInteger(userId) || userId <= 0 || Number(payload.exp) <= Math.floor(Date.now() / 1000)) {
      return res.status(401).json({ success: false, message: 'Authentication token has expired.' });
    }

    const [rows] = await db.query(`
      SELECT u.id, u.is_active, r.permissions
      FROM users u
      JOIN roles r ON r.id = u.role_id
      WHERE u.id = ?
      LIMIT 1
    `, [userId]);
    if (!rows.length || !rows[0].is_active) {
      return res.status(401).json({ success: false, message: 'Authenticated user is unavailable.' });
    }

    let permissions = [];
    try {
      permissions = typeof rows[0].permissions === 'string'
        ? JSON.parse(rows[0].permissions)
        : rows[0].permissions;
    } catch (_) {}
    if (!Array.isArray(permissions) || !permissions.some((p) => String(p).toLowerCase() === 'sales')) {
      return res.status(403).json({ success: false, message: 'Sales permission is required.' });
    }

    req.workflowUser = { id: userId };
    return next();
  } catch (error) {
    if (error.message === 'Workflow token signing secret is not configured') {
      return res.status(503).json({ success: false, message: error.message });
    }
    console.error('Sales workflow authentication error:', error);
    return res.status(401).json({ success: false, message: 'Invalid authentication token.' });
  }
}

module.exports = { issueWorkflowToken, requireSalesWorkflowUser };
