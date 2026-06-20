# Audit Trail

El sistema registra un log de auditoria de todas las acciones importantes. Esto permite saber quien hizo que, cuando, y por que.

## Eventos registrados

| Tipo | Descripcion |
|------|-------------|
| `CHECK_IN` | Un staff hizo check-in de un guest en un meetup |
| `UNDO_CHECK_IN` | Un staff deshizo un check-in (incluye razon) |
| `WALKIN` | Se agrego un guest como walk-in en un meetup |
| `GUEST_CREATED` | Se creo un guest manualmente (via busqueda por username) |
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

- Por tipo: CHECK_IN, UNDO_CHECK_IN, BAN, UNBAN, WALKIN
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
