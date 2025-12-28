import uuid
from datetime import datetime

class Tenant:
    def __init__(self, nombre, email_contacto, plan_suscripcion="free", tenant_id=None):
        if not nombre:
            raise ValueError("El nombre del tenant es obligatorio")
        if not email_contacto:
            raise ValueError("El email de contacto es obligatorio")
        
        self.id = tenant_id if tenant_id else str(uuid.uuid4())
        self.nombre = nombre
        self.email_contacto = email_contacto
        self.plan_suscripcion = plan_suscripcion
        self.creado_en = datetime.now()

    def to_dict(self):
        return {
            'id': self.id,
            'nombre': self.nombre,
            'emailContacto': self.email_contacto,
            'planSuscripcion': self.plan_suscripcion,
            'creadoEn': self.creado_en.isoformat()
        }
