import uuid

class Staff:
    def __init__(self, sucursal_id, nombre, disponibilidad_semanal=None, activo=True, staff_id=None):
        if not sucursal_id:
            raise ValueError("El ID de sucursal es obligatorio")
        if not nombre:
            raise ValueError("El nombre es obligatorio")
        
        self.id = staff_id if staff_id else str(uuid.uuid4())
        self.sucursal_id = sucursal_id
        self.nombre = nombre
        # disponibilidad_semanal esperamos que sea un dict: {'Lunes': '09:00-18:00', ...}
        self.disponibilidad_semanal = disponibilidad_semanal or {}
        self.activo = activo

    def to_dict(self):
        return {
            'id': self.id,
            'sucursalId': self.sucursal_id,
            'nombre': self.nombre,
            'disponibilidadSemanal': self.disponibilidad_semanal,
            'activo': self.activo
        }
