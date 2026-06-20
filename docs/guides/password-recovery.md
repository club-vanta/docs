# Recuperar contrasena

El sistema no tiene recuperacion de contrasena por email. Si un usuario olvido su contrasena, un **Site Admin** genera un codigo temporal de 6 digitos que se le comunica de forma directa (WhatsApp, Telegram, en persona).

---

## Para el admin: generar un codigo

1. En el menu principal, entra a **Staff**.
2. Buscá al usuario que necesita recuperar su contrasena.
3. Hace click en el boton de recuperacion de contrasena en la fila del usuario.
4. Confirma la accion.
5. El sistema muestra el codigo **una sola vez** -- copialo o anotalo en ese momento.
6. Enviaselo al usuario por un canal privado (WhatsApp, Telegram, etc.).

!!! warning "El codigo se muestra una sola vez"
    Despues de cerrar el modal, no hay forma de ver el codigo de nuevo. Si lo perdiste antes de pasarselo al usuario, genera uno nuevo -- el anterior queda invalidado automaticamente.

!!! info "Un codigo activo por usuario"
    Cada usuario puede tener solo un codigo activo a la vez. Generar uno nuevo invalida el anterior inmediatamente.

---

## Para el usuario: usar el codigo

1. En la pantalla de login, hace click en **"Olvide mi contrasena"**.
2. Ingresa tu **nombre de usuario** exactamente como fue registrado (mayusculas incluidas).
3. Ingresa el **codigo de 6 digitos** que te paso el admin.
4. Si el codigo es valido, vas a poder ingresar tu nueva contrasena.
5. Confirma la nueva contrasena y guarda.
6. El codigo queda invalidado y ya podes entrar normalmente con tu nueva contrasena.

!!! tip "Cerrar la pestaña no gasta el codigo"
    Si ingresaste el codigo pero cerras la pestaña antes de guardar la nueva contrasena, el codigo sigue siendo valido. Podes volver a usarlo sin necesidad de pedir uno nuevo al admin.

---

## Si el codigo no funciona

| Situacion | Que hacer |
|-----------|-----------|
| Pasaron mas de 72 horas desde que se genero | Pedir al admin que genere un codigo nuevo |
| El admin genero un codigo nuevo despues de este | El codigo anterior queda invalidado; usar el nuevo |
| El nombre de usuario tiene casing incorrecto | Verificar que este escrito exactamente igual que en el sistema (ej: `MiUsuario` y `miusuario` son distintos) |
| El codigo ya fue usado para un reset exitoso | El codigo fue consumido; pedir uno nuevo |

Si ningun caso aplica, el admin puede verificar el estado del codigo directamente en la base de datos. Ver la documentacion tecnica en [docs.club-vanta.com](https://docs.club-vanta.com).
