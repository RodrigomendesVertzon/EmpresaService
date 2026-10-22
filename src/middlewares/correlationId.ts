import { randomUUID } from "crypto";
import { RequestHandler } from "express";

export const correlationId: RequestHandler = (req, res, next) => {
  const incoming = req.header("x-correlation-id")?.trim();
  req.correlationId = incoming || randomUUID();
  res.setHeader("x-correlation-id", req.correlationId);
  next();
};
