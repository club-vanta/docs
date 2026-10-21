# Guests

Un guest representa a una persona de la comunidad que puede asistir a eventos. La identidad del guest puede venir de Mazmo, pero tambien puede crearse sin ninguna cuenta de Mazmo asociada.

## Identidad

Cada guest tiene:

- **`id`**: UUID interno, identificador primario en el sistema. Nunca cambia, independientemente de si el guest se vincula, desvincula o re-vincula a una cuenta de Mazmo.
- **`mazmo_user_id`**: el ID numerico del usuario en Mazmo. Nullable: es `None` para un guest que no tiene cuenta de Mazmo vinculada.
- **`mazmo_handle`**: el handle del usuario en Mazmo (ej: `@cindydark`). Nullable, con la misma condicion que `mazmo_user_id`: ambos son `None` o ambos tienen valor, nunca uno solo.
- **`displayname`**: el nombre que el usuario elige mostrar. Cambia frecuentemente y no se usa como identificador.
- **`instagram_username`**: handle de Instagram, opcional. Es independiente de si el guest esta vinculado a Mazmo.

!!! warning "displayname vs identificadores"
    El `displayname` es libre y puede cambiar en cualquier momento. `mazmo_user_id` y `mazmo_handle` pueden ser `None` y tambien pueden cambiar a lo largo del tiempo (ver [Vinculo con Mazmo](#vinculo-con-mazmo)). Para identificar a una persona de forma estable, siempre usar `id`.

## De donde vienen los guests

Hay tres formas de que un guest entre al sistema:

### 1. Sync automatico desde Mazmo

El flujo mas comun. Al hacer sync de un meetup, el sistema trae todos los RSVPs y crea automaticamente los guests que no existian. Ver [Sync desde Mazmo](sync.md).

### 2. Creacion por username de Mazmo (`POST /guests/mazmo`)

Un staff o admin puede crear un guest buscandolo por su `@username` en Mazmo. El sistema consulta la API de Mazmo, obtiene el `mazmo_user_id` y los datos del perfil, y lo agrega al sistema local.

Esto se usa cuando alguien llega al evento pero no aparece en la lista (aun no se hizo sync, o el guest no tiene RSVP en Mazmo y se lo va a agregar como walk-in).

### 3. Creacion manual sin Mazmo (`POST /guests/manual`)

Un staff o admin puede crear un guest que no tiene cuenta de Mazmo, indicando solo un `displayname` (y opcionalmente un `instagram_username`). No se hace ninguna consulta a la API de Mazmo.

No se hace chequeo de duplicados: al no haber un identificador externo contra el cual comparar, dos guests con el mismo `displayname` pueden coexistir sin problema. Si mas adelante resulta que el guest si tiene (o crea) una cuenta de Mazmo, se puede vincular con `PATCH /guests/{id}/link-mazmo`.

## Vinculo con Mazmo

Un guest creado sin Mazmo (`mazmo_user_id` y `mazmo_handle` en `None`) puede vincularse a una cuenta de Mazmo mas adelante. Un guest ya vinculado tambien puede desvincularse, por ejemplo para corregir un vinculo hecho por error.

### Vincular: `PATCH /guests/{id}/link-mazmo`

Recibe un `username` de Mazmo, lo busca en la API de Mazmo, y sobreescribe `mazmo_user_id`, `mazmo_handle` y `displayname` del guest con los datos del perfil obtenido. `instagram_username` no se toca.

- Devuelve 404 si el guest no existe, o si el username no existe en Mazmo.
- Devuelve 409 si el guest ya esta vinculado a una cuenta de Mazmo (sin importar si es la misma cuenta u otra). Hay que desvincular primero con `PATCH /guests/{id}/unlink-mazmo` si se quiere cambiar el vinculo.
- Devuelve 409 si ese `mazmo_user_id` ya pertenece a otro guest existente en el sistema. **No hay merge automatico de guests**: hay que elegir cual de los dos guests es el correcto, o corregir el username antes de reintentar.

### Desvincular: `PATCH /guests/{id}/unlink-mazmo`

Limpia `mazmo_user_id` y `mazmo_handle` del guest, dejandolo sin cuenta de Mazmo asociada.

El `displayname` no se revierte a ningun valor anterior: queda como estaba, y se puede corregir despues con `PATCH /guests/{id}`. Los nombres anteriores quedan en el [historial de nombres](#historial-de-nombres). El `mazmo_user_id` que queda libre puede volver a vincularse al mismo guest mas adelante, o a un guest distinto.

Desvincular tambien borra el [perfil de Mazmo](#perfil-de-mazmo) guardado del guest, para no mostrar datos de una cuenta que ya no esta vinculada.

- Devuelve 404 si el guest no existe.
- Devuelve 409 si el guest no esta vinculado actualmente a ninguna cuenta de Mazmo.

!!! warning "El `id` nunca cambia"
    A traves de un ciclo completo de vincular, desvincular y volver a vincular a una cuenta de Mazmo distinta, el `id` interno del guest se mantiene igual. Es el identificador estable para referenciar a un guest desde otras tablas (RSVPs, bans, audit log) y desde el resto de la API (`{guest_id}` en los paths).

## Historial de nombres

El sistema guarda cada valor que tuvo el `displayname` de un guest, con su origen, quien lo cambio y cuando. Se consulta con `GET /guests/{guest_id}/displayname-history` (cualquier usuario aprobado), y la app lo muestra en el perfil del guest.

| Origen (`source`) | Cuando se registra | Actor |
|-------------------|--------------------|-------|
| `SYNC` | El sync crea el guest, o Mazmo reporta un nombre distinto al guardado | Ninguno |
| `MANUAL_EDIT` | Se crea el guest de forma manual, o alguien edita el nombre con `PATCH /guests/{id}` | El staff que lo hizo |
| `MAZMO_LINK` | Se crea el guest por username de Mazmo, o `link-mazmo` trae un nombre distinto | El staff que lo hizo |
| `BACKFILL` | Nombre que ya tenia cada guest cuando se agrego el historial | Ninguno |

- Es una linea de tiempo completa: una fila por cada valor, incluido el primero. Un guest siempre tiene al menos una fila.
- Solo se registra un cambio real. Editar el nombre al mismo valor que ya tenia no agrega nada.
- La fecha de las filas `BACKFILL` es la de la migracion que agrego el historial, no la del nombre en si.
- El sync siempre refleja lo que dice Mazmo: si alguien edito el nombre a mano y despues Mazmo reporta otro, el sync lo pisa y agrega una fila `SYNC`.

Cada cambio real de un guest que ya existia tambien deja un evento `GUEST_DISPLAYNAME_CHANGED` en el audit log. Las altas no lo generan, para que un sync grande no llene el log de "cambios" que en realidad son guests nuevos.

## Perfil de Mazmo

Para cada guest vinculado, el sistema guarda una foto del perfil de Mazmo: avatar, edad, genero, pronombre, y si Mazmo suspendio o baneo la cuenta. Viene en el campo `mazmo_profile` de las respuestas de guests, incluida la lista de guests de un meetup.

- Se actualiza en cada sync que incluye al guest, al vincularlo con `link-mazmo`, y al crearlo por username de Mazmo. No guarda historial: cada actualizacion pisa la anterior, y `synced_at` dice de cuando es la foto.
- `mazmo_profile` es `null` tanto para un guest sin Mazmo como para uno vinculado que todavia no paso por ningun sync.
- `gender` y `pronoun` son codigos de Mazmo (`MALE`, `WOMAN_CIS`, `NOT_BINARY`, etc.). El backend los guarda tal cual y la app los traduce al mostrarlos. Ver el [catalogo de genero y pronombre](mazmo.md#catalogo-de-genero-y-pronombre).

!!! warning "Suspendido o baneado en Mazmo no es un ban de la org"
    `mazmo_suspended` y `mazmo_banned` son marcas que pone Mazmo sobre la cuenta. No tienen relacion con los [bans](bans.md) de cada organizacion y no bloquean el check-in. La app los muestra aparte, para que el staff no los confunda con un vanteo.

## Lifecycle de un guest

```
No existe en el sistema
    |
    v (sync, creacion por username de Mazmo, o creacion manual sin Mazmo)
    |
Existe en el sistema (sin RSVP en el meetup actual)
    |
    v (sync trae su RSVP, o se agrega como walk-in)
    |
Tiene RSVP en el meetup (has_arrived = false)
    |
    v (check-in en la puerta)
    |
Checked in (has_arrived = true, arrival_order asignado)
```

Un guest puede ser baneado en cualquier momento de su lifecycle. Ver [Bans](bans.md).

## Datos inmutables

El unico dato que nunca cambia una vez creado el guest es su `id`. `mazmo_user_id` y `mazmo_handle` no son inmutables: empiezan en `None` si el guest se creo sin Mazmo, se completan al vincular (`link-mazmo`), se vacian al desvincular (`unlink-mazmo`), y pueden volver a completarse con una cuenta distinta en un re-vinculo posterior. Una vez vinculado, sin embargo, `mazmo_user_id` y `mazmo_handle` nunca cambian de forma automatica via sync: el upsert de guests del sync solo actualiza el `displayname` de un guest que ya existe (cuando Mazmo reporta uno distinto), nunca su vinculo. La unica forma de cambiarlos es desvincular con `unlink-mazmo` y volver a vincular con `link-mazmo`.

La clave primaria de la tabla es `id`, no `mazmo_user_id`. Esto es lo que permite que un guest exista sin Mazmo, y que el ciclo de vincular/desvincular no rompa las referencias desde otras tablas (RSVPs, bans, audit log): esas tablas apuntan al `id` del guest, que es estable sin importar su estado de vinculacion con Mazmo.

## Guests globales

Los guests son una entidad global del sistema: existen independientemente de los meetups y organizaciones. El mismo guest puede tener RSVPs en multiples meetups de distintas orgs.

Los **bans son por organizacion**: si alguien esta baneado en "Alter Buenos Aires", puede seguir asistiendo a eventos de "Club Vanta". Cada org gestiona su propia lista de bans. Ver [Bans](bans.md).
