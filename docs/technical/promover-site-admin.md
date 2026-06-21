# Promover un usuario a Site Admin

Si el sistema no tiene ningun `SITE_ADMIN` (por ejemplo, en un deploy nuevo o si la unica cuenta admin fue eliminada), no hay forma de hacerlo desde la UI. Hay que hacerlo desde el servidor.

---

## Obtener las credenciales de la DB

El servidor no tiene `psql` instalado directamente. Los comandos de base de datos se corren dentro del contenedor `db` usando `docker compose exec`.

Las credenciales viven en AWS Secrets Manager. Para cargarlas en el ambiente actual, correr lo mismo que hace `deploy.sh`:

```bash
SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "alter-tracker-backend/secrets" \
  --region "us-east-1" \
  --query SecretString \
  --output text)

DB_USER=$(echo "$SECRET_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['db_user'])")
DB_PASSWORD=$(echo "$SECRET_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['db_password'])")

export DB_USER DB_PASSWORD
```

---

## Opcion 1: el usuario no existe todavia

El `docker-compose.yml` ya tiene el servicio `seed` que corre `scripts/seed_admin.py`, que crea el usuario con rol `SITE_ADMIN` e `is_approved=true` en un solo paso.

Si `deploy.sh` ya cargo los secrets en el ambiente, el servicio puede re-correrse directamente:

```bash
docker compose run --rm seed
```

El script es idempotente: si el usuario ya existe, no hace nada y termina normalmente.

!!! warning "Las migraciones tienen que estar aplicadas"
    Si la tabla `role` no existe o no tiene el rol `SITE_ADMIN`, el script falla con un error claro.
    Antes de correrlo, asegurate de haber corrido `alembic upgrade head`.

---

## Opcion 2: el usuario ya existe

Si la cuenta ya existe pero tiene un rol distinto, hay que actualizarla directamente en la base de datos usando `psql` dentro del contenedor `db`:

```bash
docker compose exec db psql -U $DB_USER -d alter_event_tracker -c "
UPDATE users
SET role_id = (SELECT id FROM user_roles WHERE name = 'SITE_ADMIN'),
    is_approved = true
WHERE username = 'tu_usuario';
"
```

La query devuelve `UPDATE 1` si el usuario existia y fue actualizado. Si devuelve `UPDATE 0`, el username no existe -- verificar que este escrito exactamente igual (mayusculas incluidas).

!!! tip "Verificar el resultado"
    Para confirmar que el cambio se aplico correctamente:

    ```bash
    docker compose exec db psql -U $DB_USER -d alter_event_tracker -c "
    SELECT u.username, r.name AS role, u.is_approved
    FROM users u
    JOIN user_roles r ON r.id = u.role_id
    WHERE u.username = 'tu_usuario';
    "
    ```
