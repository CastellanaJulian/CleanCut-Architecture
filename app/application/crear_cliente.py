from domain.cliente import Cliente
from adapters.api.postgres_repository import PostgresRepository

class CrearClienteUseCase:
    
    def ejecutar(self, datos):
        repository = PostgresRepository()

        tenant_id = datos.get('tenant_id')
        telefono = datos.get('telefono')
        nombre = datos.get('nombre')
        email = datos.get('email')
        staff_preferido_id = datos.get('staff_preferido_id')
        notas_internas = datos.get('notas_internas')

        nuevo_cliente = Cliente(
            tenant_id=tenant_id,
            telefono=telefono,
            nombre=nombre,
            email=email,
            staff_preferido_id=staff_preferido_id,
            notas_internas=notas_internas
        )
        
        repository.guardar(nuevo_cliente.to_dict())
        
        return nuevo_cliente.to_dict()
