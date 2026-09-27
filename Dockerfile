# Começamos com uma imagem pequena que já tem o Node.js 20 instalado.
# Ela é a "caixa" onde a nossa aplicação vai morar.
FROM node:20-alpine

# Esta será a pasta de trabalho dentro da caixa.
WORKDIR /usr/src/app

# Copiamos primeiro a lista de bibliotecas e depois as instalamos.
# Assim o Docker pode reaproveitar esta etapa quando só o código mudar.
COPY ./app/package*.json ./
RUN npm install

# Agora copiamos o restante do código da aplicação para dentro da caixa.
COPY ./app .

# A aplicação conversa pela porta 3000.
EXPOSE 3000

# Quando a caixa for ligada, este comando inicia o servidor Node.js.
CMD ["npm", "start"]
