# Stage 1: Builder
FROM node:18-alpine AS builder
LABEL maintainer="DevOps Team <devops@ejemplo.com>"
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Generar package-lock.json si no existe y instalar dependencias
RUN npm install --package-lock-only
RUN npm ci
RUN npm install --only=dev

# Copiar código fuente
COPY . .

# Ejecutar linting y pruebas
RUN npm run lint
RUN npm test

# Limpiar e instalar solo dependencias de producción
RUN rm -rf node_modules
RUN npm ci --only=production && npm cache clean --force

# Stage 2: Runner
FROM node:12-alpine AS runner
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
WORKDIR /app

# Copiar desde builder
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/*.js ./
COPY --from=builder --chown=nodejs:nodejs /app/package*.json ./

USER nodejs
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
CMD node -e "require(\"http\").get(\"http://localhost:3000/healthz\", (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

CMD ["node", "index.js"]

