import uuid

class Barbero:
    def __init__(self, sucursal_id, nombre, horario_semanal, barbero_id=None):
        if not sucursal_id:
            raise ValueError("El ID de sucursal es obligatorio")
        if not nombre:
            raise ValueError("El nombre es obligatorio")
        
        self.sucursal_id = sucursal_id
        self.id = barbero_id if barbero_id else str(uuid.uuid4())
        self.nombre = nombre
        # horario_semanal esperamos que sea un dict: {'Lunes': '09:00-18:00', ...}
        self.horario_semanal = horario_semanal 

    def to_dict(self):
        return {
            'PK': f"SUCURSAL#{self.sucursal_id}",
            'SK': f"BARBERO#{self.id}",
            'Tipo': 'BARBERO',
            'ID': self.id,
            'SucursalID': self.sucursal_id,
            'Nombre': self.nombre,
            'HorarioSemanal': self.horario_semanal
        }