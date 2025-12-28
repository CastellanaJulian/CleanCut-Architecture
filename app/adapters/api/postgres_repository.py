import pg8000.native
import os
import json

class PostgresRepository:
    def __init__(self):
        # Conexión a la base de datos usando las variables de entorno
        print(f"Conectando a {os.environ['DB_HOST']}...")
        self.conn = pg8000.native.Connection(
            user=os.environ['DB_USER'],
            password=os.environ['DB_PASSWORD'],
            host=os.environ['DB_HOST'],
            database=os.environ['DB_NAME']
        )
        
        # Cada vez que instanciamos el repositorio, verificamos si las tablas existen.
        self._inicializar_tablas()

    def _inicializar_tablas(self):
        """
        Crea las tablas necesarias si no existen.
        En producción real, esto se hace con migraciones (Alembic), 
        pero para el MVP lo hacemos aquí.
        """
        
        # Tabla TENANTS
        sql_tenants = """
        CREATE TABLE IF NOT EXISTS tenants (
            id TEXT PRIMARY KEY,
            nombre TEXT NOT NULL,
            email_contacto TEXT NOT NULL,
            plan_suscripcion TEXT DEFAULT 'free',
            creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        """
        self.conn.run(sql_tenants)
        
        # Tabla SUCURSALES
        sql_sucursales = """
        CREATE TABLE IF NOT EXISTS sucursales (
            id TEXT PRIMARY KEY,
            tenant_id TEXT NOT NULL REFERENCES tenants(id),
            nombre TEXT NOT NULL,
            direccion TEXT NOT NULL,
            timezone TEXT DEFAULT 'America/Argentina/Buenos_Aires'
        );
        """
        self.conn.run(sql_sucursales)
        
        # Tabla STAFF
        sql_staff = """
        CREATE TABLE IF NOT EXISTS staff (
            id TEXT PRIMARY KEY,
            sucursal_id TEXT NOT NULL REFERENCES sucursales(id),
            nombre TEXT NOT NULL,
            disponibilidad_semanal JSONB,
            activo BOOLEAN DEFAULT true
        );
        """
        self.conn.run(sql_staff)
        
        # Tabla SERVICIOS
        sql_servicios = """
        CREATE TABLE IF NOT EXISTS servicios (
            id TEXT PRIMARY KEY,
            sucursal_id TEXT NOT NULL REFERENCES sucursales(id),
            nombre TEXT NOT NULL,
            duracion_minutos INTEGER NOT NULL,
            precio DECIMAL(10,2) NOT NULL,
            moneda TEXT DEFAULT 'ARS'
        );
        """
        self.conn.run(sql_servicios)
        
        # Tabla CLIENTES
        sql_clientes = """
        CREATE TABLE IF NOT EXISTS clientes (
            id TEXT PRIMARY KEY,
            tenant_id TEXT NOT NULL REFERENCES tenants(id),
            telefono TEXT NOT NULL,
            email TEXT,
            nombre TEXT NOT NULL,
            staff_preferido_id TEXT REFERENCES staff(id),
            notas_internas TEXT,
            creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(tenant_id, telefono)
        );
        """
        self.conn.run(sql_clientes)
        
        # Tabla TURNOS
        sql_turnos = """
        CREATE TABLE IF NOT EXISTS turnos (
            id TEXT PRIMARY KEY,
            sucursal_id TEXT NOT NULL REFERENCES sucursales(id),
            cliente_id TEXT NOT NULL REFERENCES clientes(id),
            staff_id TEXT NOT NULL REFERENCES staff(id),
            servicio_id TEXT NOT NULL REFERENCES servicios(id),
            fecha_hora_inicio TIMESTAMP NOT NULL,
            estado TEXT DEFAULT 'pendiente',
            precio_congelado DECIMAL(10,2)
        );
        """
        self.conn.run(sql_turnos)
        
        # Tabla PAGOS
        sql_pagos = """
        CREATE TABLE IF NOT EXISTS pagos (
            id TEXT PRIMARY KEY,
            turno_id TEXT NOT NULL REFERENCES turnos(id),
            monto DECIMAL(10,2) NOT NULL,
            metodo TEXT NOT NULL,
            estado TEXT DEFAULT 'pagado',
            fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        """
        self.conn.run(sql_pagos)

    def guardar(self, entidad):
        """
        Guarda una entidad (diccionario) en la base de datos.
        Detecta el tipo de entidad por sus campos.
        """
        try:
            # TENANT
            if 'planSuscripcion' in entidad and 'emailContacto' in entidad:
                print(f"Guardando tenant: {entidad['nombre']}")
                sql = """
                INSERT INTO tenants (id, nombre, email_contacto, plan_suscripcion)
                VALUES (:id, :nombre, :email_contacto, :plan_suscripcion)
                """
                self.conn.run(sql,
                    id=entidad['id'],
                    nombre=entidad['nombre'],
                    email_contacto=entidad['emailContacto'],
                    plan_suscripcion=entidad['planSuscripcion']
                )
                return True
            
            # SUCURSAL
            elif 'tenantId' in entidad and 'direccion' in entidad and 'timezone' in entidad:
                print(f"Guardando sucursal: {entidad['nombre']}")
                sql = """
                INSERT INTO sucursales (id, tenant_id, nombre, direccion, timezone)
                VALUES (:id, :tenant_id, :nombre, :direccion, :timezone)
                """
                self.conn.run(sql,
                    id=entidad['id'],
                    tenant_id=entidad['tenantId'],
                    nombre=entidad['nombre'],
                    direccion=entidad['direccion'],
                    timezone=entidad['timezone']
                )
                return True
            
            # STAFF
            elif 'disponibilidadSemanal' in entidad and 'activo' in entidad:
                print(f"Guardando staff: {entidad['nombre']}")
                sql = """
                INSERT INTO staff (id, sucursal_id, nombre, disponibilidad_semanal, activo)
                VALUES (:id, :sucursal_id, :nombre, :disponibilidad_semanal, :activo)
                """
                self.conn.run(sql,
                    id=entidad['id'],
                    sucursal_id=entidad['sucursalId'],
                    nombre=entidad['nombre'],
                    disponibilidad_semanal=json.dumps(entidad['disponibilidadSemanal']),
                    activo=entidad['activo']
                )
                return True
            
            # SERVICIO
            elif 'duracionMinutos' in entidad and 'precio' in entidad:
                print(f"Guardando servicio: {entidad['nombre']}")
                sql = """
                INSERT INTO servicios (id, sucursal_id, nombre, duracion_minutos, precio, moneda)
                VALUES (:id, :sucursal_id, :nombre, :duracion_minutos, :precio, :moneda)
                """
                self.conn.run(sql,
                    id=entidad['id'],
                    sucursal_id=entidad['sucursalId'],
                    nombre=entidad['nombre'],
                    duracion_minutos=entidad['duracionMinutos'],
                    precio=entidad['precio'],
                    moneda=entidad['moneda']
                )
                return True
            
            # CLIENTE
            elif 'telefono' in entidad and 'tenantId' in entidad and 'notasInternas' in entidad:
                print(f"Guardando cliente: {entidad['nombre']}")
                sql = """
                INSERT INTO clientes (id, tenant_id, telefono, email, nombre, staff_preferido_id, notas_internas)
                VALUES (:id, :tenant_id, :telefono, :email, :nombre, :staff_preferido_id, :notas_internas)
                """
                self.conn.run(sql,
                    id=entidad['id'],
                    tenant_id=entidad['tenantId'],
                    telefono=entidad['telefono'],
                    email=entidad['email'],
                    nombre=entidad['nombre'],
                    staff_preferido_id=entidad['staffPreferidoId'],
                    notas_internas=entidad['notasInternas']
                )
                return True
            
            # TURNO
            elif 'fechaHoraInicio' in entidad and 'estado' in entidad:
                print(f"Guardando turno: {entidad['id']}")
                sql = """
                INSERT INTO turnos (id, sucursal_id, cliente_id, staff_id, servicio_id, fecha_hora_inicio, estado, precio_congelado)
                VALUES (:id, :sucursal_id, :cliente_id, :staff_id, :servicio_id, :fecha_hora_inicio, :estado, :precio_congelado)
                """
                self.conn.run(sql,
                    id=entidad['id'],
                    sucursal_id=entidad['sucursalId'],
                    cliente_id=entidad['clienteId'],
                    staff_id=entidad['staffId'],
                    servicio_id=entidad['servicioId'],
                    fecha_hora_inicio=entidad['fechaHoraInicio'],
                    estado=entidad['estado'],
                    precio_congelado=entidad['precioCongelado']
                )
                return True
            
            # PAGO
            elif 'turnoId' in entidad and 'metodo' in entidad:
                print(f"Guardando pago: {entidad['id']}")
                sql = """
                INSERT INTO pagos (id, turno_id, monto, metodo, estado)
                VALUES (:id, :turno_id, :monto, :metodo, :estado)
                """
                self.conn.run(sql,
                    id=entidad['id'],
                    turno_id=entidad['turnoId'],
                    monto=entidad['monto'],
                    metodo=entidad['metodo'],
                    estado=entidad['estado']
                )
                return True
            
            else:
                raise ValueError(f"Tipo de entidad no reconocido: {entidad}")
                
        except Exception as e:
            print(f"Error Base de Datos: {e}")
            raise e