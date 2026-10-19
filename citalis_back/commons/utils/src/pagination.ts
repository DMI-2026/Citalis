import { IsInt, IsOptional, Max, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';
import type { PaginatedResponse } from '@backend/contracts';

export class PaginationQueryDto {
  @ApiPropertyOptional({ default: 1, minimum: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page: number = 1;

  @ApiPropertyOptional({ default: 20, minimum: 1, maximum: 100 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  pageSize: number = 20;
}

export function buildPaginatedResponse<T>(
  data: T[],
  total: number,
  page: number,
  pageSize: number,
): PaginatedResponse<T> {
  return {
    data,
    pagination: { page, pageSize, total, totalPages: Math.ceil(total / pageSize) },
  };
}

/** Convierte `page`/`pageSize` en `skip`/`take` de Prisma. */
export function paginationToSkipTake(page: number, pageSize: number) {
  return { skip: (page - 1) * pageSize, take: pageSize };
}

/** Filtro estándar de soft-delete: `prisma.user.findMany({ where: { ...withNotDeleted() } })`. */
export function withNotDeleted(): { deletedAt: null } {
  return { deletedAt: null };
}
