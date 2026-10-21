# Esquema de base de datos

Esquema actual post-migraciones de organizaciones (0001-0016). Todas las tablas usan PostgreSQL.

## Diagrama de relaciones

```mermaid
erDiagram
    user_roles {
        int id PK
        varchar name
    }
    users {
        int id PK
        varchar username
        varchar hashed_password
        bool is_approved
        int role_id FK
        timestamptz created_at
        bool is_disabled
        timestamptz disabled_at
        int disabled_by_id FK
        varchar disabled_reason
        varchar recovery_code
        timestamptz recovery_code_created_at
        bool recovery_code_used
    }
    organizations {
        uuid id PK
        varchar name
        varchar slug
        timestamptz created_at
        int created_by_id FK
    }
    user_organizations {
        int user_id PK_FK
        uuid org_id PK_FK
        varchar role
    }
    guests {
        uuid id PK
        int mazmo_user_id "nullable, unique"
        varchar mazmo_handle "nullable"
        varchar displayname
        varchar instagram_username "nullable"
    }
    guest_displayname_history {
        int id PK
        uuid guest_id FK
        varchar displayname
        varchar source
        int actor_id FK
        timestamptz recorded_at
    }
    guest_mazmo_profile {
        uuid guest_id PK_FK
        varchar avatar_url "nullable"
        int age "nullable"
        varchar gender "nullable"
        varchar pronoun "nullable"
        bool mazmo_suspended
        bool mazmo_banned
        timestamptz synced_at
    }
    meetups {
        uuid id PK
        uuid org_id FK
        varchar mazmo_meetup_url
        varchar name
        timestamptz date
        bool is_finalized
        timestamptz finalized_at
        bool requires_payment
    }
    meetup_rsvps {
        uuid meetup_id PK_FK
        uuid guest_id PK_FK
        timestamptz rsvp_time
        bool cancelled_rsvp
        bool has_arrived
        timestamptz arrival_time
        int arrival_order
        bool is_walkin
        int checked_in_by_id FK
        bool has_paid
        timestamptz paid_at
        int paid_by_id FK
        varchar guest_type
    }
    organization_bans {
        int id PK
        uuid org_id FK
        uuid guest_id FK
        int banned_by_id FK
        timestamptz banned_at
        varchar reason
    }
    event_log {
        int id PK
        varchar event_type
        timestamptz timestamp
        uuid org_id FK
        int actor_id FK
        uuid guest_id FK
        uuid meetup_id FK
        varchar reason
    }

    user_roles ||--o{ users : "rol de"
    users ||--o{ user_organizations : "es miembro en"
    organizations ||--o{ user_organizations : "tiene miembros"
    organizations ||--o{ meetups : "tiene"
    organizations ||--o{ organization_bans : "tiene bans"
    guests ||--o{ meetup_rsvps : "tiene RSVPs"
    meetups ||--o{ meetup_rsvps : "tiene guests"
    guests ||--o{ organization_bans : "puede estar baneado en"
    guests ||--o{ guest_displayname_history : "tuvo nombres"
    guests ||--o| guest_mazmo_profile : "tiene perfil de Mazmo"
    users ||--o{ event_log : "realiza acciones"
    guests ||--o{ event_log : "es sujeto de"
    meetups ||--o{ event_log : "tiene eventos"
    organizations ||--o{ event_log : "scopea eventos"
```

---

## Tablas

### `user_roles`

Tabla de lookup para roles globales. Sembrada por migraciones; no editable por usuarios.

| Columna | Tipo | Constraints | Notas |
|---------|------|-------------|-------|
| id | integer | PK | Auto-increment |
| name | varchar(32) | UNIQUE, NOT NULL | USER o SITE_ADMIN |

---

### `users`

Cuentas de staff y admin. Las cuentas nunca se borran fisicamente; ver `is_disabled`.

