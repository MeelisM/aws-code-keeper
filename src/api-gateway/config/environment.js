import dotenv from "dotenv";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config({ path: join(__dirname, "/../.env") });

const config = {
  server: {
    port: process.env.PORT,
    host: process.env.HOST,
    inventoryUrl: process.env.INVENTORY_URL,
  },
  rabbitmq: {
    apiUrl: process.env.RABBITMQ_API_URL,
    queue: process.env.RABBITMQ_QUEUE,
  },
};

console.log("API Gateway configuration:", {
  port: config.server.port,
  host: config.server.host,
  inventoryUrl: config.server.inventoryUrl,
});

export default config;
