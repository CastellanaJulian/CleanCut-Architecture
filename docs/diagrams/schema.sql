CREATE TYPE "estado_turno" AS ENUM (
  'pendiente',
  'confirmado',
  'cancelado',
  'completado',
  'no_show'
);

CREATE TABLE "tenants" (
  "id" varchar PRIMARY KEY,
  "nombre" varchar,
  "email_contacto" varchar,
  "plan_suscripcion" varchar DEFAULT 'free',
  "creado_en" timestamp
);

CREATE TABLE "sucursales" (
  "id" varchar PRIMARY KEY,
  "tenant_id" varchar,
  "nombre" varchar,
  "direccion" varchar,
  "timezone" varchar DEFAULT 'America/Argentina/Buenos_Aires'
);

CREATE TABLE "staff" (
  "id" varchar PRIMARY KEY,
  "sucursal_id" varchar,
  "nombre" varchar,
  "rol" varchar DEFAULT 'staff',
  "disponibilidad_semanal" jsonb,
  "activo" boolean DEFAULT true
);

CREATE TABLE "servicios" (
  "id" varchar PRIMARY KEY,
  "sucursal_id" varchar,
  "nombre" varchar,
  "duracion_minutos" int,
  "precio" decimal(10,2),
  "moneda" varchar DEFAULT 'ARS'
);

CREATE TABLE "staff_servicios" (
  "staff_id" varchar,
  "servicio_id" varchar,
  "primary" key(staff_id,servicio_id)
);

CREATE TABLE "clientes" (
  "id" varchar PRIMARY KEY,
  "tenant_id" varchar,
  "telefono" varchar NOT NULL,
  "email" varchar,
  "nombre" varchar,
  "staff_preferido_id" varchar,
  "notas_internas" text,
  "creado_en" timestamp
);

CREATE TABLE "turnos" (
  "id" varchar PRIMARY KEY,
  "sucursal_id" varchar,
  "cliente_id" varchar,
  "staff_id" varchar,
  "servicio_id" varchar,
  "fecha_hora_inicio" timestamp,
  "estado" estado_turno DEFAULT 'pendiente',
  "precio_congelado" decimal(10,2)
);

CREATE TABLE "pagos" (
  "id" varchar PRIMARY KEY,
  "turno_id" varchar,
  "monto" decimal(10,2),
  "metodo" varchar,
  "estado" varchar DEFAULT 'pagado',
  "fecha_pago" timestamp
);

CREATE UNIQUE INDEX ON "clientes" ("tenant_id", "telefono");

COMMENT ON COLUMN "tenants"."id" IS 'Ej: ''Barberia Hnos''';

COMMENT ON COLUMN "sucursales"."nombre" IS 'Ej: Sucursal Centro';

COMMENT ON COLUMN "clientes"."telefono" IS 'ID Principal del usuario (WhatsApp)';

COMMENT ON COLUMN "clientes"."email" IS 'Opcional, solo para comprobantes';

COMMENT ON COLUMN "pagos"."metodo" IS 'efectivo, transferencia, mp';

ALTER TABLE "sucursales" ADD FOREIGN KEY ("tenant_id") REFERENCES "tenants" ("id");

ALTER TABLE "staff" ADD FOREIGN KEY ("sucursal_id") REFERENCES "sucursales" ("id");

ALTER TABLE "servicios" ADD FOREIGN KEY ("sucursal_id") REFERENCES "sucursales" ("id");

ALTER TABLE "staff_servicios" ADD FOREIGN KEY ("staff_id") REFERENCES "staff" ("id");

ALTER TABLE "staff_servicios" ADD FOREIGN KEY ("servicio_id") REFERENCES "servicios" ("id");

ALTER TABLE "clientes" ADD FOREIGN KEY ("tenant_id") REFERENCES "tenants" ("id");

ALTER TABLE "clientes" ADD FOREIGN KEY ("staff_preferido_id") REFERENCES "staff" ("id");

ALTER TABLE "turnos" ADD FOREIGN KEY ("sucursal_id") REFERENCES "sucursales" ("id");

ALTER TABLE "turnos" ADD FOREIGN KEY ("cliente_id") REFERENCES "clientes" ("id");

ALTER TABLE "turnos" ADD FOREIGN KEY ("staff_id") REFERENCES "staff" ("id");

ALTER TABLE "turnos" ADD FOREIGN KEY ("servicio_id") REFERENCES "servicios" ("id");

ALTER TABLE "pagos" ADD FOREIGN KEY ("turno_id") REFERENCES "turnos" ("id");
