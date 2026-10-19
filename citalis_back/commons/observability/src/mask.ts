/** Campos que nunca deben aparecer en logs (rúbrica S5: logs sin tokens ni datos personales). */
const SENSITIVE_FIELDS = new Set([
  'password',
  'token',
  'idtoken',
  'accesstoken',
  'refreshtoken',
  'authorization',
  'cookie',
  'email',
  'phone',
  'fcmtoken',
  'privatekey',
  'apikey',
  'secret',
  'databaseurl',
]);

const REDACTED = '[REDACTED]';

/** Enmascara recursivamente los campos sensibles de un objeto antes de loguearlo. */
export function maskSensitiveFields(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(maskSensitiveFields);
  if (value && typeof value === 'object') {
    const masked: Record<string, unknown> = {};
    for (const [key, val] of Object.entries(value as Record<string, unknown>)) {
      masked[key] = SENSITIVE_FIELDS.has(key.toLowerCase()) ? REDACTED : maskSensitiveFields(val);
    }
    return masked;
  }
  return value;
}
