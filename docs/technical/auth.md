# Autenticacion

## JWT

El backend emite tokens JWT usando el algoritmo HS256 (HMAC-SHA256 con clave simetrica). Los tokens se obtienen haciendo `POST /auth/token` con username y password en formato OAuth2 password flow (form-encoded). El token recibido debe incluirse en cada request como `Authorization: Bearer <token>`.

Cada token codifica el username del usuario y su rol global (`USER` o `SITE_ADMIN`). Los tokens expiran a las 12 horas por defecto (configurable con `ACCESS_TOKEN_EXPIRE_MINUTES`).

Como el rol esta embebido en el token al momento del login, un cambio de rol no tiene efecto hasta que el usuario cierre sesion y vuelva a entrar.

## Almacenamiento del token en el frontend

El frontend (velvet) almacena el token en **localStorage** bajo la clave `auth_token`. Esto permite que la sesion persista al recargar la pagina.

Al montar la aplicacion, el frontend intenta re-autenticarse llamando a `GET /auth/userinfo` con el token almacenado:

- Si el servidor responde 401 (token expirado o invalido): el token se borra de localStorage y el usuario es enviado al login.
- Si hay un error de red: el token se conserva (se asume error transitorio, no token invalido).

## Modelo de roles en dos capas

### Rol global (nivel de cuenta)

Almacenado en el registro del usuario. Hay dos valores posibles:

- **USER**: rol estandar. La cuenta esta aprobada. Las capacidades dentro de cada org dependen del rol de org.
- **SITE_ADMIN**: superadmin. Bypasea todos los controles de org. Puede operar en cualquier org sin ser miembro.

### Rol de organizacion (nivel de membresia)

Para endpoints con scope de org, el backend verifica que el usuario sea miembro de la org objetivo y el rol que tiene en ella:

- **STAFF**: puede leer y escribir en la mayoria de operaciones de puerta (check-in, sync, ver guests y bans)
- **ADMIN**: todo lo que puede STAFF mas: banear/desbanear guests, finalizar meetups, audit log completo

Un SITE_ADMIN bypasea el control de membresia de org automaticamente, sin necesitar ser miembro.

Un mismo usuario puede tener roles distintos en distintas orgs. La membresia y el rol se almacenan por par (usuario, org).

## Cadena de autorizacion

Cada request pasa por una cadena de verificaciones:

1. **Validacion del token**: el JWT se verifica criptograficamente y se carga el usuario desde la base de datos
2. **Verificacion de aprobacion**: el usuario debe estar aprobado y no estar deshabilitado
3. **Verificacion de rol global** (para endpoints exclusivos de SITE_ADMIN)
4. **Verificacion de membresia de org** (para endpoints con scope de org): se consulta la base de datos para confirmar que el usuario es miembro de la org con el rol requerido

Los SITE_ADMINs pasan el control de membresia de org automaticamente.

## Recuperacion de contrasena

El sistema no tiene reset de contrasena por email. Ver [Recuperar contrasena](../guides/password-recovery.md) para el flujo desde el punto de vista del usuario.

**Detalles de implementacion:**

- Los codigos son strings numericos de 6 digitos con padding de ceros (ej: `"042817"`)
- Se almacenan en el registro del usuario junto con el timestamp de creacion
- TTL: 72 horas desde la generacion; se verifica en el momento de validar
- El endpoint `POST /auth/verify-recovery-code` verifica el codigo sin consumirlo
- El codigo se consume (marca como usado) solo cuando `POST /auth/reset-password` completa con exito
- Generar un codigo nuevo para un usuario que ya tiene uno invalida el anterior inmediatamente
- El lookup del username durante la recuperacion es case-sensitive

**Depurar un codigo que no funciona (query directa a la base de datos):**

```sql
SELECT
    username,
    recovery_code,
    recovery_code_used,
    recovery_code_created_at,
    recovery_code_created_at + INTERVAL '72 hours' AS expires_at,
    now() AS now_utc,
    now() > recovery_code_created_at + INTERVAL '72 hours' AS is_expired
FROM users
WHERE username = 'el_username';
```

| Columna | Que significa |
|---------|---------------|
| `recovery_code IS NULL` | No hay codigo generado para este usuario |
| `recovery_code_used = true` | El codigo fue consumido por un reset exitoso |
| `is_expired = true` | Pasaron las 72 horas -- generar uno nuevo |
