import { ResultSetHeader, RowDataPacket } from "mysql2";
import { db } from "../config/db";

export async function createEmpresa(input: {cnpj:string; razaoSocial:string; nomeFantasia?:string; email:string; telefone?:string; whatsapp?:string; actor:number; correlationId?:string}) {
  const [sets] = await db.query<RowDataPacket[][]>("CALL sp_cadastrar_empresa(?,?,?,?,?,?,?,?)", [input.cnpj,input.razaoSocial,input.nomeFantasia ?? null,input.email,input.telefone ?? null,input.whatsapp ?? null,input.actor,input.correlationId ?? null]);
  return Number(sets[0][0].empresa_id);
}
export async function findEmpresaById(id:number) { const [rows]=await db.query<RowDataPacket[]>("SELECT * FROM vw_empresa_resumo WHERE empresa_id=?",[id]); return rows[0] ?? null; }
export async function findCompaniesByAuthUser(authUserId:number) { const [rows]=await db.query<RowDataPacket[]>(`SELECT e.*, ue.papel FROM usuario_empresa ue JOIN empresa e ON e.id=ue.empresa_id WHERE ue.auth_user_id=? AND ue.ativo=1 ORDER BY e.id`,[authUserId]); return rows; }
export async function hasAccess(empresaId:number, authUserId:number) { const [rows]=await db.query<RowDataPacket[]>("SELECT papel FROM usuario_empresa WHERE empresa_id=? AND auth_user_id=? AND ativo=1 LIMIT 1",[empresaId,authUserId]); return rows[0] ?? null; }
export async function bindUser(empresaId:number, authUserId:number, papel:"ADMIN_EMPRESA"|"GERENTE", actor:number, correlationId?:string) { await db.query("CALL sp_vincular_usuario_empresa(?,?,?,?,?)",[empresaId,authUserId,papel,actor,correlationId ?? null]); }
export async function createUnidade(empresaId:number, x:any) { const [r]=await db.execute<ResultSetHeader>(`INSERT INTO unidade(empresa_id,codigo,nome,cep,logradouro,numero,complemento,bairro,cidade,uf,latitude,longitude,raio_operacao_metros) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)`,[empresaId,x.codigo??null,x.nome,x.cep,x.logradouro,x.numero,x.complemento??null,x.bairro,x.cidade,x.uf,x.latitude??null,x.longitude??null,x.raioOperacaoMetros??100]); return r.insertId; }
export async function listUnidades(empresaId:number) { const [r]=await db.query<RowDataPacket[]>("SELECT * FROM unidade WHERE empresa_id=? ORDER BY id",[empresaId]); return r; }
export async function findUnidade(id:number) { const [r]=await db.query<RowDataPacket[]>("SELECT * FROM unidade WHERE id=?",[id]); return r[0]??null; }
export async function createSetor(unidadeId:number,x:any) { const u=await findUnidade(unidadeId); if(!u) return null; const [r]=await db.execute<ResultSetHeader>("INSERT INTO setor(empresa_id,unidade_id,nome,descricao) VALUES(?,?,?,?)",[u.empresa_id,unidadeId,x.nome,x.descricao??null]); return r.insertId; }
export async function listSetores(unidadeId:number) { const [r]=await db.query<RowDataPacket[]>("SELECT * FROM setor WHERE unidade_id=? ORDER BY id",[unidadeId]); return r; }
export async function findSetor(id:number) { const [r]=await db.query<RowDataPacket[]>("SELECT * FROM setor WHERE id=?",[id]); return r[0]??null; }
export async function createPonto(setorId:number,x:any) { const s=await findSetor(setorId); if(!s) return null; const [r]=await db.execute<ResultSetHeader>(`INSERT INTO ponto_operacional(empresa_id,unidade_id,setor_id,codigo,nome,descricao,latitude,longitude,raio_operacao_metros) VALUES(?,?,?,?,?,?,?,?,?)`,[s.empresa_id,s.unidade_id,setorId,x.codigo??null,x.nome,x.descricao??null,x.latitude,x.longitude,x.raioOperacaoMetros??null]); return r.insertId; }
export async function listPontos(setorId:number) { const [r]=await db.query<RowDataPacket[]>("SELECT * FROM ponto_operacional WHERE setor_id=? ORDER BY id",[setorId]); return r; }
export async function findPonto(id:number) { const [r]=await db.query<RowDataPacket[]>("SELECT * FROM ponto_operacional WHERE id=?",[id]); return r[0]??null; }
export async function createQr(pontoId:number, validoDe:string|null,validoAte:string|null,actor:number,correlationId?:string) { const [sets]=await db.query<RowDataPacket[][]>("CALL sp_gerar_qr_operacional(?,?,?,?,?)",[pontoId,validoDe,validoAte,actor,correlationId??null]); return sets[0][0]; }
export async function listQrs(pontoId:number) { const [r]=await db.query<RowDataPacket[]>("SELECT * FROM qr_code_operacional WHERE ponto_operacional_id=? ORDER BY id DESC",[pontoId]); return r; }
export async function findQr(id:number) { const [r]=await db.query<RowDataPacket[]>(`SELECT q.*, p.empresa_id FROM qr_code_operacional q JOIN ponto_operacional p ON p.id=q.ponto_operacional_id WHERE q.id=?`,[id]); return r[0]??null; }
export async function changeQrStatus(id:number,status:string,motivo:string|null,actor:number,correlationId?:string) { await db.query("CALL sp_alterar_status_qr(?,?,?,?,?)",[id,status,motivo,actor,correlationId??null]); }
