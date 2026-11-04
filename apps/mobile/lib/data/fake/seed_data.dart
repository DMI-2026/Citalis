// Datos semilla del modo demo (sin backend). Solo los usa `FakeStore`.
import '../../domain/models/business.dart';
import '../../domain/models/service.dart';

String seedImage(String id, {int w = 900}) =>
    'https://images.unsplash.com/photo-$id?w=$w&q=80&auto=format&fit=crop';

const String _salonA = '1560066984-138dadb4c035';
const String _salonB = '1522337360788-8b13dee7a37e';
const String _salonC = '1562322140-8baeececf3df';
const String _spaA = '1540555700478-4be289fbecef';
const String _spaB = '1544161515-4ab6ce6db874';
const String _spaC = '1600334129128-685c5582fd35';
const String _barberA = '1503951914875-452162b0f3f1';
const String _barberB = '1585747860715-2ba37e788b70';
const String _nailsA = '1604654894610-df63bc536371';
const String _nailsB = '1632345031435-8727f6897d53';
const String _browsA = '1583001809873-a128495da465';
const String _wellnessA = '1545205597-3d9d02c29597';
const String _wellnessB = '1506126613408-eca07ce68773';

/// Portada por defecto de un negocio recién registrado.
final String seedDefaultHeroImage = seedImage(_salonA);

