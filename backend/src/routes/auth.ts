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
