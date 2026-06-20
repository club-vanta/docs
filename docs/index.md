# Alter Tracker

Sistema de control de puerta para eventos de Alter / Club Vanta.

## Para que sirve

Alter Tracker resuelve el problema de gestionar la entrada a los eventos de Mazmo.

Con esta plataforma, resolves saber quien llego, en que orden, y asegurarte de que personas baneadas no puedan ingresar.

El sistema tiene dos componentes:

- **Backend** (`alter-tracker-backend`): API REST en FastAPI + PostgreSQL que almacena toda la informacion y se integra con Mazmo.
- **Frontend** (`velvet`): Interfaz web en React que usa el staff en la puerta durante el evento.

## Como lo uso?

### Preparaciones previas al evento

Lo primero que tenes que hacer es asegurarte de que cada miembro de tu staff [tenga un usuario](guides/registrar-usuarios.md) en el sistema.

Una vez que todos tienen sus usuarios, tenes que [crear una organizacion](guides/organizations.md) y agregar los usuarios con su rol correspondiente.

Con la org y los usuarios listos, el siguiente paso es [cargar tu evento](guides/meetups.md) en el sistema y [sincronizar los RSVPs de Mazmo](guides/meetups.md#sync).

### Durante el evento

Entra al evento desde la pagina principal de tu org. Desde ahi tenes la lista de guests con RSVP y podes hacer check-in al llegar cada persona.

Si alguien llega sin RSVP (walk-in), podes agregarlo manualmente:

1. Si ya tiene perfil en el sistema: buscalo en la lista de guests y agregalo al evento.
2. Si no tiene perfil: buscalo por su `@username` de Mazmo en la seccion de Guests, el sistema lo trae automaticamente.

Una vez que el guest esta en el sistema, podes hacer check-in normalmente. Ver [Check-in](business-logic/checkin.md) para mas detalles.

## Integracion con Mazmo

Mazmo es la plataforma donde la comunidad publica eventos y los integrantes confirman asistencia (RSVP). Alter Tracker no reemplaza Mazmo: lo complementa. Los RSVPs se leen desde Mazmo y se sincronizan al sistema local para poder operar offline y registrar el check-in.

## Secciones de esta documentacion

**Guias paso a paso:**

- **[Registrar usuarios](guides/registrar-usuarios.md)**: como crear cuentas y aprobarlas
- **[Crear una organizacion](guides/organizations.md)**: como configurar tu org y agregar miembros
- **[Cargar un evento](guides/meetups.md)**: como cargar un meetup y sincronizar los RSVPs

**Referencia:**

- **[Roles y permisos](roles-and-access.md)**: quien puede hacer que en el sistema
- **[Guests](business-logic/guests.md)**: identidad de los asistentes, de donde vienen, como se gestionan
- **[Meetups](business-logic/meetups.md)**: ciclo de vida de un evento desde creacion hasta finalizacion
- **[Check-in](business-logic/checkin.md)**: el flujo de entrada en la puerta
- **[Bans](business-logic/bans.md)**: como funciona el sistema de bans por organizacion
- **[Sync desde Mazmo](business-logic/sync.md)**: como se traen los RSVPs de Mazmo al sistema
- **[Audit trail](audit-trail.md)**: registro de todo lo que pasa en el sistema

## Comunicate

Ante cualquier consulta, comunicate con:

- contacto@club-vanta.com
