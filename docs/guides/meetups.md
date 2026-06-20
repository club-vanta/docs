# Cargar y preparar un evento

Esta guia cubre todo lo que tenes que hacer **antes** de que arranque el evento: cargar el meetup en el sistema y traer la lista de asistentes desde Mazmo.

---

## Cargar el meetup

1. En el menu, entra a tu **organizacion**.
2. Andá a la seccion **Meetups** y hace click en **"Nuevo meetup"**.
3. Completa los datos:
   - **Nombre**: algo descriptivo, ej: `Alter Buenos Aires #14`
   - **URL del evento en Mazmo**: la direccion de tu evento en Mazmo, ej: `https://mazmo.net/alter-bsas/alter-14-123456`
4. Confirma.

El sistema se conecta a Mazmo para verificar que el evento existe y obtiene automaticamente la **fecha del evento**. No tenes que ingresarla a mano.

!!! warning "La URL tiene que ser exacta"
    Copia la URL directamente desde la barra de direccion de tu navegador cuando estas en la pagina del evento en Mazmo. Si la URL no corresponde a un evento real, el sistema va a mostrar un error.

!!! info "Cada evento, una sola vez"
    No se puede cargar el mismo evento de Mazmo dos veces. Si alguien ya lo cargo, el sistema te va a avisar.

---

## Sincronizar los asistentes desde Mazmo { #sync }

Una vez creado el meetup, la lista de guests esta vacia. Para traer los RSVPs de Mazmo:

1. Entra al meetup desde la lista de meetups.
2. Hace click en **"Sincronizar desde Mazmo"**.
3. Espera a que termine - el sistema trae todos los RSVPs actuales y crea los perfiles de guests que no existian.

Cuando termina, vas a ver la lista de guests con todos los que confirmaron asistencia en Mazmo.

### Cuando hacer sync

Hace sync **antes de que empiece el evento** para tener la lista completa. Despues podes hacer sync de nuevo en cualquier momento mientras el meetup no este finalizado:

- **Antes del evento**: para tener la lista lista (pun intended)
- **Durante el evento**: si alguien confirma a ultimo momento en Mazmo, un nuevo sync lo agrega

!!! info "El sync no pisa los check-ins"
    Si ya hiciste check-in de alguien y volvés a sincronizar, ese check-in se mantiene. El sync agrega guests nuevos y actualiza datos de perfil, pero nunca toca quien ya llego.

!!! tip "Guests que cancellaron en Mazmo"
    Si alguien cancela en Mazmo y hacés sync, su RSVP queda marcado como cancelado en la lista pero no se borra. Asi sabés que esa persona inicialmente iba a venir pero luego cancelo.

---

## Durante el evento

Una vez que el evento arranzo, el flujo en la puerta es:

- **Check-in normal**: busca al guest en la lista y hace click en "Check In".
- **Walk-in**: si alguien llega sin RSVP, podes agregarlo manualmente. Ver [Check-in y walk-ins](../business-logic/checkin.md).
- **Guest baneado**: si un guest esta baneado en tu org, el sistema muestra una advertencia en el momento del check-in.

---

## Finalizar el meetup

Cuando el evento termino y la lista de asistentes es definitiva, un **admin** puede finalizar el meetup:

1. Entra al meetup.
2. Hace click en **"Finalizar"**.

Un meetup finalizado no acepta mas cambios: no se pueden hacer check-ins, syncs ni walk-ins. Si lo finalizaste por error, un admin puede des-finalizarlo.

!!! tip "Para que sirve finalizar?"
    Finalizar deja la lista de asistentes en un estado inamovible. Es util para reportes y para saber con certeza quien asistio al evento.
