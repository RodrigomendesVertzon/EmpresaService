# Empresa Service

Microsserviço responsável por empresa, vínculos de usuários, unidades, setores, pontos operacionais e QR operacional.

## Requisitos
- Node.js 20+
- MySQL 8
- banco `empresa_service` criado pelo `migrations/001_initial_schema.sql`
- Auth Service emitindo JWT com `iss=auth-service`, `aud=platform-api`, `type=access`

## Instalação (PowerShell)
```powershell
cd C:\Projetos\free-lancer\empresa-service
npm install
Copy-Item .env.example .env
```
Ajuste `JWT_ACCESS_SECRET` para o MESMO segredo do Auth Service.

## Executar
```powershell
npm run typecheck
npm test
npm run dev
```

## Health
- GET http://localhost:3003/health/live
- GET http://localhost:3003/health/ready

## Endpoints v1
- POST /v1/empresas — ADMIN_PLATAFORMA
- GET /v1/empresas/me — ADMIN_EMPRESA/GERENTE
- GET /v1/empresas/:id
- POST/GET /v1/empresas/:id/unidades
- POST/GET /v1/unidades/:id/setores
- POST/GET /v1/setores/:id/pontos
- POST/GET /v1/pontos/:id/qrcodes
- PATCH /v1/qrcodes/:id/status

## Exemplo: criar empresa
```json
{
  "cnpj": "12345678000199",
  "razaoSocial": "Empresa Teste Ltda",
  "nomeFantasia": "Empresa Teste",
  "email": "contato@empresa.com",
  "telefone": "11999999999",
  "whatsapp": "11999999999"
}
```

Observação: a primeira versão valida o formato de 14 dígitos do CNPJ. A validação matemática completa deve ser adicionada antes da abertura pública do cadastro.
