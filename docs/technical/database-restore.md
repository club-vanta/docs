# Restaurar la base de datos desde un backup

Guia para recuperar la base de datos de produccion a partir de un backup almacenado en S3.

## Contexto

Los backups se generan automaticamente cada 2 horas con `pg_dump | gzip` y se almacenan en S3:

- **Bucket**: `alter-tracker-backend-db-backups-784421200272`
- **Formato de nombre**: `backup-YYYYMMDD_HHMMSS.sql.gz`
- **Retencion**: indefinida (limpiar manualmente si el bucket crece mucho)

El servidor de produccion es una instancia EC2 (`i-054c0dd0cd6c37dc5`) accesible solo via AWS SSM (sin SSH ni IP publica expuesta al puerto 22).

---

## Cuando restaurar

- El schema quedo en un estado inconsistente (migraciones mal aplicadas, etc.)
- Se corrio un `docker compose down -v` en produccion y el volumen de datos se perdio
- Rollback a un punto anterior luego de un deploy con errores

---

## Prerequisitos

En tu maquina local:

- AWS CLI configurado con credenciales que tengan acceso a SSM y S3
- `aws ssm` plugin instalado (`session-manager-plugin`)
- Perfil activo (`assume default` si usas Granted)

---

## Proceso de restauracion

### 1. Abrir sesion SSM

Desde tu maquina local:

```bash
aws ssm start-session \
  --target i-054c0dd0cd6c37dc5 \
  --document-name alter-tracker-backend-session-preferences \
  --region us-east-1
```

Esto abre una shell en el EC2 como `ec2-user`.

---

### 2. Bajar las credenciales de DB

El `deploy.sh` ya hace esto, pero si vas a operar manualmente antes del deploy, necesitas las credenciales:

```bash
cd /home/ec2-user

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id alter-tracker-backend/secrets \
  --region us-east-1 \
  --query SecretString \
  --output text)

extract() { echo "$SECRET_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['$1'])"; }

export DB_USER=$(extract db_user)
export DB_PASSWORD=$(extract db_password)
```

!!! warning "Latencia de red"
    La primera llamada a AWS desde el EC2 puede tardar hasta 60 segundos. Es un comportamiento conocido por como esta configurada la red (internet gateway sin NAT). Dejala correr, no la mates.

---

### 3. Levantar solo la DB

```bash
docker compose up -d db
```

Los warnings de variables no seteadas (JWT_SIGNING_KEY, etc.) son normales - solo afectan a los otros servicios.

Esperar que este lista:

```bash
docker compose exec db pg_isready -U $DB_USER -d alter_event_tracker
```

Cuando responde `alter_event_tracker - accepting connections`, continuar.

---

### 4. Descargar el backup

El `aws s3 cp` puede quedarse colgado por la latencia de red. La forma mas confiable es usar un presigned URL generado desde tu maquina local (que si tiene buena conectividad).

**Desde tu maquina local**, generar el presigned URL:

```bash
aws s3 presign s3://alter-tracker-backend-db-backups-784421200272/backup-YYYYMMDD_HHMMSS.sql.gz \
  --expires-in 3600 \
  --region us-east-1
```

**En el EC2**, descargar con curl (notar las comillas simples - obligatorias por los `&` en la URL):

```bash
curl -o /tmp/backup.sql.gz '<URL_generada_arriba>'
```

Verificar que el archivo es valido:

```bash
file /tmp/backup.sql.gz
# Debe decir: gzip compressed data, from Unix, ...
```

---

### 5. Restaurar el backup

```bash
gunzip -c /tmp/backup.sql.gz | docker compose exec -T db psql -U $DB_USER -d alter_event_tracker
```

Va a imprimir bastante output (CREATE TABLE, COPY, ALTER TABLE, etc.). Es normal. Si aparecen algunos errores de "already exists" en objetos de sistema, ignorarlos.

---

### 6. Verificar la version de migraciones

```bash
docker compose exec db psql -U $DB_USER -d alter_event_tracker \
  -c "SELECT version_num FROM alembic_version;"
```

El resultado debe coincidir con la ultima migracion que estaba aplicada al momento del backup. Por ejemplo, si el backup era del estado con migraciones hasta `0008`:

```
 version_num
-------------
 0008
(1 row)
```

---

### 7. Deployar la aplicacion

Una vez que la DB tiene los datos correctos, correr el deploy normal. Esto baja la imagen mas reciente de GHCR, aplica las migraciones faltantes (`alembic upgrade head`), y levanta todos los servicios:

```bash
bash /home/ec2-user/deploy.sh
```

---

### 8. Verificacion final

```bash
# Migraciones al dia
docker compose exec db psql -U $DB_USER -d alter_event_tracker \
  -c "SELECT version_num FROM alembic_version;"

# Todos los servicios corriendo
docker compose ps
```

Todos los servicios (`db`, `migrate`, `app`, `backup`) deben estar en estado `running` o `exited 0` (para `migrate` y `seed`, que terminan una vez completados).

---

## Notas sobre el formato del backup

Los backups usan `pg_dump` plano (no custom format). La primera linea del SQL contiene `\restrict` - es una feature de PostgreSQL 18 que restringe comandos peligrosos durante el restore. No afecta el proceso de restauracion normal.

El owner de todos los objetos es `alter_tracker`, que coincide con el `DB_USER` configurado en Secrets Manager.