final List<Business> seedBusinesses = [
  Business(
    id: 'b1',
    name: 'Casa Bella',
    category: 'Peluquería',
    neighborhood: 'Reforma',
    address: 'Av. Reforma 123, Cuernavaca',
    rating: 4.9,
    reviews: 182,
    distanceKm: 0.6,
    openHours: 'Hoy · 09:00 — 20:00',
    tagline: 'Color editorial y cortes de autor.',
    heroImage: seedImage(_salonA),
    gallery: [seedImage(_salonB, w: 600), seedImage(_salonC, w: 600)],
    services: [
      Service(
        id: 's1-1',
        name: 'Corte & lavado',
        description: 'Diagnóstico, corte personalizado y peinado.',
        durationMinutes: 45,
        price: 320,
      ),
      Service(
        id: 's1-2',
        name: 'Color global',
        description: 'Coloración profesional con tratamiento post-color.',
        durationMinutes: 120,
        price: 980,
      ),
      Service(
        id: 's1-3',
        name: 'Peinado evento',
        description: 'Recogido o suelto, incluye prueba previa.',
        durationMinutes: 60,
        price: 520,
      ),
    ],
  ),
  Business(
    id: 'b2',
    name: 'Atelier Nails',
    category: 'Uñas',
    neighborhood: 'Centro',
    address: 'Plaza Galerías · Local 42, Cuernavaca',
    rating: 4.8,
    reviews: 134,
    distanceKm: 1.2,
    openHours: 'Hoy · 10:00 — 21:00',
    tagline: 'Nail art minimalista hecho a mano.',
    heroImage: seedImage(_nailsA),
    gallery: [seedImage(_nailsB, w: 600), seedImage(_salonC, w: 600)],
    services: [
      Service(
        id: 's2-1',
        name: 'Manicure signature',
        description: 'Limado, cutícula y esmalte semipermanente.',
        durationMinutes: 50,
        price: 260,
      ),
      Service(
        id: 's2-2',
        name: 'Acrílicas con diseño',
        description: 'Aplicación completa con arte personalizado.',
        durationMinutes: 100,
        price: 680,
      ),
      Service(
        id: 's2-3',
        name: 'Pedicure spa',
        description: 'Exfoliación, mascarilla y esmalte.',
        durationMinutes: 60,
        price: 340,
      ),
    ],
  ),
  Business(
    id: 'b3',
    name: 'Noma Spa',
    category: 'Spa',
    neighborhood: 'Vista Hermosa',
    address: 'Vista Hermosa #88, Cuernavaca',
    rating: 4.9,
    reviews: 231,
    distanceKm: 2.4,
    openHours: 'Hoy · 11:00 — 22:00',
    tagline: 'Rituales de bienestar inspirados en el norte.',
    heroImage: seedImage(_spaA),
    gallery: [seedImage(_spaB, w: 600), seedImage(_spaC, w: 600)],
    services: [
      Service(
        id: 's3-1',
        name: 'Masaje profundo',
        description: 'Técnica sueca con aceites esenciales.',
        durationMinutes: 60,
        price: 780,
      ),
      Service(
        id: 's3-2',
        name: 'Facial hidra-glow',
        description: 'Limpieza, exfoliación y mascarilla iluminadora.',
        durationMinutes: 50,
        price: 620,
      ),
      Service(
        id: 's3-3',
        name: 'Ritual completo',
        description: 'Masaje + facial + aromaterapia (120 min).',
        durationMinutes: 120,
        price: 1480,
      ),
    ],
  ),
  Business(
    id: 'b4',
    name: 'Fox Barber',
    category: 'Barbería',
    neighborhood: 'Centro',
    address: 'Centro Histórico · Local 7, Cuernavaca',
    rating: 4.7,
    reviews: 198,
    distanceKm: 1.1,
    openHours: 'Hoy · 10:00 — 20:00',
    tagline: 'Afeitado clásico y cortes modernos.',
    heroImage: seedImage(_barberA),
    gallery: [seedImage(_barberB, w: 600)],
    services: [
      Service(
        id: 's4-1',
        name: 'Corte signature',
        description: 'Corte, perfilado y styling.',
        durationMinutes: 45,
        price: 260,
      ),
      Service(
        id: 's4-2',
        name: 'Afeitado tradicional',
        description: 'Toalla caliente, navaja y bálsamo.',
        durationMinutes: 30,
        price: 220,
      ),
      Service(
        id: 's4-3',
        name: 'Corte + barba',
        description: 'Experiencia completa para caballero.',
        durationMinutes: 70,
        price: 420,
      ),
    ],
  ),
  Business(
    id: 'b5',
    name: 'Luz Brow Bar',
    category: 'Cejas & Pestañas',
    neighborhood: 'Reforma',
    address: 'Av. Reforma 410, Int. 2, Cuernavaca',
    rating: 4.9,
    reviews: 96,
    distanceKm: 0.9,
    openHours: 'Hoy · 10:00 — 19:00',
    tagline: 'Microblading, lifting y laminado de cejas.',
    heroImage: seedImage(_browsA),
    gallery: [seedImage(_salonB, w: 600)],
    services: [
      Service(
        id: 's5-1',
        name: 'Diseño de cejas',
        description: 'Depilación con hilo y diseño personalizado.',
        durationMinutes: 30,
        price: 180,
      ),
      Service(
        id: 's5-2',
        name: 'Lifting de pestañas',
        description: 'Curvatura natural duradera (6 semanas).',
        durationMinutes: 50,
        price: 480,
      ),
    ],
  ),
  Business(
    id: 'b6',
    name: 'Studio Yoga',
    category: 'Wellness',
    neighborhood: 'Palmira',
    address: 'Palmira 221, Jardín, Cuernavaca',
    rating: 4.8,
    reviews: 312,
    distanceKm: 3.1,
    openHours: 'Hoy · 06:30 — 21:00',
    tagline: 'Yoga, meditación y breathwork en jardín.',
    heroImage: seedImage(_wellnessA),
    gallery: [seedImage(_wellnessB, w: 600)],
    services: [
      Service(
        id: 's6-1',
        name: 'Clase vinyasa',
        description: 'Sesión grupal 60 min, todos los niveles.',
        durationMinutes: 60,
        price: 220,
      ),
      Service(
        id: 's6-2',
        name: 'Yin + meditación',
        description: 'Práctica suave con cuencos tibetanos.',
        durationMinutes: 75,
        price: 260,
      ),
    ],
  ),
];

const List<String> seedBusinessCategories = [
  'Peluquería',
  'Uñas',
  'Spa',
  'Barbería',
  'Cejas & Pestañas',
  'Wellness',
  'Masajes',
  'Depilación',
];

const List<String> seedMunicipalities = [
  'Cuernavaca',
  'Jiutepec',
  'Temixco',
  'Yautepec',
  'Emiliano Zapata',
  'Xochitepec',
];
