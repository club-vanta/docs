# Pagos

Algunos eventos de la comunidad son pagos. Los guests se siguen anotando en Mazmo de la forma habitual, pero ademas necesitan haber pagado la entrada antes de poder ingresar al evento.

## Por que existe esto

El pago de la entrada lo maneja el organizador del evento por fuera del sistema (efectivo, transferencia, etc). Mazmo no tiene esa informacion, asi que no se puede sincronizar automaticamente. Un admin de la org confirma manualmente el pago de cada guest cuando corresponde.

## `requires_payment` en el meetup

Un meetup se marca como pago con el campo `requires_payment`. Se define al crear el meetup y no se puede editar despues -- si un evento gratuito pasa a ser pago, hay que crear un meetup nuevo.

Si `requires_payment` es `false` (el default), el sistema funciona exactamente igual que antes: el pago nunca se verifica.

## Marcar el pago de un guest

Solo admins de org (y SITE_ADMINs) pueden marcar o deshacer el pago de un guest. El staff puede hacer check-in pero no puede confirmar pagos.

Al marcar el pago:

- Se registra `has_paid = true`, `paid_at` con la hora actual, y que admin lo confirmo
- Se crea una entrada en el audit log (`PAYMENT_RECORDED`)

Restricciones:

| Condicion | Resultado |
|-----------|-----------|
| El meetup no requiere pago | Error 409 |
| El guest ya esta marcado como pago | Error 409 |
| El guest no tiene RSVP en el meetup | Error 404 |
| El meetup esta finalizado | Error 409 |

## Deshacer un pago marcado por error

Requiere una razon (entre 5 y 500 caracteres), igual que deshacer un check-in. La razon queda en el audit log (`PAYMENT_REVOKED`).

A diferencia de marcar el pago, deshacerlo **no** esta bloqueado por la finalizacion del meetup -- se trata como una correccion, igual que deshacer un check-in.

## Efecto sobre el check-in

Si el meetup requiere pago y el guest no fue marcado como pago, el check-in se **bloquea** con un error 409. A diferencia de los bans (que solo muestran una advertencia y el staff puede decidir igual), el pago es un bloqueo real: no hay forma de hacer check-in sin marcar el pago primero.

Esto aplica tambien a walk-ins: un guest agregado como walk-in a un evento pago necesita el mismo marcado de pago antes de poder entrar.

## Lo que el sync nunca toca

Igual que los campos de check-in, el sync desde Mazmo nunca modifica `has_paid`, `paid_at`, ni quien lo marco. El pago es exclusivamente manual.
