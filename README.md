📌 Descripción

Shoply es una aplicación móvil diseñada para simplificar la gestión de listas de compras. Permite a los usuarios crear, editar y compartir listas con la comunidad, asignar productos a mercados específicos y realizar un seguimiento del total de cada lista.

🚀 Características Principales

      📋 Creación de Listas: Los usuarios pueden crear y gestionar múltiples listas de compras.
      
      📦 Agregar Productos: Posibilidad de añadir productos con nombre, cantidad, precio y notas.
      
      🏪 Asociación con Mercados: Asigna mercados específicos a tus listas de compras.
      
      🔎 Búsqueda de Productos: Encuentra productos en un catálogo predefinido o agrega los tuyos propios.
      
      💬 Comunidad: Comparte listas con otros usuarios y explora listas públicas.
      
      📊 Ordenación y Filtros: Ordena productos por precio y filtra listas según el mercado.
      
      🔔 Notificaciones: Mantente al tanto de cambios en tus listas.

🛠️ Instalación

    # Prerrequisitos
        -Tener Flutter instalado (guía de instalación).
        -Tener Firebase configurado en tu proyecto.
        -Pasos para Clonar e Instalar.
    
    # Clonar el repositorio
        git clone https://github.com/tu_usuario/shoply.git
        cd shoply
    
    # Instalar dependencias
        flutter pub get
    
    # Ejecutar la aplicación
        dart run
        flutter run

🏗️ Arquitectura y Tecnologías

    Shoply está desarrollado utilizando las siguientes tecnologías:
    
    Flutter: Para la interfaz de usuario.
    Firebase Firestore: Base de datos en la nube para almacenamiento de listas, usuarios y comunidad.
    Provider: Para la gestión del estado.
    Cloud Functions: Para tareas automatizadas y validaciones.

📌 Configuración de Firebase

    Crear un proyecto en Firebase en la consola de Firebase.
    Agregar Firebase a tu app siguiendo la documentación oficial.
    Habilitar Firestore Database y configurar las reglas de seguridad.
    Descargar y agregar el archivo google-services.json a la carpeta android/app/.
    Habilitar autenticación en Firebase.

📖 Uso

    Inicia sesión o usa la app como invitado.
    Crea una nueva lista de compras y agrégale productos.
    Asigna un mercado si lo deseas.
    Comparte la lista con la comunidad si es pública.
    Explora listas de otros usuarios en la comunidad.
    Edita o elimina listas según sea necesario.
