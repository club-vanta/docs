# API Reference

Todos los endpoints agrupados por dominio, con el rol minimo requerido para cada uno.

!!! info "Schemas completos en Swagger"
    Los schemas de request body, query params, y responses estan documentados en el Swagger UI: `https://api-alter-tracker.club-vanta.com/docs`

---

## Autenticacion

| Metodo | Path | Rol requerido | Descripcion |
|--------|------|--------------|-------------|
| POST | /auth/register | Ninguno | Crear una cuenta de staff (queda pendiente de aprobacion) |
| POST | /auth/token | Ninguno | Login; retorna un JWT bearer token |
| GET | /auth/userinfo | Usuario aprobado | Perfil del usuario actual |
| POST | /auth/verify-recovery-code | Ninguno | Verificar si un codigo de recuperacion es valido sin consumirlo |
| POST | /auth/reset-password | Ninguno | Cambiar contrasena usando un codigo de recuperacion; consume el codigo al completar |

---

## Organizaciones

Crear y editar organizaciones es exclusivo de SITE_ADMINs. La gestion de miembros esta disponible para ADMIN de org y SITE_ADMIN. Leer una org especifica esta disponible para cualquier miembro de esa org.

| Metodo | Path | Rol requerido | Descripcion |
|--------|------|--------------|-------------|
| GET | /organizations/ | SITE_ADMIN | Listar todas las organizaciones |
| POST | /organizations/ | SITE_ADMIN | Crear una organizacion |
| GET | /organizations/{org_id} | Miembro de la org o SITE_ADMIN | Ver detalles de la org |
| PATCH | /organizations/{org_id} | SITE_ADMIN | Editar nombre o slug de la org |
| GET | /organizations/{org_id}/members | ADMIN de org o SITE_ADMIN | Listar miembros de la org con sus roles |
| POST | /organizations/{org_id}/members/{user_id} | ADMIN de org o SITE_ADMIN | Agregar un usuario a la org con un rol |
| PATCH | /organizations/{org_id}/members/{user_id} | ADMIN de org o SITE_ADMIN | Cambiar el rol de un miembro (STAFF <-> ADMIN) |
| DELETE | /organizations/{org_id}/members/{user_id} | ADMIN de org o SITE_ADMIN | Remover un usuario de la org |

---

## Usuarios

| Metodo | Path | Rol requerido | Descripcion |
|--------|------|--------------|-------------|
| GET | /users/ | Usuario aprobado | Buscar usuarios por username (query param `q`) |

---

## Staff

| Metodo | Path | Rol requerido | Descripcion |
|--------|------|--------------|-------------|
| GET | /staff/ | SITE_ADMIN | Listar todas las cuentas de staff |
| GET | /staff/pending | SITE_ADMIN | Listar cuentas pendientes de aprobacion |
| PATCH | /staff/{user_id}/approve | SITE_ADMIN | Aprobar o revocar la aprobacion de una cuenta |
| PATCH | /staff/{user_id}/role | SITE_ADMIN | Cambiar el rol global de un usuario |
| PATCH | /staff/{user_id}/disable | SITE_ADMIN | Deshabilitar una cuenta (soft-delete, preserva historial) |
| PATCH | /staff/{user_id}/enable | SITE_ADMIN | Re-habilitar una cuenta deshabilitada |
| POST | /staff/{user_id}/recovery-code | SITE_ADMIN | Generar codigo de recuperacion de contrasena; retorna el codigo una sola vez |

---

## Guests

Cualquier usuario aprobado (sin importar la org) puede acceder a los registros de guests.

| Metodo | Path | Rol requerido | Descripcion |
|--------|------|--------------|-------------|
| GET | /guests/ | Usuario aprobado | Listar todos los guests conocidos |
| POST | /guests/ | Usuario aprobado | Registrar un guest por su username de Mazmo; consulta Mazmo para obtener su perfil |
| GET | /guests/{mazmo_user_id} | Usuario aprobado | Obtener un guest por su mazmo_user_id numerico |
| GET | /guests/by-username/{username} | Usuario aprobado | Obtener un guest por su username de Mazmo |

---

