# Guests

Un guest representa a una persona de la comunidad que puede asistir a eventos. La identidad del guest viene de Mazmo.

## Identidad

Cada guest tiene:

- **`mazmo_user_id`**: el ID numerico del usuario en Mazmo. Es el identificador primario en el sistema. Nunca cambia.
- **`username`**: el handle del usuario en Mazmo (ej: `@cindydark`). Es constante.
- **`displayname`**: el nombre que el usuario elige mostrar. Cambia frecuentemente y no se usa como identificador.

!!! warning "displayname vs username"
    El `displayname` es libre y puede cambiar en cualquier momento. Para identificar a una persona, siempre usar `username` o `mazmo_user_id`.

## De donde vienen los guests

Hay dos formas de que un guest entre al sistema:

### 1. Sync automatico desde Mazmo

El flujo mas comun. Al hacer sync de un meetup, el sistema trae todos los RSVPs y crea automaticamente los guests que no existian. Ver [Sync desde Mazmo](sync.md).

### 2. Creacion manual

Un staff o admin puede crear un guest buscandolo por su `@username` en Mazmo. El sistema consulta la API de Mazmo, obtiene el `mazmo_user_id` y los datos del perfil, y lo agrega al sistema local.

Esto se usa cuando alguien llega al evento pero no aparece en la lista (aun no se hizo sync, o el guest no tiene RSVP en Mazmo y se lo va a agregar como walk-in).

## Lifecycle de un guest

```
No existe en el sistema
    |
    v (sync o creacion manual)
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

Una vez creado, el `mazmo_user_id` y el `username` de un guest nunca cambian en el sistema. Si el usuario cambia su username en Mazmo, la proxima sync puede actualizar el dato local, pero el `mazmo_user_id` sigue siendo el mismo.

La razon por la que se usa `mazmo_user_id` como clave primaria es que permite hacer upserts idempotentes: si el mismo guest aparece en multiples syncs, siempre se identifica como la misma persona.

## Guests globales

Los guests son una entidad global del sistema: existen independientemente de los meetups y organizaciones. El mismo guest puede tener RSVPs en multiples meetups de distintas orgs.

Los **bans son por organizacion**: si alguien esta baneado en "Alter Buenos Aires", puede seguir asistiendo a eventos de "Club Vanta". Cada org gestiona su propia lista de bans. Ver [Bans](bans.md).
