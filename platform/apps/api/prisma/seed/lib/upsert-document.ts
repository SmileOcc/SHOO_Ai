import { PrismaClient } from '@prisma/client';

export async function upsertDocument(
  prisma: PrismaClient,
  key: string,
  payload: unknown,
) {
  await prisma.appDocument.upsert({
    where: { key },
    create: { key, payload: payload as object },
    update: { payload: payload as object },
  });
}
