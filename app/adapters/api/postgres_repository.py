import pg8000.native
import os
import json

class PostgresRepository:
    def __init__(self):
        # 1. Conexión a la base de datos usando las variables de entorno
        print(f"Conectando a {os.environ['DB_HOST']}...")
        self.conn = pg8000.native.Connection(
            user=os.environ['DB_USER'],
            password=os.environ['DB_PASSWORD'], # Ojo: asegúrate que la variable se llame igual en main.tf
            host=os.environ['DB_HOST'],
            database=os.environ['DB_NAME']
        )
        
        # 2. ESTA ES LA CLAVE: 
        # Cada vez que instanciamos el repositorio, verificamos si las tablas existen.
        self._inicializar_tablas()

    def _inicializar_tablas(self):
        """
        Crea las tablas necesarias si no existen.
        En producción real, esto se hace con migraciones (Alembic), 
        pero para el MVP lo hacemos aquí.
        """
        
        # Tabla BARBEROS
        # Usamos JSONB para el horario porque es una estructura flexible
        sql_barberos = """
        CREATE TABLE IF NOT EXISTS barberos (
            id TEXT PRIMARY KEY,
            sucursal_id TEXT NOT NULL,
            nombre TEXT NOT NULL,
            horario_semanal JSONB
        );
        """
        self.conn.run(sql_barberos)
        
        # (A futuro aquí agregaremos la tabla TURNOS)

    def guardar(self, entidad):
        """
        Guarda una entidad (diccionario) en la base de datos.
        """
        try:
            # Detectamos si es un Barbero por sus campos
            if 'HorarioSemanal' in entidad: 
                print(f"Guardando barbero: {entidad['Nombre']}")
                
                sql = """
                INSERT INTO barberos (id, sucursal_id, nombre, horario_semanal)
                VALUES (:id, :sucursal_id, :nombre, :horario_semanal)
                """
                
                self.conn.run(sql, 
                    id=entidad['ID'],
                    sucursal_id=entidad['SucursalID'],
                    nombre=entidad['Nombre'],
                    # Postgres necesita que el dict se convierta a string JSON
                    horario_semanal=json.dumps(entidad['HorarioSemanal'])
                )
                return True
                
        except Exception as e:
            print(f"Error Base de Datos: {e}")
            raise e