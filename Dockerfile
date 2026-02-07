FROM node:18-alpine
RUN npm install -g serve
WORKDIR /app
COPY index.html .
CMD ["sh", "-c", "serve -s . -l $PORT"]
