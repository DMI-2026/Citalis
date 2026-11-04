import { maskSensitiveFields } from './mask';

describe('maskSensitiveFields', () => {
  it('enmascara campos sensibles de forma recursiva, sin importar mayúsculas', () => {
    const result = maskSensitiveFields({
      name: 'Ana',
      Email: 'ana@correo.com',
      nested: { idToken: 'abc', ok: 1, list: [{ password: 'x', city: 'Cuernavaca' }] },
    });
    expect(result).toEqual({
      name: 'Ana',
      Email: '[REDACTED]',
      nested: {
        idToken: '[REDACTED]',
        ok: 1,
        list: [{ password: '[REDACTED]', city: 'Cuernavaca' }],
      },
    });
  });

  it('deja intactos los valores primitivos', () => {
    expect(maskSensitiveFields('texto')).toBe('texto');
    expect(maskSensitiveFields(null)).toBeNull();
  });
});
