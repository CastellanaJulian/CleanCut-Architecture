import uuid
from datetime import datetime
from enum import Enum

class EstadoPago(Enum):
    PENDIENTE = "pendiente"
    PAGADO = "pagado"
    CANCELADO = "cancelado"

class Pago:
    def __init__(self, turno_id, monto, metodo, estado=EstadoPago.PENDIENTE, pago_id=None):
        if not turno_id:
            raise ValueError("El ID del turno es obligatorio")
        if monto <= 0:
            raise ValueError("El monto debe ser mayor a 0")
        if not metodo:
            raise ValueError("El método de pago es obligatorio")
        
        self.id = pago_id if pago_id else str(uuid.uuid4())
        self.turno_id = turno_id
        self.monto = monto
        self.metodo = metodo
        self.estado = estado if isinstance(estado, EstadoPago) else EstadoPago(estado)
        self.fecha_pago = datetime.now()

    def cambiar_estado(self, nuevo_estado):
        """Cambia el estado del pago"""
        if isinstance(nuevo_estado, str):
            nuevo_estado = EstadoPago(nuevo_estado)
        self.estado = nuevo_estado

    def to_dict(self):
        return {
            'id': self.id,
            'turnoId': self.turno_id,
            'monto': float(self.monto),
            'metodo': self.metodo,
            'estado': self.estado.value,
            'fechaPago': self.fecha_pago.isoformat()
        }
