from domain.turno import Turno
from adapters.api.postgres_repository import PostgresRepository
from datetime import datetime

class CrearTurnoUseCase:
    
    def ejecutar(self, datos):
        repository = PostgresRepository()

        sucursal_id = datos.get('sucursal_id')
        cliente_id = datos.get('cliente_id')
        staff_id = datos.get('staff_id')
        servicio_id = datos.get('servicio_id')
        fecha_hora_inicio = datos.get('fecha_hora_inicio')
        precio_congelado = datos.get('precio_congelado')

        # Convertir string a datetime si es necesario
        if isinstance(fecha_hora_inicio, str):
            fecha_hora_inicio = datetime.fromisoformat(fecha_hora_inicio)

        nuevo_turno = Turno(
            sucursal_id=sucursal_id,
            cliente_id=cliente_id,
            staff_id=staff_id,
            servicio_id=servicio_id,
            fecha_hora_inicio=fecha_hora_inicio,
            precio_congelado=precio_congelado
        )
        
        repository.guardar(nuevo_turno.to_dict())
        
        return nuevo_turno.to_dict()
