import { RequestHandler } from "express";
import jwt, { JwtPayload } from "jsonwebtoken";
import { env } from "../config/env";
import { AppError } from "../utils/AppError";

const roles = new Set(["FREELANCER", "ADMIN_EMPRESA", "GERENTE", "ADMIN_PLATAFORMA"]);

export const authenticate: RequestHandler = (req, _res, next) => {
  const header = req.header("authorization");
  if (!header?.startsWith("Bearer ")) return next(new AppError(401, "TOKEN_AUSENTE", "Token de acesso ausente"));
  try {
    const payload = jwt.verify(header.slice(7), env.JWT_ACCESS_SECRET, {
      issuer: env.JWT_ISSUER,
      audience: env.JWT_AUDIENCE
    }) as JwtPayload;
    if (payload.type !== "access" || !payload.sub || !roles.has(String(payload.role))) {
      throw new Error("invalid claims");
    }
    const userId = Number(payload.sub);
    if (!Number.isSafeInteger(userId) || userId <= 0) throw new Error("invalid sub");
    req.auth = { userId, role: payload.role as Express.Request["auth"] extends infer A ? A extends {role: infer R} ? R : never : never, email: typeof payload.email === "string" ? payload.email : undefined };
    next();
  } catch {
    next(new AppError(401, "TOKEN_INVALIDO", "Token de acesso inválido ou expirado"));
  }
};
