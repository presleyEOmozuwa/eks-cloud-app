# Base file system for Container
FROM node:alpine

# Create a Directory to store your code
WORKDIR /app

# Copy the package.json to the created Directory
COPY package.json* ./

# Run the npm install to have node_modules
RUN npm install

# Copy the rest of the file
COPY . .

EXPOSE 5173

# Run the start up command
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "5173"]
