# Promover un usuario a Site Admin

Si el sistema no tiene ningun `SITE_ADMIN` (por ejemplo, en un deploy nuevo o si la unica cuenta admin fue eliminada), no hay forma de hacerlo desde la UI. Hay que hacerlo desde el servidor.

---

## Opcion 1: el usuario no existe todavia

Usar el script `seed_admin.py`, que crea el usuario con rol `SITE_ADMIN` e `is_approved=true` en un solo paso.

```bash
ADMIN_USERNAME=tu_usuario ADMIN_PASSWORD=tu_password uv run python scripts/seed_admin.py
```

El script es idempotente: si el usuario ya existe, no hace nada y termina normalmente.

!!! warning "Las migraciones tienen que estar aplicadas"
    Si la tabla `role` no existe o no tiene el rol `SITE_ADMIN`, el script falla con un error claro.
    Antes de correrlo, asegurate de haber corrido `alembic upgrade head`.

---

## Opcion 2: el usuario ya existe

Si la cuenta ya existe pero tiene un rol distinto, hay que actualizarla directamente en la base de datos.

```sql
UPDATE "user"
SET role_id = (SELECT id FROM role WHERE name = 'SITE_ADMIN'),
    is_approved = true
WHERE username = 'tu_usuario';
```

Desde la terminal del servidor, usando `psql`:

```bash
psql "$DATABASE_URL" -c "
UPDATE \"user\"
SET role_id = (SELECT id FROM role WHERE name = 'SITE_ADMIN'),
    is_approved = true
WHERE username = 'tu_usuario';
"
```

La query devuelve `UPDATE 1` si el usuario existia y fue actualizado. Si devuelve `UPDATE 0`, el username no existe -- verificar que este escrito exactamente igual (mayusculas incluidas).

!!! tip "Verificar el resultado"
    Para confirmar que el cambio se aplico correctamente:

    ```sql
    SELECT u.username, r.name AS role, u.is_approved
    FROM "user" u
    JOIN role r ON r.id = u.role_id
    WHERE u.username = 'tu_usuario';
    ```
