import dotenv from "dotenv";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config({ path: join(__dirname, "/../../.env") });

const config = {
  server: {
    port: process.env.PORT,
    host: process.env.HOST,
  },
  database: {
    username: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: "postgres",
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000,
    },
  },
  rabbitmq: {
    localUrl: process.env.RABBITMQ_LOCAL_URL,
    queue: process.env.RABBITMQ_QUEUE,
  },
};

console.log(config.database);
export default config;
