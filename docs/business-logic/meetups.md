# Meetups

Un meetup representa un evento de la comunidad que el sistema va a gestionar en la puerta.

## Datos de un meetup

- **`name`**: nombre descriptivo del evento (ej: "Alter Buenos Aires #12")
- **`mazmo_meetup_url`**: URL del evento en Mazmo (ej: `https://mazmo.net/alter-bsas/alter-12-123456`). Es unica por meetup.
- **`date`**: fecha y hora del evento, obtenida automaticamente de Mazmo al crear el meetup.
- **`is_finalized`**: si el evento ya cerro y no acepta mas cambios.

## Ciclo de vida

```
1. Creacion
   -> El staff provee nombre + URL de Mazmo
   -> El sistema valida que la URL exista en Mazmo y obtiene la fecha del evento
   -> El meetup queda creado (sin guests todavia)

2. Sync
   -> El staff ejecuta "Sync from Mazmo"
   -> El sistema trae la lista de RSVPs actuales desde Mazmo
   -> Los guests nuevos se crean, los RSVPs se actualizan
   -> Se puede hacer sync multiples veces (es idempotente)

3. Evento en curso
   -> Check-in de guests al llegar
   -> Nuevos syncs si llegan RSVPs de ultima hora
   -> Walk-ins para quien llega sin RSVP

4. Finalizacion
   -> Un admin finaliza el meetup
   -> Ya no se aceptan check-ins, undo check-ins, syncs, ni walk-ins
   -> Es reversible: un admin puede des-finalizar si fue un error
```

## Creacion

Al crear un meetup, el sistema hace una llamada a la API de Mazmo para verificar que la URL existe y obtener la fecha del evento. Si Mazmo no responde o la URL es invalida, el meetup no se crea.

Cada URL de Mazmo puede usarse solo una vez: no se puede crear dos meetups para el mismo evento.

## Sync

Antes de que empiece el evento, el staff hace sync para traer los RSVPs. Esto se puede hacer varias veces: si alguien confirma asistencia en Mazmo a ultimo momento, un nuevo sync lo incluye.

El sync es seguro de correr en cualquier momento: nunca pisa los datos de check-in. Ver [Sync desde Mazmo](sync.md) para el detalle.

## Finalizacion

La finalizacion es la forma de cerrar un meetup oficialmente. Una vez finalizado:

- No se pueden hacer check-ins nuevos
- No se puede deshacer check-ins
- No se puede hacer sync
- No se pueden agregar walk-ins

La finalizacion es reversible con "un-finalize", por si se hizo por error.

!!! note "Por que finalizar?"
    La finalizacion sirve para dejar el registro del evento en un estado inmutable. Permite saber con certeza que la lista de asistentes es definitiva.

## Relacion con guests

Los guests de un meetup son los que tienen un RSVP (ya sea sincronizado desde Mazmo o agregado como walk-in). El mismo guest puede tener RSVPs en multiples meetups, y cada RSVP es independiente: el check-in en un meetup no afecta el estado en otro.
