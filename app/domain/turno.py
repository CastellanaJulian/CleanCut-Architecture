import uuid
from datetime import datetime
from enum import Enum

class EstadoTurno(Enum):
    PENDIENTE = "pendiente"
    CONFIRMADO = "confirmado"
    CANCELADO = "cancelado"
    COMPLETADO = "completado"
    NO_SHOW = "no_show"

class Turno:
    def __init__(self, sucursal_id, cliente_id, staff_id, servicio_id, fecha_hora_inicio, 
                 estado=EstadoTurno.PENDIENTE, precio_congelado=None, turno_id=None):
        if not sucursal_id:
            raise ValueError("El ID de sucursal es obligatorio")
        if not cliente_id:
            raise ValueError("El ID de cliente es obligatorio")
        if not staff_id:
            raise ValueError("El ID de staff es obligatorio")
        if not servicio_id:
            raise ValueError("El ID de servicio es obligatorio")
        if not fecha_hora_inicio:
            raise ValueError("La fecha y hora de inicio es obligatoria")
        
        self.id = turno_id if turno_id else str(uuid.uuid4())
        self.sucursal_id = sucursal_id
        self.cliente_id = cliente_id
        self.staff_id = staff_id
        self.servicio_id = servicio_id
        self.fecha_hora_inicio = fecha_hora_inicio
        self.estado = estado if isinstance(estado, EstadoTurno) else EstadoTurno(estado)
        self.precio_congelado = precio_congelado

    def cambiar_estado(self, nuevo_estado):
        """Cambia el estado del turno"""
        if isinstance(nuevo_estado, str):
            nuevo_estado = EstadoTurno(nuevo_estado)
        self.estado = nuevo_estado

    def to_dict(self):
        return {
            'id': self.id,
            'sucursalId': self.sucursal_id,
            'clienteId': self.cliente_id,
            'staffId': self.staff_id,
            'servicioId': self.servicio_id,
            'fechaHoraInicio': self.fecha_hora_inicio.isoformat() if isinstance(self.fecha_hora_inicio, datetime) else self.fecha_hora_inicio,
            'estado': self.estado.value,
            'precioCongelado': float(self.precio_congelado) if self.precio_congelado else None
        }
