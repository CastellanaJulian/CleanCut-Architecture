from domain.sucursal import Sucursal
from adapters.api.postgres_repository import PostgresRepository

class CrearSucursalUseCase:
    
    def ejecutar(self, datos):
        repository = PostgresRepository()

        tenant_id = datos.get('tenant_id')
        nombre = datos.get('nombre')
        direccion = datos.get('direccion')
        timezone = datos.get('timezone', 'America/Argentina/Buenos_Aires')

        nueva_sucursal = Sucursal(
            tenant_id=tenant_id,
            nombre=nombre,
            direccion=direccion,
            timezone=timezone
        )
        
        repository.guardar(nueva_sucursal.to_dict())
        
        return nueva_sucursal.to_dict()
