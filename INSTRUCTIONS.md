# Contexto y Reglas del Proyecto

Este archivo define los estándares de codificación, arquitectura y reglas de negocio para el proyecto "SaaS de Turnos/Reservas".
Toda sugerencia de código generada por AI (Copilot) debe adherirse estrictamente a estas normas.

## 1. Visión del Proyecto
Sistema SaaS Multi-tenant para gestión de turnos y reservas (barberías, salones, consultorios).
- **Modelo:** B2B2C (Negocio -> Sucursales -> Clientes Finales).
- **Core:** Gestión de disponibilidad, reservas, clientes y pagos.

## 2. Estándares de Código y Estilo

El proyecto adhiere estrictamente al estándar **PEP 8** de Python.

### Convenciones de Nombres
- **Variables y Funciones:** `snake_case` (ej: `calcular_disponibilidad`, `cliente_id`, `fecha_inicio`).
- **Clases:** `PascalCase` (ej: `CrearTurnoUseCase`, `PostgresRepository`).
- **Constantes:** `UPPER_CASE` (ej: `MAX_INTENTOS`).
- **Archivos:** `snake_case` (ej: `crear_turno.py`, `postgres_repository.py`).
- **JSON/API:** Las respuestas hacia el frontend (JSON) deben transformarse a `camelCase` en los métodos `.to_dict()` o serializadores.
    - *Python:* `fecha_creacion` -> *JSON:* `fechaCreacion`.

### Idioma y Formato
- **Código:** Nombres de variables, métodos y clases en **Español**.
- **Comentarios:** En **Español**. Deben explicar el "por qué" de la lógica compleja, no el "qué".
- **Emojis:** Estrictamente **PROHIBIDOS** en comentarios, mensajes de commit y documentación. Mantener tono profesional.
- **Strings:** Preferir comillas dobles `"` para strings visibles.

### Commits
- Estructura: `Tipo: Descripción breve en español`
- Tipos permitidos: `Feat`, `Fix`, `Refactor`, `Docs`, `Infra`.
- Ejemplo: `Feat: Agrega validación de telefono único por tenant`

## 3. Arquitectura (Hexagonal / Clean Architecture)

El código vive en la carpeta `app/` y se divide en capas concéntricas. Respetar la dirección de las dependencias (de afuera hacia adentro).

### Estructura de Carpetas
- `domain/`: Entidades puras y reglas de negocio. Sin dependencias externas (no SQL, no AWS, no librerías raras).
- `application/`: Casos de uso. Orquestan la lógica. Importan del dominio y definen interfaces para repositorios.
- `adapters/`: Implementaciones técnicas (Infraestructura).
    - `api/`: Lambda handlers (`lambda_handler.py`).
    - `database/`: Implementación de repositorios (`postgres_repository.py`).

### Reglas de Importación (CRÍTICO)
Debido al empaquetado de AWS Lambda por Terraform, **NUNCA** usar el prefijo `app.` en los imports.
- **Incorrecto:** `from app.domain.cliente import Cliente`
- **Correcto:** `from domain.cliente import Cliente`

## 4. Stack Tecnológico

- **Lenguaje:** Python 3.9+
- **Infraestructura:** AWS Lambda, API Gateway, Terraform.
- **Base de Datos:** PostgreSQL.
- **Driver SQL:** `pg8000` (Driver nativo puro, sin dependencias de C).
- **Entorno Local:** Docker, Docker Compose, LocalStack.

## 5. Modelo de Datos (Reglas de Negocio)

### Multi-tenancy
- **Aislamiento Lógico:** Todo dato pertenece a un `tenant` (dueño del negocio).
- Las búsquedas siempre deben filtrar por `tenant_id` por seguridad.

### Identificación de Clientes (Guest Checkout)
- El identificador principal del cliente es su **Teléfono**.
- El Email es opcional (para comprobantes).
- **Restricción de Unicidad:** Un par `(tenant_id, telefono)` debe ser único. Un mismo teléfono puede existir en diferentes Tenants (negocios distintos), pero no duplicarse dentro del mismo.

### Entidades Principales
- **Tenants:** Dueños de la suscripción SaaS.
- **Sucursales:** Ubicaciones físicas asociadas a un Tenant.
- **Staff:** Empleados que brindan servicios en una Sucursal.
- **Servicios:** Catálogo de prestaciones (precios, duración).
- **Turnos:** La reserva central. Vincula Cliente, Staff y Servicio.
- **Pagos:** Entidad separada de Turnos para permitir pagos parciales y múltiples métodos.

## 6. Flujo de Trabajo (Makefile)

Utilizar `make` para operaciones comunes:
- `make deploy`: Empaqueta el código en una carpeta temporal, instala dependencias y despliega con Terraform (rápido).
- `make reset`: "Opción Nuclear". Destruye contenedores y volúmenes, y reconstruye todo desde cero (borra la DB).
- `make logs`: Muestra logs de Lambda y DB en tiempo real.