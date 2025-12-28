from domain.pago import Pago
from adapters.api.postgres_repository import PostgresRepository

class CrearPagoUseCase:
    
    def ejecutar(self, datos):
        repository = PostgresRepository()

        turno_id = datos.get('turno_id')
        monto = datos.get('monto')
        metodo = datos.get('metodo')
        estado = datos.get('estado', 'pagado')

        nuevo_pago = Pago(
            turno_id=turno_id,
            monto=monto,
            metodo=metodo,
            estado=estado
        )
        
        repository.guardar(nuevo_pago.to_dict())
        
        return nuevo_pago.to_dict()
