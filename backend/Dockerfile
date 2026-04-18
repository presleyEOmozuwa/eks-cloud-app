# Base file system for Container
FROM node:buster

# Create a Directory to store your code
WORKDIR /app

# Copy the package.json to the created Directory
COPY package.json* ./

# Run the npm install to download node_modules
RUN npm install

# Copy the rest of the file
COPY . .

EXPOSE 3000

# Run the start up command
CMD ["npm", "run", "dev", "--", "--host"]