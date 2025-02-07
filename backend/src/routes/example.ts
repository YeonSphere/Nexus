import { Elysia } from 'elysia'

export const exampleRouter = new Elysia()
  .group('/api/examples', app => app
    .get('/', () => {
      return { message: 'List of examples' }
    })
    .post('/', ({ body }) => {
      // Handle POST request
      return { message: 'Created example', data: body }
    })
    .get('/:id', ({ params: { id } }) => {
      return { message: `Example ${id}` }
    })
  )