## Bans

Las operaciones de ban tienen scope de org. Ver la lista de baneados es accesible para cualquier miembro; emitir y levantar bans requiere rol ADMIN de org.

| Metodo | Path | Rol requerido | Descripcion |
|--------|------|--------------|-------------|
| GET | /organizations/{org_id}/guests/banned | Miembro de la org | Listar guests baneados actualmente en esta org |
| PATCH | /organizations/{org_id}/guests/{mazmo_user_id}/ban | ADMIN de org | Banear un guest en esta org; requiere razon |
| PATCH | /organizations/{org_id}/guests/{mazmo_user_id}/unban | ADMIN de org | Levantar el ban de un guest en esta org |

---

## Meetups

Todas las operaciones de meetup tienen scope de org. Cualquier miembro puede leer y sincronizar; finalizar requiere ADMIN de org.

| Metodo | Path | Rol requerido | Descripcion |
|--------|------|--------------|-------------|
| POST | /organizations/{org_id}/meetups/ | Miembro de la org | Crear un meetup desde una URL de Mazmo; obtiene nombre y fecha de Mazmo |
| GET | /organizations/{org_id}/meetups/ | Miembro de la org | Listar meetups de la org (ordenados por fecha desc) |
| GET | /organizations/{org_id}/meetups/{meetup_id} | Miembro de la org | Ver un meetup |
| POST | /organizations/{org_id}/meetups/{meetup_id}/sync | Miembro de la org | Sincronizar la lista de RSVPs desde Mazmo |
| GET | /organizations/{org_id}/meetups/{meetup_id}/guests | Miembro de la org | Listar guests con RSVP y su estado de check-in y ban |
| PATCH | /organizations/{org_id}/meetups/{meetup_id}/finalize | ADMIN de org | Finalizar el meetup; bloquea check-ins y syncs |
| PATCH | /organizations/{org_id}/meetups/{meetup_id}/unfinalize | ADMIN de org | Des-finalizar el meetup |

---

## Check-ins

Todas las operaciones de check-in tienen scope de org y estan disponibles para cualquier miembro.

| Metodo | Path | Rol requerido | Descripcion |
|--------|------|--------------|-------------|
| POST | /organizations/{org_id}/meetups/{meetup_id}/guests/{mazmo_user_id}/add-walkin | Miembro de la org | Agregar un guest al meetup como walk-in (sin RSVP previo) |
| POST | /organizations/{org_id}/meetups/{meetup_id}/guests/{mazmo_user_id}/checkin | Miembro de la org | Hacer check-in de un guest; registra hora de llegada, orden, y actor |
| PATCH | /organizations/{org_id}/meetups/{meetup_id}/guests/{mazmo_user_id}/undo-checkin | Miembro de la org | Deshacer un check-in; requiere razon |

---

## Audit Log (Eventos)

Todos los endpoints de audit log tienen scope de org. Lo que puede ver cada rol esta descrito en [Audit Trail](../audit-trail.md).

| Metodo | Path | Rol requerido | Descripcion |
|--------|------|--------------|-------------|
| GET | /organizations/{org_id}/events/ | ADMIN de org | Audit log completo de la org con filtros opcionales |
| GET | /organizations/{org_id}/events/meetups/{meetup_id} | Miembro de la org | Eventos de un meetup especifico |
| GET | /organizations/{org_id}/events/guests/{guest_id} | Miembro de la org | Eventos relacionados a un guest especifico |
| GET | /organizations/{org_id}/events/staff/{staff_id} | Miembro de la org | Eventos realizados por un staff especifico |

Los endpoints de eventos soportan filtros por tipo, rango de fechas, guest, meetup, actor, limit y offset. Ver Swagger para el detalle completo.

---

## Health

| Metodo | Path | Rol requerido | Descripcion |
|--------|------|--------------|-------------|
| GET | /ping | Ninguno | Liveness check; retorna `{"ping": "pong"}` |
| GET | /health | Ninguno | Health check incluyendo conectividad con la DB y la API de Mazmo |
| HEAD | /health | Ninguno | Health check liviano para UptimeRobot / Cloudflare |
