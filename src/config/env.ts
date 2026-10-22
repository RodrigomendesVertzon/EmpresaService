import "dotenv/config";
import { z } from "zod";

const schema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  PORT: z.coerce.number().int().positive().default(3003),
  DB_HOST: z.string().min(1),
  DB_PORT: z.coerce.number().int().positive().default(3306),
  DB_USER: z.string().min(1),
  DB_PASSWORD: z.string(),
  DB_NAME: z.string().min(1).default("empresa_service"),
  DB_CONNECTION_LIMIT: z.coerce.number().int().positive().default(10),
  LOG_LEVEL: z.string().default("info"),
  JWT_ACCESS_SECRET: z.string().min(32),
  JWT_ISSUER: z.string().default("auth-service"),
  JWT_AUDIENCE: z.string().default("platform-api"),
  CORS_ORIGIN: z.string().default("http://localhost:4200")
});

export const env = schema.parse(process.env);
