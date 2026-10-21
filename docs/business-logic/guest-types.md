# Tipos de guest

Cada RSVP tiene un tipo de guest (`guest_type`) que dice en que caracter va esa persona a ese evento puntual. Sirve para eximir del pago a quienes no tienen que pagar entrada, sin tener que marcarlos como pagos a mano.

## Por que existe esto

En eventos pagos aparecen personas que estan en la lista pero no deberian pagar:

1. Invitados personales de la organizacion del evento.
2. Gente que trae su propio stand de venta y no va como asistente.
3. Gente que trabaja como staff del evento.

Antes de esto, la unica forma de dejarlos pasar era marcarlos como pagos, lo que mezclaba "pago de verdad" con "no tiene que pagar" y perdia el motivo en el audit log.

## Los cuatro tipos

| Valor | En la app | Paga entrada en un evento pago |
|-------|-----------|-------------------------------|
| `NORMAL` | General | Si |
| `INVITED` | Cortesia | No |
| `VENDOR` | Stand | No |
| `STAFF` | Staff | No |

Todo RSVP arranca como `NORMAL`, tanto los que trae el sync como los walk-ins.

!!! info "Es por evento, no por persona"
    El tipo vive en el RSVP, no en el guest. La misma persona puede tener un stand en un evento e ir como asistente comun al siguiente.

## Cambiar el tipo de un guest

Solo admins de org (y SITE_ADMINs) pueden cambiarlo. En la app, desde el menu `...` de la fila del guest en la pagina del meetup. Por API: `PATCH /organizations/{org_id}/meetups/{meetup_id}/guests/{guest_id}/type` con `{"guest_type": "VENDOR"}`.

- Cada cambio genera una entrada `GUEST_TYPE_CHANGED` en el audit log, con el valor anterior y el nuevo en la razon.
- No toca `has_paid`, `paid_at` ni quien marco el pago. Si alguien pago y despues lo reclasifican como staff, el pago registrado queda como estaba (por ejemplo, para devolverselo).
- No es retroactivo: reclasificar a alguien que ya hizo check-in no cambia su check-in.

| Condicion | Resultado |
|-----------|-----------|
| El guest no tiene RSVP en el meetup | Error 404 |
| El meetup esta finalizado | Error 409 |
| Quien lo pide no es admin de la org | Error 403 |

## Efecto sobre el check-in

En un evento pago, el check-in solo exige pago a los guests `NORMAL`. `INVITED`, `VENDOR` y `STAFF` pueden entrar aunque no tengan `has_paid`. En un evento gratis el tipo no cambia nada. Ver [Pagos](payments.md).

## Lo que el sync nunca toca

El sync nunca modifica `guest_type`. Igual que el pago, es un dato que carga un admin a mano.

## Estadisticas del meetup

`GET /organizations/{org_id}/meetups/{meetup_id}/stats` devuelve los conteos del meetup agrupados. Lo puede consultar cualquier miembro de la org. La app lo muestra arriba de la lista de guests.

| Grupo | Campos | Que cuenta |
|-------|--------|-----------|
| `attendance` | `total_rsvps`, `arrived_count`, `not_arrived_count`, `walkin_count` | RSVPs no cancelados |
| `cancellations` | `cancelled_count`, `cancelled_but_paid_count` | RSVPs cancelados, y cuantos de ellos ya habian pagado |
| `guest_types` | `normal_count`, `invited_count`, `vendor_count`, `staff_count` | RSVPs no cancelados, por tipo |
| `payment` | `paid_count`, `unpaid_count`, `exempt_from_payment_count` | RSVPs no cancelados |

`paid_count` y `unpaid_count` cuentan solo guests `NORMAL`. Un guest exento que igual tiene `has_paid` cuenta solo en `exempt_from_payment_count`, asi nadie se cuenta dos veces. Por eso siempre se cumple:

- `normal_count = paid_count + unpaid_count`
- `total_rsvps = normal_count + invited_count + vendor_count + staff_count`
- `total_rsvps = paid_count + unpaid_count + exempt_from_payment_count`

`cancelled_but_paid_count` sirve para saber a quien hay que devolverle la entrada.
