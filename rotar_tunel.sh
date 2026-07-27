#!/bin/bash
# =================================================================
# CompuMar Core - Sistema de Rotación Preventiva en Caliente (Red MAR)
# =================================================================

# Configuración idéntica a su matriz inicial
TOKEN="CompuMarCore2026!#" # [cite: 21]
HOST_RECEPTOR="https://compumarvillarrica.com/redmar-matrix.php" # [cite: 22]
STATE_FILE="/tmp/mar_pool_actual.conf"

TUNEL_A_ROTAR=$1

if [[ "$TUNEL_A_ROTAR" != "A" && "$TUNEL_A_ROTAR" != "B" && "$TUNEL_A_ROTAR" != "C" ]]; then
    echo "Uso correcto: ./rotar_tunel.sh [A|B|C]"
    exit 1
fi

# Cargar las URLs actuales del archivo de estado local
if [ -f "$STATE_FILE" ]; then
    source "$STATE_FILE"
else
    echo "Error: No se encontró el estado inicial de la matriz."
    exit 1
fi

echo "Iniciando rotación estratégica del Túnel $TUNEL_A_ROTAR..."

# 1. Identificar y terminar de forma limpia el proceso del túnel viejo
LOG_VIEJO="/tmp/mar_tunel_${TUNEL_A_ROTAR}.log"
if [ -f "$LOG_VIEJO" ]; then
    # Buscamos el PID que está escribiendo en ese log específico
    PID_VIEJO=$(lsof -t "$LOG_VIEJO" 2>/dev/null)
    if [ ! -z "$PID_VIEJO" ]; then
        kill -9 "$PID_VIEJO"
        echo "Túnel viejo $TUNEL_A_ROTAR (PID: $PID_VIEJO) desconectado."
    fi
    rm "$LOG_VIEJO"
fi

# 2. Levantar el nuevo túnel efímero apuntando al nodo Docker
cloudflared tunnel --url http://172.17.164.109:20261 > "$LOG_VIEJO" 2>&1 & # [cite: 26]
sleep 5

# 3. Extraer la nueva URL asignada por Cloudflare
NUEVA_URL=$(grep -oE 'https://[a-zA-Z0-9-]+\.trycloudflare\.com' "$LOG_VIEJO" | head -n 1) # [cite: 28]

if [ -z "$NUEVA_URL" ]; then
    echo "Catástrofe: Cloudflare no asignó una URL efímera válida."
    exit 1
fi

# 4. Actualizar la variable correspondiente manteniendo las otras dos intactas
if [ "$TUNEL_A_ROTAR" == "A" ]; then URL_A=$NUEVA_URL; fi
if [ "$TUNEL_A_ROTAR" == "B" ]; then URL_B=$NUEVA_URL; fi
if [ "$TUNEL_A_ROTAR" == "C" ]; then URL_C=$NUEVA_URL; fi

# 5. Guardar el nuevo estado localmente para la próxima rotación
echo "URL_A=\"$URL_A\"" > "$STATE_FILE"
echo "URL_B=\"$URL_B\"" >> "$STATE_FILE"
echo "URL_C=\"$URL_C\"" >> "$STATE_FILE"

# 6. Sincronizar inmediatamente con el cPanel
curl -s -X POST $HOST_RECEPTOR \ # 
  -d "token=$TOKEN" \ # [cite: 37]
  -d "pool_update=1" \ # [cite: 38]
  -d "url_a=$URL_A" \ # [cite: 39]
  -d "url_b=$URL_B" \ # [cite: 40]
  -d "url_c=$URL_C" # [cite: 41]

echo "Rotación exitosa. Matriz sincronizada en cPanel para el Túnel $TUNEL_A_ROTAR -> $NUEVA_URL"