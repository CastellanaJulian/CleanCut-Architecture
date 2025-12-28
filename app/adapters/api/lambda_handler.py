import json
from application.crear_tenant import CrearTenantUseCase
from application.crear_sucursal import CrearSucursalUseCase
from application.crear_staff import CrearStaffUseCase
from application.crear_servicio import CrearServicioUseCase
from application.crear_cliente import CrearClienteUseCase
from application.crear_turno import CrearTurnoUseCase
from application.crear_pago import CrearPagoUseCase

# Router: Tabla de rutas mapeadas a casos de uso
RUTAS = {
    '/tenants': {
        'POST': CrearTenantUseCase,
    },
    '/sucursales': {
        'POST': CrearSucursalUseCase,
    },
    '/staff': {
        'POST': CrearStaffUseCase,
    },
    '/servicios': {
        'POST': CrearServicioUseCase,
    },
    '/clientes': {
        'POST': CrearClienteUseCase,
    },
    '/turnos': {
        'POST': CrearTurnoUseCase,
    },
    '/pagos': {
        'POST': CrearPagoUseCase,
    },
}

def lambda_handler(event, context):
    print("Recibido:", event)
    
    path = event.get('path', '/')
    http_method = event.get('httpMethod', 'GET')
    
    body = {}
    if 'body' in event and event['body']:
        body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']

    try:
        # Validar si la ruta existe
        if path not in RUTAS:
            return response(404, {"error": f"Ruta no encontrada: {path}"})
        
        # Validar si el método existe para esa ruta
        if http_method not in RUTAS[path]:
            return response(405, {"error": f"Método {http_method} no permitido para {path}"})
        
        # Obtener el caso de uso correspondiente
        use_case_class = RUTAS[path][http_method]
        use_case = use_case_class()
        resultado = use_case.ejecutar(body)
        
        return response(201, {"message": "Operación exitosa", "datos": resultado})

    except Exception as e:
        print(f"Error: {e}")
        return response(500, {"error": str(e)})

def response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET,POST,PUT,DELETE,PATCH,OPTIONS"
        },
        "body": json.dumps(body)
    }
