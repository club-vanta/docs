# Roles y permisos

El sistema tiene dos niveles de permisos: un rol global de cuenta, y un rol dentro de cada organizacion.

Todos los usuarios necesitan ser aprobados por un admin antes de poder usar el sistema.

---

## Rol global de cuenta

Cuando se crea una cuenta, el sistema le asigna un rol global que define su nivel de acceso base.

### Usuario (USER)

El rol estandar para cualquier miembro del staff. Solo tiene acceso al sistema a traves de las organizaciones a las que pertenece. Sin pertenencia a una org, no puede hacer nada.

### Site Admin (SITE_ADMIN)

Rol de administracion global del sistema. Puede hacer todo en cualquier organizacion, sin necesidad de pertenecer a ellas. Se usa para:

- Crear y gestionar organizaciones
- Aprobar y gestionar cuentas de usuarios
- Acceder a cualquier org sin ser miembro

!!! warning "El Site Admin no es el admin del dia a dia"
    El Site Admin es un rol de infraestructura. Para las tareas del evento (banear, finalizar), el rol relevante es el de **Admin de organizacion** (ver abajo).

---

## Roles dentro de una organizacion

Ademas del rol global, cada usuario tiene un rol especifico dentro de cada organizacion a la que pertenece. Estos roles controlan lo que puede hacer en esa org.

### Staff

El rol base para quienes trabajan en la puerta durante un evento.

**Puede:**

- Ver y crear meetups
- Sincronizar RSVPs desde Mazmo
- Hacer check-in de guests y deshacer check-ins
- Agregar walk-ins
- Ver la lista de guests (incluyendo quienes estan baneados, para identificarlos en la puerta)
- Crear guests manualmente (busqueda por username en Mazmo)
- Ver el historial de bans/unbans de un guest especifico

**No puede:**

- Banear o desbanear guests
- Finalizar o re-abrir meetups
- Ver el audit log completo de la org

### Admin de organizacion

Acceso completo dentro de la org. Ademas de todo lo que puede hacer Staff:

**Puede:**

- Banear y desbanear guests en la org (con razon obligatoria)
- Finalizar y des-finalizar meetups
- Ver el audit log completo de la org (todos los eventos, todos los actores)

---

## Tabla de permisos

| Accion | Staff | Admin de org | Site Admin |
|--------|-------|--------------|------------|
| Ver meetups | Si | Si | Si |
| Crear meetup | Si | Si | Si |
| Sync desde Mazmo | Si | Si | Si |
| Check-in guest | Si | Si | Si |
| Deshacer check-in | Si | Si | Si |
| Agregar walk-in | Si | Si | Si |
| Ver lista de guests | Si | Si | Si |
| Crear guest manualmente | Si | Si | Si |
| Ver historial de bans de un guest | Si | Si | Si |
| **Banear guest** | No | Si | Si |
| **Desbanear guest** | No | Si | Si |
| **Finalizar meetup** | No | Si | Si |
| **Ver audit log completo de la org** | No | Si | Si |
| **Gestionar miembros de la org** | No | No | Si |
| **Crear organizaciones** | No | No | Si |
| **Aprobar/gestionar cuentas de staff** | No | No | Si |

---

## Aprobacion de cuentas

Los nuevos usuarios se registran con estado "pendiente". No pueden usar ningun endpoint hasta que un admin del sistema los apruebe. Un Site Admin puede tambien revocar la aprobacion o deshabilitar la cuenta completamente.

- **Pendiente**: se registro pero no fue aprobado todavia
- **Activo**: aprobado, puede usar el sistema segun su rol en cada org
- **Deshabilitado**: cuenta desactivada, no puede ingresar (sus datos historicos se preservan)

Ver [Registrar usuarios](guides/registrar-usuarios.md) para el paso a paso.

---

## Un usuario, multiples organizaciones

Un mismo usuario puede pertenecer a varias organizaciones con distintos roles. Por ejemplo:

- **Lucia**: Admin en "Alter Buenos Aires", Staff en "Club Vanta"
- **Tomas**: Staff en "Alter Buenos Aires" solamente

Los permisos son siempre en el contexto de la org. Lucia no puede banear guests de Club Vanta aunque sea Admin en Alter BsAs.
