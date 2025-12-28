# Documentación de Arquitectura - Sistema de Turnos SaaS

## 1. Modelo de Datos (Entity Relationship)

El sistema utiliza una arquitectura **Multi-Tenant** donde los datos de cada negocio están lógicamente aislados, aunque residen en la misma base de datos.

![Diagrama ER](diagramas/dbdiagram.png)

### Decisiones de Diseño Clave

1.  **Identificación por Celular:**
    * Se utiliza el `telefono` como identificador principal del cliente para reducir la fricción en la reserva (Guest Checkout).
    * **Restricción:** `UNIQUE(tenant_id, telefono)`. Un número de teléfono es único dentro del contexto de un negocio, pero el mismo número puede existir en distintos negocios (Tenants).

2.  **Aislamiento de Clientes:**
    * Los clientes pertenecen al `Tenant` (Dueño del negocio), no a la `Sucursal`. Esto permite que una cadena de barberías reconozca al cliente en cualquiera de sus locales.

3.  **Manejo de Pagos:**
    * La tabla `pagos` está desacoplada de `turnos` para permitir pagos parciales (ej: señas) y múltiples métodos de pago para una sola reserva.

## 2. Tecnologías

* **Base de Datos:** PostgreSQL
* **Infraestructura:** AWS Lambda + API Gateway (Serverless)
* **IaC:** Terraform