#!/usr/bin/env zsh

# Set the project directory
PROJECT_DIR="/home/dae/YeonSphere/Nexus"

# Print system information
echo -e "\033[1;34mSystem Information:\033[0m"
echo "==================="
echo "Kernel: $(uname -r)"
echo "Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "User: $USER"
echo

# Function to check if a package is installed
is_installed() {
    pacman -Qi "$1" >/dev/null 2>&1
}

# Install required system packages
echo -e "\033[1;32mInstalling system dependencies...\033[0m"
sudo pacman -Syu --needed --noconfirm \
    base-devel \
    git \
    postgresql \
    nodejs \
    npm \
    inotify-tools \
    httpie \
    tmux \
    ripgrep \
    fd \
    exa \
    bat

# Set up PostgreSQL
echo -e "\033[1;34mSetting up PostgreSQL...\033[0m"
if ! systemctl is-active --quiet postgresql; then
    sudo systemctl enable postgresql
    sudo systemctl start postgresql
    sudo -u postgres initdb -D /var/lib/postgres/data
    sudo -u postgres psql -c "CREATE USER nexus WITH PASSWORD '127733' CREATEDB;"
    sudo -u postgres createdb -O nexus nexus_dev
    sudo -u postgres createdb -O nexus nexus_test
fi

# Install Bun
echo -e "\033[1;34mInstalling Bun...\033[0m"
curl -fsSL https://bun.sh/install | bash

# Add Bun to PATH
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Create project directory
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR" || exit

# Initialize SvelteKit project
echo -e "\033[1;34mCreating SvelteKit project...\033[0m"
# Remove the frontend directory if it exists
rm -rf "$PROJECT_DIR/frontend"
# Create new SvelteKit project using the correct command
npx sv create "$PROJECT_DIR/frontend" --template minimal --types ts
cd "$PROJECT_DIR/frontend" || { echo "Failed to enter frontend directory"; exit 1; }
npm install

# Add required dependencies
npm install -D \
    @sveltejs/adapter-node \
    @typescript-eslint/eslint-plugin \
    @typescript-eslint/parser \
    prettier \
    prettier-plugin-svelte \
    svelte-check

# Initialize backend with Bun
echo -e "\033[1;34mCreating Bun backend...\033[0m"
cd "$PROJECT_DIR"
mkdir -p backend/src/{routes,models,middleware,utils}

# Initialize Bun project
cd backend
bun init -y

# Update package.json for backend
cat > package.json << 'EOL'
{
  "name": "nexus-backend",
  "version": "0.1.0",
  "module": "src/index.ts",
  "type": "module",
  "scripts": {
    "dev": "bun run --watch src/index.ts",
    "start": "bun run src/index.ts",
    "test": "bun test",
    "lint": "eslint src/**/*.ts",
    "format": "prettier --write 'src/**/*.{ts,json}'"
  },
  "dependencies": {
    "@elysiajs/cors": "latest",
    "@elysiajs/jwt": "latest",
    "@elysiajs/swagger": "latest",
    "elysia": "latest",
    "drizzle-orm": "latest",
    "postgres": "latest",
    "@types/pg": "latest"
  },
  "devDependencies": {
    "bun-types": "latest",
    "drizzle-kit": "latest",
    "@typescript-eslint/eslint-plugin": "latest",
    "@typescript-eslint/parser": "latest",
    "eslint": "latest",
    "prettier": "latest",
    "typescript": "latest"
  }
}
EOL

# Install backend dependencies
bun install

# Create backend TypeScript configuration
cat > tsconfig.json << 'EOL'
{
  "compilerOptions": {
    "lib": ["ESNext"],
    "module": "ESNext",
    "target": "ESNext",
    "moduleResolution": "bundler",
    "moduleDetection": "force",
    "allowImportingTsExtensions": true,
    "noEmit": true,
    "composite": true,
    "strict": true,
    "downlevelIteration": true,
    "skipLibCheck": true,
    "jsx": "preserve",
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true,
    "allowJs": true,
    "types": [
      "bun-types"
    ]
  }
}
EOL

# Create main backend entry point
cat > src/index.ts << 'EOL'
import { Elysia } from 'elysia'
import { cors } from '@elysiajs/cors'
import { swagger } from '@elysiajs/swagger'
import { jwt } from '@elysiajs/jwt'

const app = new Elysia()
  .use(cors())
  .use(swagger())
  .use(
    jwt({
      name: 'jwt',
      secret: process.env.JWT_SECRET || 'your-secret-key'
    })
  )
  .get('/', () => 'Hello Nexus!')
  .listen(3000)

console.log(
  `🦊 Server is running at ${app.server?.hostname}:${app.server?.port}`
)
EOL

# Create database schema
mkdir -p src/db
cat > src/db/schema.ts << 'EOL'
import { pgTable, serial, text, timestamp } from 'drizzle-orm/pg-core'

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  email: text('email').notNull().unique(),
  username: text('username').notNull().unique(),
  passwordHash: text('password_hash').notNull(),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow()
})
EOL

# Create example route
cat > src/routes/auth.ts << 'EOL'
import { Elysia, t } from 'elysia'
import { db } from '../db'
import { users } from '../db/schema'
import { eq } from 'drizzle-orm'
import { compareSync, hashSync } from 'bcrypt'

export const auth = new Elysia({ prefix: '/auth' })
  .post(
    '/signup',
    async ({ body, set }) => {
      const { email, username, password } = body

      const existingUser = await db
        .select()
        .from(users)
        .where(eq(users.email, email))
        .limit(1)

      if (existingUser.length > 0) {
        set.status = 400
        return { error: 'User already exists' }
      }

      const passwordHash = hashSync(password, 10)

      const [user] = await db
        .insert(users)
        .values({
          email,
          username,
          passwordHash
        })
        .returning()

      return { user }
    },
    {
      body: t.Object({
        email: t.String({ format: 'email' }),
        username: t.String({ minLength: 3 }),
        password: t.String({ minLength: 8 })
      })
    }
  )
EOL

# Create database utilities
cat > src/db/index.ts << 'EOL'
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from './schema'

const connectionString = process.env.DATABASE_URL || 'postgres://nexus:127733@localhost:5432/nexus_dev'

const client = postgres(connectionString)
export const db = drizzle(client, { schema })
EOL

# Create environment files
cat > .env.development << 'EOL'
DATABASE_URL=postgres://nexus:127733@localhost:5432/nexus_dev
JWT_SECRET=your_development_secret_key
EOL

cat > .env.production << 'EOL'
DATABASE_URL=postgres://nexus:127733@localhost:5432/nexus_prod
JWT_SECRET=your_production_secret_key
EOL

# Create main README
cat > README.md << 'EOL'
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
EOL

# Frontend Setup
echo -e "\033[1;34mFrontend Setup:\033[0m"
cd "$PROJECT_DIR/frontend" || { echo "Failed to enter frontend directory"; exit 1; }
npm install
npm run dev

# Database Setup
echo -e "\033[1;34mDatabase Setup:\033[0m"
cd "$PROJECT_DIR/backend" || { echo "Failed to enter backend directory"; exit 1; }
bun run db:migrate

# Environment Variables
echo -e "\033[1;34mSetting up Environment Variables:\033[0m"
cp .env.development .env

# License
echo -e "\033[1;34mLicense:\033[0m"
echo "YUOSL"

# Completion Message
print -P "%F{green}Setup complete! Next steps:%f"
print -P "1. cd \$PROJECT_DIR"
print -P "2. Start backend: cd backend && bun run dev"
print -P "3. Start frontend: cd frontend && npm run dev --open"