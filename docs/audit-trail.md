# Audit Trail

El sistema registra un log de auditoria de todas las acciones importantes. Esto permite saber quien hizo que, cuando, y por que.

## Eventos registrados

| Tipo | Descripcion |
|------|-------------|
| `CHECK_IN` | Un staff hizo check-in de un guest en un meetup |
| `UNDO_CHECK_IN` | Un staff deshizo un check-in (incluye razon) |
| `WALKIN` | Se agrego un guest como walk-in en un meetup |
| `GUEST_CREATED` | Se creo un guest, ya sea via busqueda por handle de Mazmo o de forma manual (sin cuenta de Mazmo) |
| `GUEST_MAZMO_LINKED` | Se vinculo un guest existente (creado sin Mazmo) a una cuenta de Mazmo |
| `GUEST_MAZMO_UNLINKED` | Se desvinculo la cuenta de Mazmo de un guest |
| `GUEST_DISPLAYNAME_CHANGED` | Cambio el nombre de un guest que ya existia, por sync, edicion manual o `link-mazmo` (incluye nombre anterior y nuevo) |
| `GUEST_TYPE_CHANGED` | Un admin cambio el [tipo de guest](business-logic/guest-types.md) de un RSVP (incluye tipo anterior y nuevo) |
| `PAYMENT_RECORDED` | Un admin marco el pago de un guest |
| `PAYMENT_REVOKED` | Un admin deshizo un pago marcado (incluye razon) |
| `PAYMENT_REQUIREMENT_ENABLED` | Un admin hizo pago un meetup |
| `PAYMENT_REQUIREMENT_DISABLED` | Un admin hizo gratis un meetup |
| `BAN` | Un admin baneo un guest (incluye razon) |
| `UNBAN` | Un admin desbaneo un guest |
| `MEETUP_FINALIZED` | Un admin finalizo un meetup |
| `MEETUP_UNFINALIZED` | Un admin des-finalizo un meetup |

Cada evento registra:
- **Tipo** de evento
- **Timestamp** de cuando ocurrio
- **Actor** (el usuario staff/admin que realizo la accion)
- **Guest** afectado (cuando aplica)
- **Meetup** donde ocurrio (cuando aplica)
- **Razon** (para UNDO_CHECK_IN, BAN, etc.)

!!! info "Eventos globales de guests"
    `GUEST_CREATED`, `GUEST_MAZMO_LINKED`, `GUEST_MAZMO_UNLINKED` y `GUEST_DISPLAYNAME_CHANGED` no pertenecen a ninguna organizacion (su `org_id` es nulo), porque los guests son globales. Los endpoints de audit log son por organizacion, asi que estos eventos no aparecen ahi. Los cambios de nombre se ven en el historial de nombres del perfil del guest.

## Quien puede ver que

El acceso al audit log depende del rol:

### STAFF puede ver:
- **Audit log de un meetup especifico**: todos los eventos del meetup (`/events/meetups/{id}`)
- **Historial de un guest**: solo los eventos de tipo BAN y UNBAN (`/events/guests/{id}`)
- **Sus propias acciones**: puede consultar su propio historial de acciones

### ADMIN puede ver:
- **Audit log global**: todos los eventos del sistema, filtrables por tipo, fechas, guest, meetup, o actor
- **Historial completo de un guest**: todos los tipos de eventos, no solo bans
- **Acciones de cualquier staff**: puede ver lo que hizo cualquier usuario

## Filtros disponibles (para admins)

Desde la pantalla de eventos en la app:

- Por tipo: CHECK_IN, UNDO_CHECK_IN, BAN, UNBAN, WALKIN, PAYMENT_RECORDED, PAYMENT_REVOKED, GUEST_TYPE_CHANGED
- Por rango de fechas
- Por guest especifico
- Por meetup especifico
- Por actor (staff que realizo la accion)

## Inmutabilidad

El audit log es de solo lectura: los registros nunca se modifican ni se eliminan. Representa el historial definitivo de lo que ocurrio en el sistema.

## Casos de uso comunes

**"Quien chequeo a este guest?"**
Ver el historial del guest, filtrar por CHECK_IN.

**"Que paso en este evento?"**
Ver el audit log del meetup: todos los check-ins, walk-ins, y undos del dia.

**"Por que esta baneado este guest?"**
Ver el historial del guest, ver el evento BAN con la razon.

**"Que hizo este staff ayer?"**
Como admin, consultar el historial de acciones de ese usuario.

**"A que hora llego cada persona?"**
En el detalle del meetup, la lista de guests muestra el `arrival_order` y `arrival_time` de cada check-in.
