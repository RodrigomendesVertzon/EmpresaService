import { RequestHandler } from "express";
import { AppError } from "../utils/AppError";

type Role = "FREELANCER" | "ADMIN_EMPRESA" | "GERENTE" | "ADMIN_PLATAFORMA";
export const requireRole = (...allowed: Role[]): RequestHandler => (req, _res, next) => {
  if (!req.auth) return next(new AppError(401, "NAO_AUTENTICADO", "Usuário não autenticado"));
  if (!allowed.includes(req.auth.role)) return next(new AppError(403, "ACESSO_NEGADO", "Perfil sem permissão para esta operação"));
  next();
};
