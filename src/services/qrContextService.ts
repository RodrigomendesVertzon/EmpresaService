import { AppError } from "../utils/AppError";
import * as repo from "../repositories/qrContextRepository";

function parseDate(value: Date | string | null): Date | null {
  if (!value) {
    return null;
  }

  return value instanceof Date
    ? value
    : new Date(value);
}

export async function getQrContext(token: string) {
  const context = await repo.findContextByToken(token);

  if (!context) {
    throw new AppError(
      404,
      "QR_NAO_ENCONTRADO",
      "QR Code operacional não encontrado"
    );
  }

  const agora = new Date();

  /*
   * QR
   */
  if (context.qr_status === "BLOQUEADO") {
    throw new AppError(
      409,
      "QR_BLOQUEADO",
      "QR Code operacional está bloqueado"
    );
  }

  if (context.qr_status !== "ATIVO") {
    throw new AppError(
      409,
      "QR_INATIVO",
      "QR Code operacional não está ativo"
    );
  }

  const validoDe = parseDate(context.qr_valido_de);
  const validoAte = parseDate(context.qr_valido_ate);

  if (validoDe && agora < validoDe) {
    throw new AppError(
      409,
      "QR_FORA_DA_VIGENCIA",
      "QR Code operacional ainda não está vigente"
    );
  }

  if (validoAte && agora > validoAte) {
    throw new AppError(
      409,
      "QR_EXPIRADO",
      "QR Code operacional está expirado"
    );
  }

  /*
   * Ponto operacional
   */
  if (!Boolean(context.ponto_ativo)) {
    throw new AppError(
      409,
      "PONTO_OPERACIONAL_INATIVO",
      "Ponto operacional não está ativo"
    );
  }

  /*
   * Setor
   */
  if (!Boolean(context.setor_ativo)) {
    throw new AppError(
      409,
      "SETOR_INATIVO",
      "Setor não está ativo"
    );
  }

  /*
   * Unidade
   */
  if (!Boolean(context.unidade_ativa)) {
    throw new AppError(
      409,
      "UNIDADE_INATIVA",
      "Unidade não está ativa"
    );
  }

  /*
   * Empresa
   *
   * Aqui temos duas situações:
   * - cadastro_status = ATIVO
   * - status operacional = ATIVA
   */
  if (context.empresa_cadastro_status !== "ATIVO") {
    throw new AppError(
      409,
      "EMPRESA_CADASTRO_NAO_ATIVO",
      "Cadastro da empresa ainda não está ativo"
    );
  }

  if (context.empresa_status !== "ATIVA") {
    throw new AppError(
      409,
      "EMPRESA_NAO_ATIVA",
      "Empresa não está operacionalmente ativa"
    );
  }

  /*
   * O ponto pode possuir raio próprio.
   *
   * Se não possuir, herdamos o raio da unidade.
   */
  const raioOperacaoMetros =
    context.ponto_raio_operacao_metros ??
    context.unidade_raio_operacao_metros;

  return {
    qr: {
      id: context.qr_id,
      token: context.qr_token,
      status: context.qr_status,
      validoDe,
      validoAte,
      utilizavel: true
    },

    empresa: {
      id: context.empresa_id,
      razaoSocial: context.empresa_razao_social,
      nomeFantasia: context.empresa_nome_fantasia,
      status: context.empresa_status,
      cadastroStatus: context.empresa_cadastro_status
    },

    unidade: {
      id: context.unidade_id,
      nome: context.unidade_nome,
      ativa: Boolean(context.unidade_ativa)
    },

    setor: {
      id: context.setor_id,
      nome: context.setor_nome,
      ativo: Boolean(context.setor_ativo)
    },

    ponto: {
      id: context.ponto_id,
      nome: context.ponto_nome,
      ativo: Boolean(context.ponto_ativo),

      latitude: Number(context.ponto_latitude),
      longitude: Number(context.ponto_longitude),

      raioOperacaoMetros
    }
  };
}