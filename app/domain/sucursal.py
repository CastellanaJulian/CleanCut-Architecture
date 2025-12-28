import uuid

class Sucursal:
    def __init__(self, tenant_id, nombre, direccion, timezone="America/Argentina/Buenos_Aires", sucursal_id=None):
        if not tenant_id:
            raise ValueError("El ID del tenant es obligatorio")
        if not nombre:
            raise ValueError("El nombre de la sucursal es obligatorio")
        if not direccion:
            raise ValueError("La dirección es obligatoria")
        
        self.id = sucursal_id if sucursal_id else str(uuid.uuid4())
        self.tenant_id = tenant_id
        self.nombre = nombre
        self.direccion = direccion
        self.timezone = timezone

    def to_dict(self):
        return {
            'id': self.id,
            'tenantId': self.tenant_id,
            'nombre': self.nombre,
            'direccion': self.direccion,
            'timezone': self.timezone
        }
