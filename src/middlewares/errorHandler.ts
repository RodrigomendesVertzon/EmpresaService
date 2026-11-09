import { ErrorRequestHandler } from "express";
import { ZodError } from "zod";
import { logger } from "../config/logger";
import { AppError } from "../utils/AppError";

interface MySqlError extends Error {
  code?: string;
  errno?: number;
  sqlState?: string;
  sqlMessage?: string;
  sql?: string;
}

export const errorHandler: ErrorRequestHandler = (
  err,
  req,
  res,
  _next
) => {
  const correlationId = req.correlationId;

  /*
   * Erros de validação de entrada
   */
  if (err instanceof ZodError) {
    return res.status(400).json({
      error: "DADOS_INVALIDOS",
      message: "Dados inválidos",
      details: err.flatten(),
      correlationId
    });
  }

  /*
   * Erros controlados da aplicação
   */
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      error: err.code,
      message: err.message,
      details: err.details,
      correlationId
    });
  }

  /*
   * Erros provenientes do MySQL
   */
  const mysql = err as MySqlError;

  /*
   * Chave única duplicada
   *
   * Exemplo:
   * ER_DUP_ENTRY / errno 1062
   */
  if (mysql.code === "ER_DUP_ENTRY" || mysql.errno === 1062) {
    logger.error(
      {
        correlationId,
        mysql: {
          code: mysql.code,
          errno: mysql.errno,
          sqlState: mysql.sqlState,
          sqlMessage: mysql.sqlMessage,
          sql: mysql.sql
        }
      },
      "mysql duplicate entry"
    );

    /*
     * Durante o desenvolvimento também mostramos
     * claramente no terminal para facilitar o diagnóstico.
     */
    if (process.env.NODE_ENV !== "production") {
      console.error("\n========== MYSQL DUPLICATE ERROR ==========");
      console.error("Correlation ID:", correlationId);
      console.error("Code:", mysql.code);
      console.error("Errno:", mysql.errno);
      console.error("SQL State:", mysql.sqlState);
      console.error("SQL Message:", mysql.sqlMessage);
      console.error("SQL:", mysql.sql);
      console.error("===========================================\n");
    }

    return res.status(409).json({
      error: "REGISTRO_DUPLICADO",
      message: "Já existe um registro com uma chave única informada",
      correlationId
    });
  }

  /*
   * Violação de Foreign Key
   */
  if (
    mysql.code === "ER_NO_REFERENCED_ROW_2" ||
    mysql.code === "ER_ROW_IS_REFERENCED_2"
  ) {
    logger.error(
      {
        correlationId,
        mysql: {
          code: mysql.code,
          errno: mysql.errno,
          sqlState: mysql.sqlState,
          sqlMessage: mysql.sqlMessage,
          sql: mysql.sql
        }
      },
      "mysql foreign key error"
    );

    return res.status(409).json({
      error: "CONFLITO_REFERENCIAL",
      message: "A operação viola uma referência existente",
      correlationId
    });
  }

  /*
   * Violação de CHECK/constraint
   */
  if (
    mysql.code === "ER_CHECK_CONSTRAINT_VIOLATED" ||
    mysql.errno === 3819
  ) {
    logger.error(
      {
        correlationId,
        mysql: {
          code: mysql.code,
          errno: mysql.errno,
          sqlState: mysql.sqlState,
          sqlMessage: mysql.sqlMessage,
          sql: mysql.sql
        }
      },
      "mysql constraint violation"
    );

    return res.status(400).json({
      error: "REGRA_BANCO_VIOLADA",
      message: "Os dados informados violam uma regra de validação",
      correlationId
    });
  }

  /*
   * Qualquer outro erro inesperado.
   *
   * O erro completo fica somente no log.
   * A API não expõe SQL, stack trace ou detalhes internos.
   */
  logger.error(
    {
      err,
      correlationId,
      mysql:
        mysql.code || mysql.errno
          ? {
              code: mysql.code,
              errno: mysql.errno,
              sqlState: mysql.sqlState,
              sqlMessage: mysql.sqlMessage,
              sql: mysql.sql
            }
          : undefined
    },
    "unhandled error"
  );

  if (process.env.NODE_ENV !== "production") {
    console.error("\n========== UNHANDLED ERROR ==========");
    console.error("Correlation ID:", correlationId);
    console.error(err);
    console.error("=====================================\n");
  }

  return res.status(500).json({
    error: "ERRO_INTERNO",
    message: "Erro interno do servidor",
    correlationId
  });
};