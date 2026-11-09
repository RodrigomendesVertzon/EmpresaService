import { Router } from "express";
import * as controller from "../controllers/qrContextController";
import { authenticate } from "../middlewares/auth";

const router = Router();

/*
 * Por enquanto usamos o JWT do Auth Service.
 *
 * Posteriormente podemos trocar por autenticação
 * service-to-service específica.
 */
router.get(
  "/qrcodes/:token/context",
  authenticate,
  controller.getContext
);

export default router;