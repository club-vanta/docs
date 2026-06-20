# Sync desde Mazmo

El sync es la operacion que trae la lista de RSVPs de un evento desde Mazmo al sistema local.

## Por que es necesario

Los guests confirman asistencia directamente en Mazmo. El sistema local no tiene acceso en tiempo real a esa informacion: hay que pedirla explicitamente. El sync hace esa consulta y actualiza la base de datos local.

## Cuando hacer sync

- **Antes del evento**: para tener la lista de RSVPs cargada y lista para la puerta.
- **Durante el evento**: si alguien confirma asistencia a ultimo momento en Mazmo, un nuevo sync lo incluye.
- **Multiples veces**: el sync es idempotente, se puede correr cuantas veces se quiera sin riesgo.

Un meetup finalizado no acepta syncs.

## Que hace el sync

1. Consulta la API de Mazmo con la URL del evento
2. Obtiene la lista de usuarios que hicieron RSVP (con su `userId` y timestamp de RSVP)
3. Consulta los perfiles de esos usuarios en Mazmo (en lotes de hasta 30 por request)
4. Upsert de guests: si el guest no existe en el sistema, lo crea. Si ya existe, no lo modifica.
5. Upsert de RSVPs: si el RSVP no existe, lo crea. Si ya existe, actualiza el `rsvp_time`.
6. Marca como cancelados los RSVPs que ya no estan en la lista de Mazmo.

## Lo que el sync NUNCA toca

El sync nunca modifica los datos de check-in:

- `has_arrived`
- `arrival_time`
- `arrival_order`
- `checked_in_by_id`

Esto es critico: si alguien ya fue chequeado y se hace un nuevo sync, su estado de check-in no cambia.

## Idempotencia

El sync es seguro de correr multiples veces. El comportamiento es siempre el mismo:

- Guests ya existentes: no se modifican
- RSVPs ya existentes: se actualiza el `rsvp_time`, nada mas
- Check-in data: intocable

## RSVPs cancelados

Si un guest canceló su RSVP en Mazmo (y por lo tanto no aparece en la lista del evento), el sync marca ese RSVP como `cancelled_rsvp = true`. Si despues el guest vuelve a confirmar, el sync lo reactiva.

Un RSVP cancelado no impide el check-in (el staff puede hacerlo igual), pero si el guest no aparece en la lista principal al filtrar por RSVPs activos.

## Errores posibles

| Error | Causa | Que hacer |
|-------|-------|-----------|
| 504 Gateway Timeout | Mazmo no responde | Intentar de nuevo en unos minutos |
| 502 Bad Gateway | Mazmo devolvio un error | Verificar que la URL del evento siga siendo valida en Mazmo |

## Respuesta del sync

El sistema devuelve un resumen de la operacion:
- `inserted`: cuantos RSVPs nuevos se agregaron
- `skipped`: cuantos ya existian
- `total_in_db`: total de RSVPs para este meetup despues del sync
