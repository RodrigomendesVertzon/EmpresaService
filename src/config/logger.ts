import pino from "pino";
import { env } from "./env";

export const logger = pino({
  level: env.LOG_LEVEL,
  redact: {
    paths: [
      "req.headers.authorization",
      "headers.authorization",
      "password",
      "token",
      "accessToken",
      "refreshToken"
    ],
    censor: "[REDACTED]"
  }
});
