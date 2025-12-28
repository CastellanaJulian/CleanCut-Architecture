from domain.servicio import Servicio
from adapters.api.postgres_repository import PostgresRepository

class CrearServicioUseCase:
    
    def ejecutar(self, datos):
        repository = PostgresRepository()

        sucursal_id = datos.get('sucursal_id')
        nombre = datos.get('nombre')
        duracion_minutos = datos.get('duracion_minutos')
        precio = datos.get('precio')
        moneda = datos.get('moneda', 'ARS')

        nuevo_servicio = Servicio(
            sucursal_id=sucursal_id,
            nombre=nombre,
            duracion_minutos=duracion_minutos,
            precio=precio,
            moneda=moneda
        )
        
        repository.guardar(nuevo_servicio.to_dict())
        
        return nuevo_servicio.to_dict()
