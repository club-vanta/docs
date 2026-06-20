# Check-in

El check-in es la operacion central del sistema: registrar que un guest llego al evento.

## Flujo de check-in normal

1. El guest llega a la puerta
2. El staff lo busca en la lista del meetup (por nombre o @username)
3. El staff hace click en "Check In"
4. El sistema verifica que:
   - El guest tiene RSVP en este meetup
   - El guest no esta ya checked in
   - El guest no esta baneado
   - El meetup no esta finalizado
5. Si todo esta bien, el sistema registra el check-in:
   - `has_arrived = true`
   - `arrival_time` se setea automaticamente con la hora actual
   - `arrival_order` se asigna automaticamente (secuencial por meetup, sin saltos)
   - Se registra que staff hizo el check-in
   - Se crea una entrada en el audit log

!!! warning "Guest baneado"
    Si el guest esta baneado, el sistema muestra un dialogo de advertencia. El staff puede ver la razon del ban. El check-in se puede hacer igual si el staff lo decide (el dialogo pide confirmacion), pero queda registrado en el audit log.

## Arrival order

El `arrival_order` indica en que posicion llego el guest al evento: 1 es el primero, 2 el segundo, etc. Es un numero secuencial sin saltos dentro de cada meetup.

Este numero se calcula automaticamente por un trigger de base de datos en el momento del check-in. El staff no necesita preocuparse por eso.

Si se deshace un check-in, el `arrival_order` se libera. Pero no se reasigna a nadie: el siguiente check-in recibe el numero siguiente disponible. Esto significa que pueden quedar "huecos" si se deshacen check-ins intermedios.

## Walk-ins

Un walk-in es un guest que llega al evento sin haber hecho RSVP en Mazmo. Para hacer check-in de un walk-in:

1. El guest no aparece en la lista del meetup
2. El staff agrega al guest como walk-in:
   - Si el guest ya existe en el sistema: buscarlo y agregar su RSVP con `is_walkin = true`
   - Si el guest no existe: crearlo primero desde su @username de Mazmo, luego agregarlo como walk-in
3. Una vez que tiene RSVP (con walk-in flag), se puede hacer check-in normalmente

Los walk-ins quedan marcados en el registro del evento para distinguirlos de los RSVPs originales de Mazmo.

## Deshacer check-in

Si se hizo un check-in por error, se puede deshacer. Requiere una razon (entre 5 y 500 caracteres). La razon queda en el audit log.

Al deshacer:
- `has_arrived` vuelve a `false`
- `arrival_time` y `arrival_order` se borran
- Se registra en el audit log con la razon

## Restricciones

| Condicion | Resultado |
|-----------|-----------|
| Guest sin RSVP | Error 404 - no puede hacer check-in sin RSVP previo |
| Guest ya checked in | Error 409 - hay que deshacer primero |
| Meetup finalizado | Error 409 - el evento ya cerro |
| Guest baneado | Advertencia - pide confirmacion al staff |

## Que registra el sistema

Cada check-in (y cada undo) queda en el [audit log](../audit-trail.md) con:
- Quien lo hizo (staff)
- A quien (guest)
- En que meetup
- Cuando
- Si fue undo: con que razon
