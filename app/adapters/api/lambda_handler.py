import json
from application.crear_barbero import CrearBarberoUseCase

def lambda_handler(event, context):
    print("Recibido:", event)
    
    # Detectamos la ruta y el método HTTP
    path = event.get('path', '/')
    http_method = event.get('httpMethod', 'GET')
    
    # Manejo de cuerpo de la petición
    body = {}
    if 'body' in event and event['body']:
        body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']

    try:
        # --- ROUTER ---
        
        # 1. Crear Barbero
        if path == '/barberos' and http_method == 'POST':
            use_case = CrearBarberoUseCase()
            resultado = use_case.ejecutar(body)
            return response(200, {"message": "Barbero creado", "datos": resultado})
            
        # 3. Ruta no encontrada
        else:
            return response(404, {"error": f"Ruta no encontrada: {path} {http_method}"})

    except Exception as e:
        print(f"Error: {e}")
        return response(500, {"error": str(e)})

def response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*", # CORS IMPORTANTE
            "Access-Control-Allow-Methods": "POST,OPTIONS"
        },
        "body": json.dumps(body)
    }