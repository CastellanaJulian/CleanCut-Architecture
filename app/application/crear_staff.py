from domain.staff import Staff
from adapters.api.postgres_repository import PostgresRepository

class CrearStaffUseCase:
    
    def ejecutar(self, datos):
        # Instanciamos el repositorio aquí mismo (más limpio)
        repository = PostgresRepository()

        # Extraemos datos
        sucursal_id = datos.get('sucursal_id')
        nombre = datos.get('nombre')
        horario = datos.get('horario_semanal', {}) 

        # Instanciamos Dominio
        nuevo_staff = Staff(
            sucursal_id=sucursal_id,
            nombre=nombre,
            horario_semanal=horario
        )
        
        # Guardamos
        # IMPORTANTE: El PostgresRepository que creamos espera un Diccionario (JSON),
        # así que usamos .to_dict() antes de enviarlo.
        repository.guardar(nuevo_staff.to_dict())
        
        return nuevo_staff.to_dict()