| Columna | Tipo | Constraints | Notas |
|---------|------|-------------|-------|
| id | integer | PK | Auto-increment |
| username | varchar(64) | UNIQUE, NOT NULL, indexed | Case-sensitive |
| hashed_password | varchar | NOT NULL | Hash Argon2 |
| is_approved | boolean | NOT NULL, default false | Debe ser true para poder entrar |
| role_id | integer | FK -> user_roles.id, NOT NULL | Rol global |
| created_at | timestamptz | NOT NULL | |
| is_disabled | boolean | NOT NULL, default false | Soft-delete |
| disabled_at | timestamptz | nullable | |
| disabled_by_id | integer | FK -> users.id, nullable | Quien la deshabilito |
| disabled_reason | varchar(500) | nullable | |
| recovery_code | varchar(6) | nullable | String de 6 digitos; NULL cuando no hay codigo activo |
| recovery_code_created_at | timestamptz | nullable | Para calcular el TTL de 72 horas |
| recovery_code_used | boolean | NOT NULL, default false | Marcado como usado al completar un reset exitoso |

---

### `organizations`

Contenedores de nivel superior. Cada org posee sus propios meetups, bans y eventos del audit log.

| Columna | Tipo | Constraints | Notas |
|---------|------|-------------|-------|
| id | uuid | PK | Generado al crear |
| name | varchar(128) | UNIQUE, NOT NULL | Nombre de display |
| slug | varchar(64) | UNIQUE, NOT NULL | Identificador para URLs |
| created_at | timestamptz | NOT NULL | |
| created_by_id | integer | FK -> users.id, nullable | |

---

### `user_organizations`

Membresia de un usuario en una organizacion con un rol especifico. PK compuesta en (user_id, org_id).

| Columna | Tipo | Constraints | Notas |
|---------|------|-------------|-------|
| user_id | integer | PK + FK -> users.id | |
| org_id | uuid | PK + FK -> organizations.id | |
| role | varchar(32) | NOT NULL | OrgRole: STAFF o ADMIN |

Un usuario puede ser miembro de multiples orgs con roles distintos en cada una.

---

### `guests`

Identidades de guests. Los guests son globales -- no pertenecen a ninguna org especifica. Una identidad puede o no estar vinculada a una cuenta de Mazmo: la PK es un `id` interno independiente de Mazmo, no `mazmo_user_id`.

| Columna | Tipo | Constraints | Notas |
|---------|------|-------------|-------|
| id | uuid | PK | Generado al crear; nunca cambia, incluso a traves de vincular/desvincular Mazmo |
| mazmo_user_id | integer | UNIQUE, nullable, indexed | Asignado por Mazmo; NULL si el guest no tiene cuenta de Mazmo vinculada |
| mazmo_handle | varchar | nullable, indexed | Handle de Mazmo; NULL en la misma condicion que mazmo_user_id |
| displayname | varchar | NOT NULL | Cambia frecuentemente |
| instagram_username | varchar(64) | nullable | Independiente del vinculo con Mazmo |

Los bans se almacenan en `organization_bans`, no en esta tabla. No existe campo `is_banned` en guests.

---

### `guest_displayname_history`

Cada valor que tuvo el `displayname` de un guest. Una fila por valor, incluido el primero; nunca se modifican ni eliminan (salvo en cascada si se borra el guest).

| Columna | Tipo | Constraints | Notas |
|---------|------|-------------|-------|
| id | integer | PK | Auto-increment |
| guest_id | uuid | FK -> guests.id (ON DELETE CASCADE), NOT NULL, indexed | |
| displayname | varchar | NOT NULL | El valor que tuvo el guest |
| source | varchar(16) | NOT NULL | SYNC, MANUAL_EDIT, MAZMO_LINK o BACKFILL |
| actor_id | integer | FK -> users.id (ON DELETE SET NULL), nullable | NULL para SYNC y BACKFILL |
| recorded_at | timestamptz | NOT NULL, default now() | Para BACKFILL es la fecha de la migracion 0018 |

Indice compuesto en `(guest_id, recorded_at)`: la consulta es siempre "todas las filas de este guest, ordenadas en el tiempo".

---

### `guest_mazmo_profile`

Foto del perfil de Mazmo de un guest vinculado. Relacion 1:1 con `guests`, sin historial: cada sync o `link-mazmo` pisa la fila. Se borra al desvincular el guest de Mazmo.

