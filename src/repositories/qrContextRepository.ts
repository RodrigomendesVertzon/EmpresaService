import { RowDataPacket } from "mysql2";
import { db } from "../config/db";

export interface QrContextRow extends RowDataPacket {
  qr_id: number;
  qr_token: string;
  qr_status: "ATIVO" | "INATIVO" | "BLOQUEADO";
  qr_valido_de: Date | null;
  qr_valido_ate: Date | null;

  ponto_id: number;
  ponto_nome: string;
  ponto_ativo: number;
  ponto_latitude: string;
  ponto_longitude: string;
  ponto_raio_operacao_metros: number | null;

  setor_id: number;
  setor_nome: string;
  setor_ativo: number;

  unidade_id: number;
  unidade_nome: string;
  unidade_ativa: number;
  unidade_latitude: string | null;
  unidade_longitude: string | null;
  unidade_raio_operacao_metros: number;

  empresa_id: number;
  empresa_razao_social: string;
  empresa_nome_fantasia: string | null;
  empresa_status: "PENDENTE" | "ATIVA" | "BLOQUEADA" | "INATIVA";
  empresa_cadastro_status:
    | "INCOMPLETO"
    | "PENDENTE_VALIDACAO"
    | "REJEITADO"
    | "ATIVO";
}

export async function findContextByToken(
  token: string
): Promise<QrContextRow | null> {
  const [rows] = await db.execute<QrContextRow[]>(
    `
    SELECT
        q.id                    AS qr_id,
        q.token                 AS qr_token,
        q.status                AS qr_status,
        q.valido_de             AS qr_valido_de,
        q.valido_ate            AS qr_valido_ate,

        p.id                    AS ponto_id,
        p.nome                  AS ponto_nome,
        p.ativo                 AS ponto_ativo,
        p.latitude              AS ponto_latitude,
        p.longitude             AS ponto_longitude,
        p.raio_operacao_metros  AS ponto_raio_operacao_metros,

        s.id                    AS setor_id,
        s.nome                  AS setor_nome,
        s.ativo                 AS setor_ativo,

        u.id                    AS unidade_id,
        u.nome                  AS unidade_nome,
        u.ativo                 AS unidade_ativa,
        u.latitude              AS unidade_latitude,
        u.longitude             AS unidade_longitude,
        u.raio_operacao_metros  AS unidade_raio_operacao_metros,

        e.id                    AS empresa_id,
        e.razao_social          AS empresa_razao_social,
        e.nome_fantasia         AS empresa_nome_fantasia,
        e.status                AS empresa_status,
        e.cadastro_status       AS empresa_cadastro_status

    FROM qr_code_operacional q

    INNER JOIN ponto_operacional p
        ON p.id = q.ponto_operacional_id

    INNER JOIN setor s
        ON s.id = p.setor_id

    INNER JOIN unidade u
        ON u.id = p.unidade_id
       AND u.id = s.unidade_id

    INNER JOIN empresa e
        ON e.id = u.empresa_id

    WHERE q.token = ?

    LIMIT 1
    `,
    [token]
  );

  return rows[0] ?? null;
}