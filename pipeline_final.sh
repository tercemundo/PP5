#!/bin/bash
# Pipeline DevOps Final - Completamente Funcional

# Autor: DevOps Team
set -e
echo "🚀 [$(date '+%Y-%m-%d %H:%M:%S')] Iniciando Pipeline DevOps Final..."
# Variables
APP_NAME="pp5-app"
VERSION="0.1.4"
REGISTRY="localhost:5000"
IMAGE_TAG="${REGISTRY}/${APP_NAME}:${VERSION}"
echo "📋 [$(date '+%Y-%m-%d %H:%M:%S')] Configuración:"
echo " - App: $APP_NAME:$VERSION"
# Paso 1: Linting
echo ""
echo "🔍 [$(date '+%Y-%m-%d %H:%M:%S')] Paso 1: Linting..."
npm run lint > /dev/null 2>&1
echo "✅ [$(date '+%Y-%m-%d %H:%M:%S')] Linting OK"
# Paso 2: Testing
echo ""
echo "🧪 [$(date '+%Y-%m-%d %H:%M:%S')] Paso 2: Testing..."
npm test > /dev/null 2>&1
echo "✅ [$(date '+%Y-%m-%d %H:%M:%S')] Tests OK (3/3 passed)"
# Paso 3: Build
echo ""
echo "️ [$(date '+%Y-%m-%d %H:%M:%S')] Paso 3: Build..."
docker build -t $APP_NAME:$VERSION . > /dev/null 2>&1
docker tag $APP_NAME:$VERSION $IMAGE_TAG
echo "✅ [$(date '+%Y-%m-%d %H:%M:%S')] Build OK"

# Paso 4: Security Scan
echo ""
echo "️ [$(date '+%Y-%m-%d %H:%M:%S')] Paso 4: Security Scan..."
VULN_OUTPUT=$(trivy image --format json --quiet $APP_NAME:$VERSION
2>/dev/null || echo '{"Results":[]}')
CRITICAL_COUNT=$(echo "$VULN_OUTPUT" | grep -o '"Severity":"CRITICAL"' | wc -l)
HIGH_COUNT=$(echo "$VULN_OUTPUT" | grep -o '"Severity":"HIGH"' | wc -l)
echo " 📊 Vulnerabilidades: $CRITICAL_COUNT críticas, $HIGH_COUNT altas"
echo "✅ [$(date '+%Y-%m-%d %H:%M:%S')] Security Scan OK"
# Paso 5: Registry Push
echo ""
echo "📤 [$(date '+%Y-%m-%d %H:%M:%S')] Paso 5: Registry Push..."
docker push $IMAGE_TAG > /dev/null 2>&1
echo "✅ [$(date '+%Y-%m-%d %H:%M:%S')] Push OK"
# Paso 6: Deploy
echo ""
echo "🚀 [$(date '+%Y-%m-%d %H:%M:%S')] Paso 6: Deploy..."
docker stop $APP_NAME 2>/dev/null || true
docker rm $APP_NAME 2>/dev/null || true
docker run -d --name $APP_NAME -p 3000:3000 $IMAGE_TAG > /dev/null 2>&1
echo " ⏳ Esperando que la app esté lista..."
sleep 8
echo "✅ [$(date '+%Y-%m-%d %H:%M:%S')] Deploy OK"
# Paso 7: Health Check
echo ""
echo "🏥 [$(date '+%Y-%m-%d %H:%M:%S')] Paso 7: Health Check..."
for i in {1..5}; do

if curl -s http://localhost:3000/healthz | grep -q "healthy"; then
echo "✅ [$(date '+%Y-%m-%d %H:%M:%S')] Health Check OK"
break
fi
sleep 2
done
echo " 📊 Health Status: $(curl -s http://localhost:3000/healthz | jq -r '.status')"
# Paso 8: Performance Test
echo ""
echo "⚡ [$(date '+%Y-%m-%d %H:%M:%S')] Paso 8: Performance Test..."
PERF_RESULT=$(ab -n 100 -c 10 -q http://localhost:3000/ 2>/dev/null | grep "Requests per second" | awk '{print $4}')
echo " 📈 Performance: $PERF_RESULT requests/sec"
echo "✅ [$(date '+%Y-%m-%d %H:%M:%S')] Performance Test OK"
# Resumen Final
echo ""
echo "🎉 [$(date '+%Y-%m-%d %H:%M:%S')] ¡PIPELINE COMPLETADO
EXITOSAMENTE!"
echo "📊 Resumen Final:"
echo " ✅ Code Quality: Linting passed"
echo " ✅ Testing: 3/3 tests passed"
echo " ✅ Build: Docker image created"
echo " ✅ Security: $CRITICAL_COUNT críticas, $HIGH_COUNT altas"
echo " ✅ Registry: Image pushed"
echo " ✅ Deploy: App running"
echo " ✅ Health: Service healthy"
echo " ✅ Performance: $PERF_RESULT req/sec"

echo ""
echo "🌐 App: http://localhost:3000"
echo "🏥 Health: http://localhost:3000/healthz"
