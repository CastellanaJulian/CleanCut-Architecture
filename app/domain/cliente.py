import uuid
from datetime import datetime

class Cliente:
    def __init__(self, tenant_id, telefono, nombre, email=None, staff_preferido_id=None, notas_internas=None, cliente_id=None):
        if not tenant_id:
            raise ValueError("El ID del tenant es obligatorio")
        if not telefono:
            raise ValueError("El teléfono es obligatorio (identificador principal)")
        if not nombre:
            raise ValueError("El nombre es obligatorio")
        
        self.id = cliente_id if cliente_id else str(uuid.uuid4())
        self.tenant_id = tenant_id
        self.telefono = telefono
        self.nombre = nombre
        self.email = email
        self.staff_preferido_id = staff_preferido_id
        self.notas_internas = notas_internas
        self.creado_en = datetime.now()

    def to_dict(self):
        return {
            'id': self.id,
            'tenantId': self.tenant_id,
            'telefono': self.telefono,
            'nombre': self.nombre,
            'email': self.email,
            'staffPreferidoId': self.staff_preferido_id,
            'notasInternas': self.notas_internas,
            'creadoEn': self.creado_en.isoformat()
        }
