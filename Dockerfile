# ---------- 1. Base Dependencies ----------
    FROM node:20-alpine AS deps
    WORKDIR /app
    
    # Copy package.json and install dependencies
    COPY my-app/package.json my-app/package-lock.json* ./
    RUN npm install --frozen-lockfile
    
    # ---------- 2. Builder ----------
    FROM node:20-alpine AS builder
    WORKDIR /app
    
    COPY --from=deps /app/node_modules ./node_modules
    COPY my-app ./
    
    RUN npm run build
    
    # ---------- 3. Production Runner ----------
    FROM node:20-alpine AS runner
    WORKDIR /app
    
    ENV NODE_ENV=production
    ENV PORT=80
    
    COPY --from=builder /app/public ./public
    COPY --from=builder /app/.next ./.next
    COPY --from=builder /app/node_modules ./node_modules
    COPY --from=builder /app/package.json ./package.json
    COPY --from=builder /app/next.config.ts ./next.config.ts
    
    EXPOSE 80
    
    CMD ["npx", "next", "start", "-p", "80"]
    