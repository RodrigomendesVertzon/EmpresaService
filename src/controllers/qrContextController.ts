import { Request, Response, NextFunction } from "express";
import { z } from "zod";
import * as qrContextService from "../services/qrContextService";

const paramsSchema = z.object({
  token: z
    .string()
    .uuid("Token do QR Code inválido")
});

export async function getContext(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const { token } = paramsSchema.parse(req.params);

    const context =
      await qrContextService.getQrContext(token);

    return res.status(200).json(context);
  } catch (err) {
    return next(err);
  }
}