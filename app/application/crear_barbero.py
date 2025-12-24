from domain.barbero import Barbero
from adapters.api.postgres_repository import PostgresRepository

class CrearBarberoUseCase:
    
    def ejecutar(self, datos):
        # 2. Instanciamos el repositorio aquí mismo (más limpio)
        repository = PostgresRepository()

        # Extraemos datos
        sucursal_id = datos.get('sucursal_id')
        nombre = datos.get('nombre')
        horario = datos.get('horario_semanal', {}) 

        # Instanciamos Dominio
        nuevo_barbero = Barbero(
            sucursal_id=sucursal_id,
            nombre=nombre,
            horario_semanal=horario
        )
        
        # 3. Guardamos
        # IMPORTANTE: El PostgresRepository que creamos espera un Diccionario (JSON),
        # así que usamos .to_dict() antes de enviarlo.
        repository.guardar(nuevo_barbero.to_dict())
        
        return nuevo_barbero.to_dict()