# Mazmo

[Mazmo](https://mazmo.net) es una red social orientada a la comunidad LGBTQ+ de America Latina. Ofrece espacios de comunidad, mensajeria, y un sistema de eventos donde las organizaciones publican sus actividades y los miembros confirman asistencia (RSVP).

Alter usa Mazmo como canal principal para publicar sus meetups. Cuando Club Vanta anuncia un evento, lo hace a traves de un "evento" en Mazmo. Las personas que quieren asistir confirman su presencia directamente ahi.

## Por que existe el Alter Tracker

Mazmo gestiona bien los RSVPs, pero no tiene herramientas para operar la puerta de un evento. Cuando el evento esta en curso, el staff necesita saber quien ya llego, en que orden, y si hay personas que no deben ingresar. Mazmo no ofrece nada de eso.

El Alter Tracker existe para cubrir ese gap: toma la lista de RSVPs de Mazmo y agrega la capa de gestion en tiempo real -- registro de llegadas, orden de entrada, lista de bans por org, y un audit log completo.

## La relacion entre Mazmo y el Tracker

El Alter Tracker no crea ni modifica nada en Mazmo. El flujo de datos es en una sola direccion: de Mazmo hacia el tracker.

```mermaid
flowchart LR
    A["Mazmo\n(eventos y RSVPs)"] -->|"staff sincroniza\nla lista de guests"| B["Alter Tracker\n(control de puerta)"]
    C["Guest"] -->|"hace RSVP\nen Mazmo"| A
    D["Staff"] -->|"registra llegadas\nen la puerta"| B
    B -->|"guarda hora, orden\ny actor del check-in"| E["Registro de asistencia\ny audit log"]
```

Cada meetup en el tracker esta vinculado a una URL de evento en Mazmo. Cuando el staff sincroniza el meetup, el sistema consulta esa URL en Mazmo y descarga la lista de RSVPs actual. A partir de ahi, el tracker opera de forma independiente -- los check-ins, bans y el audit log son internos.

## Lo que el Tracker obtiene de Mazmo

Hay dos momentos en los que el tracker consulta a Mazmo:

**Al crear un meetup:** el tracker consulta la URL del evento para obtener el nombre y la fecha del evento. Esos datos se guardan localmente. Si el nombre o la fecha cambian en Mazmo despues de la creacion, el tracker no se actualiza automaticamente.

**Al sincronizar:** el tracker descarga la lista completa de RSVPs actuales. Ver [Sync desde Mazmo](sync.md) para el detalle del proceso.

## Identidad de los guests

La identidad de los guests (su `mazmo_user_id`, `username` y `displayname`) tambien viene de Mazmo. El `mazmo_user_id` es el identificador que Mazmo le asigna a cada cuenta y nunca cambia. Es lo que el tracker usa como clave primaria para reconocer a la misma persona en distintos eventos y syncs. Ver [Guests](guests.md).

## Catalogo de genero y pronombre

Mazmo no devuelve el genero ni el pronombre como texto: devuelve un codigo, y su propio frontend lo traduce. El tracker guarda el codigo crudo en `mazmo_profile.gender` y `mazmo_profile.pronoun`, y el frontend lo traduce con el mapeo de `src/lib/mazmoProfile.ts`. Si llega un codigo que no esta en la tabla, la app muestra el codigo tal cual.

La lista sale del bundle JS de mazmo.net (`GENDERS`, `USERS_PRONOUNS` y las claves `GENDER.*` y `PRONOUN.*` de su diccionario en espanol), relevada el 2026-10-21. Si Mazmo agrega un codigo nuevo, hay que sumarlo aca y en el frontend.

### Genero

| Codigo | Etiqueta en Mazmo | Etiqueta en ingles (tracker) | Pronombre por defecto |
|---|---|---|---|
| `MALE` | Hombre | Man | `MALE` |
| `FEMALE` | Mujer | Woman | `FEMALE` |
| `MALE_CIS` | Hombre cis | Cis man | `MALE` |
| `WOMAN_CIS` | Mujer cis | Cis woman | `FEMALE` |
| `MALE_TRANS` | Hombre trans | Trans man | `MALE` |
| `FEMALE_TRANS` | Mujer trans | Trans woman | `FEMALE` |
| `MALE_TRANSGENDER` | Transgénero masculino | Transgender man | `MALE` |
| `FEMALE_TRANSGENDER` | Transgénero femenina | Transgender woman | `FEMALE` |
| `TRANS` | Trans | Trans | `NEUTRAL` |
| `TRANSEXUAL` | Transexual | Transsexual | `NEUTRAL` |
| `TRANSGENDER` | Transgénero | Transgender | `NEUTRAL` |
| `TRAVESTI` | Travesti | Travesti | `NEUTRAL` |
| `CROSSDRESSER` | Crossdresser | Crossdresser | `NEUTRAL` |
| `INTERSEX` | Intersex | Intersex | `NEUTRAL` |
| `INTERSEXUAL` | Intersexual | Intersexual | `NEUTRAL` |
| `ANDROGYNOUS` | Andrógine | Androgynous | `NEUTRAL` |
| `NOT_BINARY` | No binarie | Non-binary | `NEUTRAL` |
| `NEUTRAL` | Neutral | Neutral | `NEUTRAL` |
| `QUEER` | Queer | Queer | `NEUTRAL` |
| `FLUID` | Género Fluido | Gender fluid | `NEUTRAL` |
| `UNDEFINED` | Indefinido | Undefined | `NEUTRAL` |

El pronombre por defecto es el que Mazmo le sugiere al usuario segun el genero. El usuario lo puede cambiar, asi que el tracker no lo deduce del genero: usa el campo `pronoun` que manda Mazmo.

### Pronombre

| Codigo | Etiqueta en Mazmo | En la ficha del guest | En el encabezado (es / en) |
|---|---|---|---|
| `MALE` | Masculino | Masculino / Masculine | él / he/him |
| `FEMALE` | Femenino | Femenino / Feminine | ella / she/her |
| `NEUTRAL` | Neutral | Neutral / Neutral | elle / they/them |

### Valores observados

Para referencia, en los attendees de dos eventos reales (Spookink II y Alter Gatuno Spooky Edition, 137 personas) los generos fueron: `MALE` 63, `FEMALE` 48, `WOMAN_CIS` 9, `NOT_BINARY` 7, `NEUTRAL` 2, `QUEER` 2, `ANDROGYNOUS` 1, `FEMALE_TRANS` 1, `MALE_CIS` 1, `MALE_TRANS` 1, sin dato 2. Los pronombres: `MALE` 64, `FEMALE` 62, `NEUTRAL` 9, sin dato 2. Ambos campos pueden venir en `null`.
