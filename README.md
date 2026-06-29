# Toast 🔔

![PowerBuilder](https://img.shields.io/badge/PowerBuilder-2025-orange?style=flat-square&logo=appveyor&logoColor=white)
![Tecnología](https://img.shields.io/badge/Windows-Toast%20Notifications-0078D6?style=flat-square&logo=windows&logoColor=white)
![Técnica](https://img.shields.io/badge/PowerBuilder-MultiThread-9cf?style=flat-square)
![Blog](https://img.shields.io/badge/blog-rsrsystem-FF5722?style=flat-square&logo=blogger&logoColor=white)

> Notificaciones nativas tipo *toast* de Windows 10/11 desde PowerBuilder: esos avisos emergentes no bloqueantes que asoman por la esquina y se van solos.

---

## 📋 ¿Qué es esto?

Esta semana me he puesto a trastear con las **notificaciones de Windows 10/11** desde PowerBuilder, esos avisos *toast* que aparecen en la esquina inferior derecha (y se quedan luego en el centro de notificaciones del sistema).

La idea es poder lanzar avisos al usuario **sin bloquear** la aplicación: ni un `MessageBox` que te corta el flujo, ni una ventana modal esperando un clic. Solo un mensajito discreto que aparece, informa y desaparece.

## ✨ Cómo funciona

El corazón del ejemplo son tres objetos no visuales que podéis **extraer e integrar directamente en cualquier aplicación**:

- **`n_cst_systemtray`** → el objeto principal que dialoga con el área de notificaciones / bandeja del sistema y construye el *toast*.
- **`n_cst_systemtray_shared`** → datos compartidos entre instancias/hilos.
- **`n_cst_systemtray_callback`** → recibe los *callbacks* del sistema (clics, cierres…).

Y aquí viene lo interesante de verdad: se ha usado la técnica de **MultiThread** para crear un **hilo secundario** que se encarga de **cerrar las notificaciones** pasado su tiempo de vida, **sin afectar al flujo** de la aplicación principal. Es decir, mientras el usuario sigue trabajando, hay un hilo aparte vigilando y limpiando los avisos. Una forma muy elegante de no congelar la UI.

En la ventana `w_main` tenéis el ejemplo de uso para disparar las notificaciones y ver el resultado.

## 🛠️ Requisitos

- **PowerBuilder 2025** (compilado con el Runtime `25.0.0.3711`).
- **Windows 10 u 11** (las *toast notifications* son nativas del sistema).
- Sin dependencias externas: clonáis y compila.

## ▶️ Cómo probarlo

1. Clona el repositorio (viene **en modo solución**).
2. Abre `toast.pbsln` desde el IDE de PowerBuilder.
3. Compila y ejecuta `w_main` (o lanza el `toast.exe` que ya viene generado).
4. Dispara una notificación y observa cómo aparece el *toast* y cómo se cierra solo gracias al hilo secundario.

> 💡 Para reutilizarlo en lo tuyo, basta con llevarte los objetos `n_cst_systemtray`, `n_cst_systemtray_shared` y `n_cst_systemtray_callback` a tu aplicación.

## 🔗 Repo PowerBuilder

Tenéis el ejemplo publicado en modo solución aquí:
👉 <https://github.com/rasanfe/toast>

## 🙌 Créditos

Este ejemplo está **extraído y adaptado** de la utilidad de notificaciones de las **STD Foundation Classes — Windows Notification Utility**:
- 📦 <https://sourceforge.net/projects/stdfndclass/files/Applications/PowerBuilder/Notification/>

Todo el mérito de la base original es de sus autores; yo me he limitado a empaquetarlo como ejemplo didáctico y explicar el truco del MultiThread.

---

> ¡Nos vemos en el próximo artículo! Y recuerda: en PowerBuilder, los límites solo están en nuestra imaginación. 🚀

📨 **Blog:** <https://rsrsystem.blogspot.com/>
