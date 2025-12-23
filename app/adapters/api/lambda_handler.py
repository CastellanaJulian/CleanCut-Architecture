import json

def lambda_handler(event, context):

    # Handler temporal para verificar que la infraestructura responde.
    
    # Imprimimos el evento en la consola
    print("Evento recibido en Lambda:", event)

    # Intentamos leer el cuerpo del mensaje
    body_recibido = "Nada"
    if 'body' in event and event['body']:
        body_recibido = event['body']

    # Respuesta para API Gateway
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "POST, GET, OPTIONS"
        },
        "body": json.dumps({
            "mensaje": "Infraestructura funcionando!",
            "recibi_esto": body_recibido
        })
    }