#!/bin/bash

# PP5 DevOps Pipeline Script
# Automatiza el proceso completo de CI/CD
set -e
# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
# Función para logging
log() {
echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}
error() {
echo -e "${RED}[ERROR] $1${NC}" >&2
exit 1
}
warn() {
echo -e "${YELLOW}[WARN] $1${NC}"
}
# Variables
APP_NAME="pp5-app"
VERSION="${1:-0.1.1}"
REGISTRY="localhost:5000"
CONTAINER_NAME="${APP_NAME}-container"
log "🚀 Iniciando Pipeline DevOps para $APP_NAME:$VERSION"
# Paso 1: Limpiar contenedores anteriores

log "🧹 Limpiando contenedores anteriores..."
docker rm -f $CONTAINER_NAME 2>/dev/null || true
# Paso 2: Verificar código con ESLint
log "🔍 Ejecutando ESLint..."
npm run lint || error "ESLint falló"
# Paso 3: Ejecutar pruebas
log "🧪 Ejecutando pruebas unitarias..."
npm test || error "Las pruebas fallaron"
# Paso 4: Construir imagen Docker
log "️ Construyendo imagen Docker..."
docker build -t $APP_NAME:$VERSION . || error "Build de Docker falló"
# Paso 5: Etiquetar para registro
log "️ Etiquetando imagen..."
docker tag $APP_NAME:$VERSION $REGISTRY/$APP_NAME:$VERSION
# Paso 6: Subir a registro
log "📤 Subiendo imagen al registro..."
docker push $REGISTRY/$APP_NAME:$VERSION || error "Push al registro falló"
# Paso 7: Desplegar contenedor
log "🚢 Desplegando aplicación..."
docker run -d -p 3000:3000 --name $CONTAINER_NAME \
	$REGISTRY/$APP_NAME:$VERSION || error "Despliegue falló"
# Paso 8: Verificar despliegue
log "✅ Verificando despliegue..."
sleep 5
# Verificar que el contenedor está corriendo
if ! docker ps | grep -q $CONTAINER_NAME; then

error "El contenedor no está ejecutándose"
fi
# Verificar endpoint de salud
if ! curl -sf http://localhost:3000/healthz > /dev/null; then
error "Healthcheck falló"
fi
log "🎉 Pipeline completado exitosamente!"
log "📊 Aplicación desplegada en: http://localhost:3000"
log "🏥 Healthcheck: http://localhost:3000/healthz"
# Mostrar información del contenedor
log "📋 Información del despliegue:"
docker ps | grep $CONTAINER_NAME
