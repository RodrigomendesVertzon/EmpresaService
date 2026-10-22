import { describe, expect, it } from "vitest";
import { empresaSchema, qrStatusSchema } from "../src/services/empresaService";
describe("empresa schemas",()=>{
  it("aceita empresa válida",()=>{expect(empresaSchema.parse({cnpj:"12345678000199",razaoSocial:"Empresa Teste Ltda",email:"teste@example.com"}).cnpj).toBe("12345678000199");});
  it("rejeita CNPJ fora do formato",()=>{expect(()=>empresaSchema.parse({cnpj:"123",razaoSocial:"Empresa",email:"teste@example.com"})).toThrow();});
  it("aceita status de QR conhecido",()=>{expect(qrStatusSchema.parse({status:"BLOQUEADO",motivo:"Teste"}).status).toBe("BLOQUEADO");});
});
