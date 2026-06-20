# Bans

El sistema de bans permite marcar a un guest como no bienvenido en una organizacion. Solo admins de la org (y SITE_ADMINs) pueden banear y desbanear.

## Los bans son por organizacion

Un ban aplica solamente dentro de la org donde se emitio. Si un guest esta baneado en "Alter Buenos Aires", puede seguir asistiendo a eventos de "Club Vanta" -- cada org gestiona su propia lista de bans de forma independiente.

## Que significa estar baneado

Un guest baneado aparece marcado en la lista de todos los meetups de la org. Si alguien intenta hacerle check-in, el sistema muestra una advertencia con la razon del ban. El staff puede ver la lista de baneados pero no puede emitir ni levantar bans.

## Banear un guest

Solo admins de org (y SITE_ADMINs). Requiere una razon (entre 5 y 500 caracteres). La razon es obligatoria para el audit trail: es el registro permanente de por que se tomo la decision.

Al banear:
- Se crea un registro de ban en la org para ese guest
- Se registra quien lo baneo, cuando, y por que
- Se crea una entrada en el audit log (`BAN`)

!!! warning "No se pueden tener dos bans activos"
    Solo puede existir un ban activo por guest por organizacion. Si el guest ya esta baneado, hay que desbanearlo primero antes de emitir uno nuevo.

## Desbanear un guest

Solo admins de org (y SITE_ADMINs). No requiere razon.

Al desbanear:
- El registro de ban activo se elimina
- Se crea una entrada en el audit log (`UNBAN`) con quien lo desbaneo y cuando

!!! note "El historial no se pierde"
    Aunque el registro de ban se elimina, los eventos BAN y UNBAN quedan en el audit log. Siempre vas a poder ver quien lo baneo, por que, y quien lo desbaneo.

## Actualizar la razon de un ban

No se puede editar la razon de un ban activo directamente. Para cambiar la razon:

1. Desbanear al guest
2. Banearlo de nuevo con la razon actualizada

Ambas acciones quedan registradas en el audit log.

## Lo que puede ver el staff sobre los bans

- En la lista de guests: los guests baneados aparecen marcados visualmente en todos los meetups de la org
- En la lista de baneados de la org: puede ver quien esta baneado y la razon
- En el historial de un guest: puede ver los eventos de BAN y UNBAN (pero no otros tipos de eventos)

El staff **no puede** banear ni desbanear.

## Flujo en la puerta con un guest baneado

1. El staff busca al guest en la lista del meetup
2. El guest aparece con indicador de baneado
3. Si el staff intenta hacer check-in, aparece un dialogo de advertencia con la razon del ban
4. El staff decide si igual lo deja entrar (a su criterio) o no
5. Si hace check-in de igual forma, queda registrado en el audit log

!!! note "El ban no bloquea tecnicamente el check-in"
    El sistema muestra la advertencia pero no bloquea el check-in. La decision final es del staff en la puerta. Esto es intencional: el staff necesita poder manejar situaciones excepcionales sin que el sistema se los impida.
