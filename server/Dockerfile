FROM node:20-alpine

WORKDIR /app

COPY server/package.json server/package-lock.json* ./
RUN npm ci --omit=dev 2>/dev/null || npm install --omit=dev

COPY server/src ./src
COPY assets/mock ./assets/mock

ENV PORT=8080
ENV MOCK_DATA_DIR=/app/assets/mock
ENV API_PREFIX=/api/v1
ENV MOCK_DELAY_MS=0

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD wget -qO- http://127.0.0.1:8080/health || exit 1

CMD ["node", "src/index.js"]
