FROM node:18
WORKDIR /app
COPY . .
RUN npm install --only=production
CMD ["npm", "run", "start:prod"]
