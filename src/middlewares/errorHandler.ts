import { ErrorRequestHandler } from "express";
import { ZodError } from "zod";
import { logger } from "../config/logger";
import { AppError } from "../utils/AppError";

export const errorHandler: ErrorRequestHandler = (err, req, res, _next) => {
  if (err instanceof ZodError) return res.status(400).json({ error: "DADOS_INVALIDOS", message: "Dados inválidos", details: err.flatten(), correlationId: req.correlationId });
  if (err instanceof AppError) return res.status(err.statusCode).json({ error: err.code, message: err.message, details: err.details, correlationId: req.correlationId });
  const mysql = err as { code?: string; errno?: number; sqlMessage?: string };
  if (mysql.code === "ER_DUP_ENTRY") return res.status(409).json({ error: "REGISTRO_DUPLICADO", message: "Já existe um registro com uma chave única informada", correlationId: req.correlationId });
  logger.error({ err, correlationId: req.correlationId }, "unhandled error");
  return res.status(500).json({ error: "ERRO_INTERNO", message: "Erro interno do servidor", correlationId: req.correlationId });
};
