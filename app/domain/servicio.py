import uuid

class Servicio:
    def __init__(self, sucursal_id, nombre, duracion_minutos, precio, moneda="ARS", servicio_id=None):
        if not sucursal_id:
            raise ValueError("El ID de sucursal es obligatorio")
        if not nombre:
            raise ValueError("El nombre del servicio es obligatorio")
        if duracion_minutos <= 0:
            raise ValueError("La duración debe ser mayor a 0")
        if precio < 0:
            raise ValueError("El precio no puede ser negativo")
        
        self.id = servicio_id if servicio_id else str(uuid.uuid4())
        self.sucursal_id = sucursal_id
        self.nombre = nombre
        self.duracion_minutos = duracion_minutos
        self.precio = precio
        self.moneda = moneda

    def to_dict(self):
        return {
            'id': self.id,
            'sucursalId': self.sucursal_id,
            'nombre': self.nombre,
            'duracionMinutos': self.duracion_minutos,
            'precio': float(self.precio),
            'moneda': self.moneda
        }
