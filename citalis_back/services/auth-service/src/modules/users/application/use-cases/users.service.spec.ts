import { BadRequestException, ConflictException, NotFoundException } from '@nestjs/common';
import { UserAlreadyExistsError, UserEntity } from '../../domain/entities/user.entity';
import { IUserRepository } from '../../domain/repositories/user.repository.interface';
import { UsersService } from './users.service';

const user = (overrides: Partial<UserEntity> = {}): UserEntity => ({
  id: 'u-1',
  email: 'ana@correo.com',
  firebaseUid: 'uid-1',
  name: 'Ana',
  phone: null,
  defaultCity: null,
  createdAt: new Date('2026-10-01'),
  updatedAt: new Date('2026-10-01'),
  ...overrides,
});

function makeRepo(): jest.Mocked<IUserRepository> {
  return {
    findById: jest.fn().mockResolvedValue(null),
    findByFirebaseUid: jest.fn().mockResolvedValue(null),
    findByEmail: jest.fn().mockResolvedValue(null),
    create: jest.fn().mockImplementation(async (data) => user({ ...data })),
  };
}

describe('UsersService.register', () => {
  const identity = { firebaseUid: 'uid-1', email: 'ana@correo.com' };

  it('crea el usuario con el correo verificado de Firebase', async () => {
    const repo = makeRepo();
    const result = await new UsersService(repo).register(identity, {
      name: 'Ana',
      phone: '7771234567',
    });
    expect(result.created).toBe(true);
    expect(repo.create).toHaveBeenCalledWith({
      email: 'ana@correo.com',
      firebaseUid: 'uid-1',
      name: 'Ana',
      phone: '7771234567',
    });
  });

  it('es idempotente: un reintento devuelve el usuario existente sin crear otro', async () => {
    const repo = makeRepo();
    repo.findByFirebaseUid.mockResolvedValue(user());
    const result = await new UsersService(repo).register(identity, { name: 'Ana' });
    expect(result).toMatchObject({ created: false, user: { id: 'u-1' } });
    expect(repo.create).not.toHaveBeenCalled();
  });

  it('rechaza (409) un correo que ya pertenece a otra cuenta', async () => {
    const repo = makeRepo();
    repo.findByEmail.mockResolvedValue(user({ firebaseUid: 'otro-uid' }));
    await expect(new UsersService(repo).register(identity, { name: 'Ana' })).rejects.toBeInstanceOf(
      ConflictException,
    );
  });

  it('traduce la carrera de dos registros simultáneos (unique violation) a 409', async () => {
    const repo = makeRepo();
    repo.create.mockRejectedValue(new UserAlreadyExistsError());
    await expect(new UsersService(repo).register(identity, { name: 'Ana' })).rejects.toBeInstanceOf(
      ConflictException,
    );
  });

  it('rechaza (400) una identidad sin correo', async () => {
    await expect(
      new UsersService(makeRepo()).register({ firebaseUid: 'uid-1', email: null }, { name: 'Ana' }),
    ).rejects.toBeInstanceOf(BadRequestException);
  });
});

describe('UsersService consultas', () => {
  it('getProfile responde 404 si el usuario no existe', async () => {
    await expect(new UsersService(makeRepo()).getProfile('x')).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });

  it('findByFirebaseUid responde 404 si el UID no está registrado', async () => {
    await expect(new UsersService(makeRepo()).findByFirebaseUid('x')).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });
});
