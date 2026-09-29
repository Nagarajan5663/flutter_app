# flutter_app

A new Flutter project.

## Sync SQL files to Hostinger

The backend reads its MySQL connection settings from `backend/.env`. Keep that file private and use the Hostinger database credentials already configured there.

To run every `.sql` file in `backend/database` once:

```powershell
cd backend
npm run db:sync
```

To keep the database folder watched while creating or editing SQL files:

```powershell
cd backend
npm run db:watch
```

Leave the watch command running. New or saved `.sql` files are executed against the database selected by `DB_NAME`. Use idempotent statements such as `CREATE TABLE IF NOT EXISTS` because saving a file executes it again. Deleting a SQL file does not delete its table.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
