# Crear y gestionar una organizacion

Una **organizacion** es el espacio donde viven tus meetups, tus guests y tus bans. El acceso al sistema es siempre a traves de una org: los usuarios solo pueden hacer cosas dentro de las orgs a las que pertenecen.

Esta guia es para quienes administran el sistema a nivel global (rol **Site Admin**). Si sos staff de una org ya existente, no necesitas hacer esto - alguien ya lo hizo por vos.

---

## Crear una organizacion

1. En el menu principal, entra a **Organizaciones**.
2. Hace click en **"Nueva organizacion"**.
3. Completa los datos:
   - **Nombre**: el nombre completo de tu org (ej: `Alter Buenos Aires`)
   - **Slug**: una identificacion corta para URLs, solo letras minusculas y guiones (ej: `alter-bsas`)
4. Confirma la creacion.

!!! info "El slug no cambia"
    El slug se usa en links internos y debe ser unico en todo el sistema. Elegilo con cuidado porque no se puede editar despues.

---

## Agregar miembros

Una org sin miembros no sirve de nada. Una vez creada la org (o si estas administrando una existente):

1. Entra a la organizacion desde el menu.
2. Andá a la seccion **"Miembros"**.
3. Hace click en **"Agregar miembro"**.
4. Elegí el usuario (tiene que tener cuenta aprobada - ver [Registrar usuarios](registrar-usuarios.md)).
5. Asignale un rol:
   - **Staff**: para el equipo de puerta
   - **Admin**: para quienes necesitan poder banear guests o finalizar eventos

!!! tip "El usuario ya existe?"
    Si el usuario todavia no tiene cuenta, primero tenes que pedirle que se registre y luego aprobarlo. Una vez aprobada la cuenta, ya aparece disponible para agregar a la org.

---

## Cambiar el rol de un miembro

Si necesitas cambiar el rol de alguien (por ejemplo, promover a un staff a admin):

1. Entra a **Miembros** de la org.
2. Hace click en el usuario.
3. Cambia el rol y guarda.

Un usuario puede tener distintos roles en distintas orgs. Por ejemplo, puede ser Admin en "Alter BsAs" y Staff en "Club Vanta".

---

## Remover un miembro

Para sacar a alguien de la org sin deshabilitar su cuenta:

1. Entra a **Miembros** de la org.
2. Hace click en **"Remover"** en el usuario que queres sacar.

El usuario pierde acceso a esa org inmediatamente, pero su cuenta sigue activa y puede pertenecer a otras orgs.

!!! warning "Diferencia entre remover y deshabilitar"
    - **Remover de la org**: pierde acceso a esta org. Puede seguir usando el sistema si pertenece a otras.
    - **Deshabilitar cuenta**: no puede entrar al sistema para nada. Esto se hace desde la seccion **Staff**, no desde la org.

---

## Proximos pasos

Con la org creada y los usuarios adentro, el siguiente paso es [cargar tu primer evento](meetups.md).
