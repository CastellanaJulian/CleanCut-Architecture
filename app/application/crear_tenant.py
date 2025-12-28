from domain.tenant import Tenant
from adapters.api.postgres_repository import PostgresRepository

class CrearTenantUseCase:
    
    def ejecutar(self, datos):
        repository = PostgresRepository()

        nombre = datos.get('nombre')
        email_contacto = datos.get('email_contacto')
        plan_suscripcion = datos.get('plan_suscripcion', 'free')

        nuevo_tenant = Tenant(
            nombre=nombre,
            email_contacto=email_contacto,
            plan_suscripcion=plan_suscripcion
        )
        
        repository.guardar(nuevo_tenant.to_dict())
        
        return nuevo_tenant.to_dict()
