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
