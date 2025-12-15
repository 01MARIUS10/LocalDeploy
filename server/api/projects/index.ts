import prisma from '../../utils/prisma'
import { toProjectListItemDTO } from '~/backend/dto/project.dto'

export default defineEventHandler(async (event) => {
  const query = getQuery(event)
  const userId = query.userId ? Number(query.userId) : undefined

  const projects = await prisma.project.findMany({
    where: userId ? { userId } : undefined,
    include: {
      user: {
        select: { id: true, name: true, email: true }
      },
      _count: {
        select: { 
          deployments: true,
          envVars: true 
        }
      }
    },
    orderBy: { updatedAt: 'desc' }
  })

  return {
    projects: projects.map(p => toProjectListItemDTO(p)),
    total: projects.length
  }
})