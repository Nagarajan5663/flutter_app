const fs = require('fs');
const path = require('path');
const db = require('../config/db');

const databaseDirectory = __dirname;

function getSqlFiles() {
  return fs
    .readdirSync(databaseDirectory)
    .filter((fileName) => fileName.endsWith('.sql'))
    .sort();
}

async function runSqlFile(fileName) {
  const filePath = path.join(databaseDirectory, fileName);
  const sql = fs.readFileSync(filePath, 'utf8').trim();

  if (!sql) {
    return;
  }

  console.log(`Running ${fileName}...`);
  const [result] = await db.query(sql);

  if (Array.isArray(result)) {
    console.log(`${fileName} completed (${result.length} result set rows).`);
  } else {
    console.log(`${fileName} completed.`);
  }
}

async function syncDatabase() {
  const sqlFiles = getSqlFiles();

  if (sqlFiles.length === 0) {
    console.log('No SQL files found in the database folder.');
    return;
  }

  for (const sqlFile of sqlFiles) {
    await runSqlFile(sqlFile);
  }
}

async function watchDatabase() {
  await syncDatabase();

  const pending = new Map();
  let queuedRuns = Promise.resolve();
  const watcher = fs.watch(databaseDirectory, (eventType, changedFile) => {
    if (!changedFile) {
      return;
    }

    const fileName = changedFile.toString();
    if (!fileName.endsWith('.sql')) {
      return;
    }

    clearTimeout(pending.get(fileName));
    pending.set(fileName, setTimeout(() => {
      pending.delete(fileName);
      const filePath = path.join(databaseDirectory, fileName);

      if (!fs.existsSync(filePath)) {
        return;
      }

      queuedRuns = queuedRuns
        .then(() => runSqlFile(fileName))
        .catch((error) => {
          console.error(`Failed to run ${fileName}:`, error.message);
        });
    }, 300));
  });

  console.log('Watching backend/database for SQL file changes.');

  const stopWatching = async () => {
    watcher.close();
    for (const timer of pending.values()) {
      clearTimeout(timer);
    }
    await queuedRuns;
    await db.end();
    process.exit(0);
  };

  process.once('SIGINT', stopWatching);
  process.once('SIGTERM', stopWatching);
}

if (require.main === module) {
  const task = process.argv.includes('--watch')
    ? watchDatabase()
    : syncDatabase();

  task
    .catch((error) => {
      console.error('Database sync failed:', error.message);
      process.exitCode = 1;
    })
    .finally(async () => {
      if (!process.argv.includes('--watch')) {
        await db.end();
      }
    });
}

module.exports = {
  getSqlFiles,
  runSqlFile,
  syncDatabase,
  watchDatabase,
};
