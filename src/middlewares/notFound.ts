import { RequestHandler } from "express";
export const notFound: RequestHandler = (req, res) => res.status(404).json({ error: "ROTA_NAO_ENCONTRADA", message: `Rota ${req.method} ${req.path} não encontrada`, correlationId: req.correlationId });