| Columna | Tipo | Constraints | Notas |
|---------|------|-------------|-------|
| guest_id | uuid | PK + FK -> guests.id (ON DELETE CASCADE) | |
| avatar_url | varchar | nullable | Solo la URL `default` del avatar de Mazmo |
| age | integer | nullable | |
| gender | varchar(32) | nullable | Texto libre de Mazmo, truncado a 32 caracteres |
| pronoun | varchar(32) | nullable | Texto libre de Mazmo, truncado a 32 caracteres |
| mazmo_suspended | boolean | NOT NULL, default false | Marca de Mazmo, no un ban de la org |
| mazmo_banned | boolean | NOT NULL, default false | Marca de Mazmo, no un ban de la org |
| synced_at | timestamptz | NOT NULL, default now() | De cuando es la foto |

---

### `meetups`

Eventos trackeados por el sistema. Cada meetup pertenece a una org y esta vinculado a una URL de Mazmo.

| Columna | Tipo | Constraints | Notas |
|---------|------|-------------|-------|
| id | uuid | PK | Generado al crear |
| org_id | uuid | FK -> organizations.id, NOT NULL, indexed | |
| mazmo_meetup_url | varchar | UNIQUE, NOT NULL | URL completa del evento en Mazmo |
| name | varchar | NOT NULL, indexed | Obtenido de Mazmo al crear |
| date | timestamptz | NOT NULL | Obtenido de Mazmo al crear |
| is_finalized | boolean | NOT NULL, default false | Bloquea check-ins y syncs cuando es true |
| finalized_at | timestamptz | nullable | Seteado al finalizar |
| requires_payment | boolean | NOT NULL, default false | Si true, el check-in exige has_paid=true en el RSVP. Se define al crear, editable despues via enable-payment/disable-payment |

---

### `meetup_rsvps`

Asociacion entre un guest y un meetup, con datos de RSVP y check-in. PK compuesta en (meetup_id, guest_id).

| Columna | Tipo | Constraints | Notas |
|---------|------|-------------|-------|
| meetup_id | uuid | PK + FK -> meetups.id | |
| guest_id | uuid | PK + FK -> guests.id | |
| rsvp_time | timestamptz | NOT NULL | Cuando se registro el RSVP en Mazmo |
| cancelled_rsvp | boolean | NOT NULL, default false | |
| has_arrived | boolean | NOT NULL, default false, indexed | Solo modificado por el flujo de check-in; el sync nunca lo toca |
| arrival_time | timestamptz | nullable | Solo seteado por check-in |
| arrival_order | integer | nullable | Asignado por trigger de DB; no por codigo de aplicacion |
| is_walkin | boolean | NOT NULL, default false | True si fue agregado como walk-in |
| checked_in_by_id | integer | FK -> users.id, nullable | Que staff hizo el check-in |
| has_paid | boolean | NOT NULL, default false, indexed | Solo relevante si el meetup tiene requires_payment=true |
| paid_at | timestamptz | nullable | Solo seteado al marcar el pago |
| paid_by_id | integer | FK -> users.id, nullable | Que admin marco el pago |
| guest_type | varchar(16) | NOT NULL, default 'NORMAL', indexed | NORMAL, INVITED, VENDOR o STAFF. Solo NORMAL paga en un evento pago |

!!! warning "Campos intocables por el sync"
    `has_arrived`, `arrival_time`, `arrival_order`, `checked_in_by_id`, `has_paid`, `paid_at`, `paid_by_id` y `guest_type` solo son modificados por los flujos de check-in, de pago y de tipo de guest. El sync nunca los toca, aunque actualice otros campos del RSVP.

`arrival_order` es asignado por un **trigger de base de datos** en el momento del check-in -- no es calculado por el codigo de aplicacion. El trigger asigna el siguiente entero disponible dentro del meetup.

---

### `organization_bans`

Bans activos de guests dentro de una organizacion. Una fila = un ban activo. Al desbanear se elimina la fila; el historial queda en `event_log`.

