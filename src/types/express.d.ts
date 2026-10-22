import "express";

declare global {
  namespace Express {
    interface Request {
      auth?: {
        userId: number;
        role: "FREELANCER" | "ADMIN_EMPRESA" | "GERENTE" | "ADMIN_PLATAFORMA";
        email?: string;
      };
      correlationId?: string;
    }
  }
}
export {};
