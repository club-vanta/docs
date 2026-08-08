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
- Devuelve 409 si el guest ya esta vinculado a otra cuenta de Mazmo. Hay que desvincular primero con `PATCH /guests/{id}/unlink-mazmo` si se quiere cambiar el vinculo.
- Devuelve 409 si ese `mazmo_user_id` ya pertenece a otro guest existente en el sistema. **No hay merge automatico de guests**: hay que elegir cual de los dos guests es el correcto, o corregir el username antes de reintentar.

### Desvincular: `PATCH /guests/{id}/unlink-mazmo`

Limpia `mazmo_user_id` y `mazmo_handle` del guest, dejandolo sin cuenta de Mazmo asociada.

El `displayname` no se revierte a ningun valor anterior (no se guarda historial de nombres): queda como estaba, y se puede corregir despues con `PATCH /guests/{id}`. El `mazmo_user_id` que queda libre puede volver a vincularse al mismo guest mas adelante, o a un guest distinto.

- Devuelve 404 si el guest no existe.
- Devuelve 409 si el guest no esta vinculado actualmente a ninguna cuenta de Mazmo.

!!! warning "El `id` nunca cambia"
    A traves de un ciclo completo de vincular, desvincular y volver a vincular a una cuenta de Mazmo distinta, el `id` interno del guest se mantiene igual. Es el identificador estable para referenciar a un guest desde otras tablas (RSVPs, bans, audit log) y desde el resto de la API (`{guest_id}` en los paths).

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

El unico dato que nunca cambia una vez creado el guest es su `id`. `mazmo_user_id` y `mazmo_handle` no son inmutables: empiezan en `None` si el guest se creo sin Mazmo, se completan al vincular (`link-mazmo`), se vacian al desvincular (`unlink-mazmo`), y pueden volver a completarse con una cuenta distinta en un re-vinculo posterior. Si el usuario cambia su handle en Mazmo mientras esta vinculado, la proxima sync puede actualizar `mazmo_handle`.

La clave primaria de la tabla es `id`, no `mazmo_user_id`. Esto es lo que permite que un guest exista sin Mazmo, y que el ciclo de vincular/desvincular no rompa las referencias desde otras tablas (RSVPs, bans, audit log): esas tablas apuntan al `id` del guest, que es estable sin importar su estado de vinculacion con Mazmo.

## Guests globales

Los guests son una entidad global del sistema: existen independientemente de los meetups y organizaciones. El mismo guest puede tener RSVPs en multiples meetups de distintas orgs.

Los **bans son por organizacion**: si alguien esta baneado en "Alter Buenos Aires", puede seguir asistiendo a eventos de "Club Vanta". Cada org gestiona su propia lista de bans. Ver [Bans](bans.md).
