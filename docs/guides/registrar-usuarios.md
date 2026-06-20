# Registrar usuarios

Esta guia explica como crear una cuenta en Alter Tracker y como un admin la aprueba para que el usuario pueda empezar a trabajar.

---

## Crear una cuenta

1. Entra a la plataforma y hace click en **"Registrarse"** (o pedile el link a tu admin).
2. Elegí un **nombre de usuario** (sin espacios, maximo 64 caracteres) y una **contrasena** (minimo 8 caracteres).
3. Confirma el registro.

!!! info "Tu cuenta queda pendiente"
    Despues de registrarte, **no vas a poder entrar todavia**. Tu cuenta queda en estado "pendiente" hasta que un admin la apruebe. Esto es normal - es una medida de seguridad para que no cualquiera pueda acceder al sistema.

Avisale a tu admin que te registraste para que te apruebe.

---

## Aprobar una cuenta (para admins)

Si sos admin de tu organizacion y alguien te avisa que se registro, segui estos pasos:

1. En el menu, entra a **Staff** (o **Usuarios**).
2. Vas a ver la lista de cuentas pendientes arriba.
3. Hace click en **"Aprobar"** en la cuenta que queres habilitar.

Una vez aprobada, el usuario ya puede entrar con su usuario y contrasena.

!!! tip "Asignar a una organizacion"
    Aprobar la cuenta es el primer paso, pero el usuario todavia no tiene acceso a ninguna organizacion. Una vez aprobado, tenes que [agregarlo a tu organizacion](organizations.md#agregar-miembros) con el rol correspondiente.

---

## Roles dentro de una organizacion

Una vez que el usuario esta aprobado y agregado a tu org, su nivel de acceso depende del rol que le asignes:

| Rol | Que puede hacer |
|-----|-----------------|
| **Staff** | Check-in, sincronizar RSVPs, ver lista de guests, agregar walk-ins |
| **Admin** | Todo lo de Staff + banear guests, finalizar meetups |

Para mas detalle, ver [Roles y permisos](../roles-and-access.md).

---

## Deshabilitar o revocar una cuenta

Si un usuario deja de ser parte del staff:

- **Removerlo de la organizacion**: va a perder acceso a esa org pero la cuenta sigue activa.
- **Deshabilitar la cuenta**: el usuario no puede entrar al sistema para nada. Sus datos historicos (check-ins, bans que registro) se preservan.

Estas opciones estan disponibles en la seccion **Staff** para admins del sistema.
