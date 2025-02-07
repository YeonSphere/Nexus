import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from './schema'

const connectionString = process.env.DATABASE_URL || 'postgres://nexus:127733@localhost:5432/nexus_dev'

const client = postgres(connectionString)
export const db = drizzle(client, { schema })
