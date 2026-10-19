import { buildPaginatedResponse, paginationToSkipTake, withNotDeleted } from './pagination';

describe('pagination', () => {
  it('calcula skip/take', () => {
    expect(paginationToSkipTake(3, 20)).toEqual({ skip: 40, take: 20 });
  });

  it('arma la respuesta paginada con totalPages redondeado hacia arriba', () => {
    expect(buildPaginatedResponse(['a', 'b'], 41, 1, 20).pagination).toEqual({
      page: 1,
      pageSize: 20,
      total: 41,
      totalPages: 3,
    });
  });

  it('withNotDeleted filtra registros con soft delete', () => {
    expect(withNotDeleted()).toEqual({ deletedAt: null });
  });
});
