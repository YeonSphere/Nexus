# Nexus

A modern web application built with Bun and SvelteKit.

## Tech Stack
- Backend: Bun + Elysia + Drizzle ORM
- Frontend: SvelteKit + TypeScript
- Database: PostgreSQL

## Development Setup

### Prerequisites
- Arch Linux
- PostgreSQL
- npm
- Bun

### Backend Setup
```bash
cd "/backend"
bun install
```

### Frontend Setup
```bash
cd "/frontend"
bun install
```

### Database Setup
```bash
cd "/backend"
bun run db:migrate
```

### Environment Variables
```bash
cp .env.development .env
```

### License
YUOSL

### Completion Message
print -P "%F{green}Setup complete! Next steps:%f"
print -P "1. cd \$PROJECT_DIR"
print -P "2. Start backend: cd backend && bun run dev"
print -P "3. Start frontend: cd frontend && npm run dev"