| Columna | Tipo | Constraints | Notas |
|---------|------|-------------|-------|
| id | integer | PK | Auto-increment |
| org_id | uuid | FK -> organizations.id, NOT NULL, indexed | |
| guest_id | uuid | FK -> guests.id, NOT NULL, indexed | |
| banned_by_id | integer | FK -> users.id, nullable | |
| banned_at | timestamptz | NOT NULL | |
| reason | varchar(500) | NOT NULL | Obligatorio; no puede estar vacio |

**Constraint UNIQUE en (org_id, guest_id):** solo puede existir un ban activo por guest por org.

---

### `event_log`

Audit log. Una fila por accion auditable. Las filas nunca se modifican ni eliminan.

| Columna | Tipo | Constraints | Notas |
|---------|------|-------------|-------|
| id | integer | PK | Auto-increment |
| event_type | varchar(32) | NOT NULL, indexed | Ver valores de EventType abajo |
| timestamp | timestamptz | NOT NULL, indexed | Default: now() |
| org_id | uuid | FK -> organizations.id, nullable, indexed | NULL solo para GUEST_CREATED, GUEST_MAZMO_LINKED, GUEST_MAZMO_UNLINKED y GUEST_DISPLAYNAME_CHANGED |
| actor_id | integer | FK -> users.id, nullable | El staff que realizo la accion |
| guest_id | uuid | FK -> guests.id, nullable, indexed | |
| meetup_id | uuid | FK -> meetups.id, nullable, indexed | |
| reason | varchar(500) | nullable | Presente para UNDO_CHECK_IN y BAN |

**Valores de EventType:** `CHECK_IN`, `UNDO_CHECK_IN`, `BAN`, `UNBAN`, `MEETUP_FINALIZED`, `MEETUP_UNFINALIZED`, `WALKIN`, `GUEST_CREATED`, `GUEST_MAZMO_LINKED`, `GUEST_MAZMO_UNLINKED`, `PAYMENT_RECORDED`, `PAYMENT_REVOKED`, `PAYMENT_REQUIREMENT_ENABLED`, `PAYMENT_REQUIREMENT_DISABLED`, `GUEST_DISPLAYNAME_CHANGED`, `GUEST_TYPE_CHANGED`

Cada entrada del audit log se escribe en la misma transaccion de base de datos que la accion que registra. Si la accion se revierte, la entrada del log se revierte con ella.

---

## Historial de migraciones

| Migracion | Resumen |
|-----------|---------|
| 0001 | Schema inicial: user_roles, users, guests, meetups, meetup_rsvps |
| 0002 | Refactor de schema multi-meetup |
| 0003 | Campos de disable en users; campos de tracking de check-in en meetup_rsvps |
| 0004 | Campos de ban global en guests (removidos en 0013) |
| 0005 | Tabla event_log |
| 0006 | Campos de finalizacion en meetups |
| 0007 | Flag is_walkin en meetup_rsvps |
| 0008 | Tabla organizations |
| 0009 | Tabla user_organizations |
| 0010 | FK meetups.org_id; seed org "Club Vanta"; backfill de membresias de usuarios |
| 0011 | Tabla organization_bans; org_id en event_log; backfill |
| 0012 | Renombrar roles globales (STAFF -> USER, ADMIN -> SITE_ADMIN); migrar usuarios |
| 0013 | Remover campos de ban global de guests; migrar bans existentes a organization_bans |
| 0014 | Campos de recovery_code en users |
| 0015 | requires_payment en meetups; has_paid/paid_at/paid_by_id en meetup_rsvps (eventos pagos) |
| 0016 | Identidad de guest desacoplada de Mazmo: guests.id (UUID) como PK, mazmo_user_id/mazmo_handle nullable, instagram_username, FKs de guest_id retargeteadas de mazmo_user_id a id |
| 0017 | guest_type en meetup_rsvps (exencion de pago por tipo de guest) |
| 0018 | Tabla guest_displayname_history, con backfill BACKFILL de los guests existentes |
| 0019 | Tabla guest_mazmo_profile |
