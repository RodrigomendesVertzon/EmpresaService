-- ============================================================================
-- EMPRESA SERVICE - SCHEMA CONSOLIDADO
-- Plataforma de Freelancers
-- MySQL 8.0+
-- ============================================================================

CREATE DATABASE IF NOT EXISTS empresa_service
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE empresa_service;

-- ============================================================================
-- 1. EMPRESA
-- ============================================================================
CREATE TABLE IF NOT EXISTS empresa (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  cnpj CHAR(14) NOT NULL,
  razao_social VARCHAR(200) NOT NULL,
  nome_fantasia VARCHAR(200) NULL,
  email VARCHAR(254) NOT NULL,
  telefone VARCHAR(20) NULL,
  whatsapp VARCHAR(20) NULL,
  cadastro_status ENUM('INCOMPLETO','PENDENTE_VALIDACAO','REJEITADO','ATIVO') NOT NULL DEFAULT 'INCOMPLETO',
  status ENUM('PENDENTE','ATIVA','BLOQUEADA','INATIVA') NOT NULL DEFAULT 'PENDENTE',
  versao BIGINT UNSIGNED NOT NULL DEFAULT 1,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_empresa_cnpj (cnpj),
  KEY idx_empresa_status (status, cadastro_status),
  CONSTRAINT ck_empresa_cnpj_formato CHECK (cnpj REGEXP '^[0-9]{14}$')
) ENGINE=InnoDB;

-- ============================================================================
-- 2. ENDERECO DA EMPRESA
-- ============================================================================
CREATE TABLE IF NOT EXISTS empresa_endereco (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  empresa_id BIGINT UNSIGNED NOT NULL,
  cep VARCHAR(9) NOT NULL,
  logradouro VARCHAR(200) NOT NULL,
  numero VARCHAR(30) NOT NULL,
  complemento VARCHAR(100) NULL,
  bairro VARCHAR(100) NOT NULL,
  cidade VARCHAR(100) NOT NULL,
  uf CHAR(2) NOT NULL,
  latitude DECIMAL(10,7) NULL,
  longitude DECIMAL(10,7) NULL,
  principal TINYINT(1) NOT NULL DEFAULT 1,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  vigencia_inicio DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  vigencia_fim DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_empresa_endereco (empresa_id, ativo, principal),
  CONSTRAINT fk_empresa_endereco_empresa FOREIGN KEY (empresa_id) REFERENCES empresa(id),
  CONSTRAINT ck_empresa_endereco_uf CHECK (uf REGEXP '^[A-Z]{2}$'),
  CONSTRAINT ck_empresa_endereco_lat CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
  CONSTRAINT ck_empresa_endereco_lon CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180),
  CONSTRAINT ck_empresa_endereco_vigencia CHECK (vigencia_fim IS NULL OR vigencia_fim > vigencia_inicio)
) ENGINE=InnoDB;

-- ============================================================================
-- 3. RESPONSAVEL DA EMPRESA
-- ============================================================================
CREATE TABLE IF NOT EXISTS empresa_responsavel (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  empresa_id BIGINT UNSIGNED NOT NULL,
  nome VARCHAR(150) NOT NULL,
  cpf CHAR(11) NULL,
  cargo VARCHAR(100) NULL,
  email VARCHAR(254) NOT NULL,
  telefone VARCHAR(20) NULL,
  principal TINYINT(1) NOT NULL DEFAULT 0,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_responsavel_empresa (empresa_id, ativo, principal),
  CONSTRAINT fk_responsavel_empresa FOREIGN KEY (empresa_id) REFERENCES empresa(id),
  CONSTRAINT ck_responsavel_cpf CHECK (cpf IS NULL OR cpf REGEXP '^[0-9]{11}$')
) ENGINE=InnoDB;

-- ============================================================================
-- 4. USUARIO x EMPRESA
-- auth_user_id e referencia logica ao Auth Service. Sem FK entre servicos.
-- ============================================================================
CREATE TABLE IF NOT EXISTS usuario_empresa (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  empresa_id BIGINT UNSIGNED NOT NULL,
  auth_user_id BIGINT UNSIGNED NOT NULL,
  papel ENUM('ADMIN_EMPRESA','GERENTE') NOT NULL,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_usuario_empresa (empresa_id, auth_user_id),
  KEY idx_usuario_empresa_auth (auth_user_id, ativo),
  CONSTRAINT fk_usuario_empresa_empresa FOREIGN KEY (empresa_id) REFERENCES empresa(id)
) ENGINE=InnoDB;

-- ============================================================================
-- 5. UNIDADE
-- ============================================================================
CREATE TABLE IF NOT EXISTS unidade (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  empresa_id BIGINT UNSIGNED NOT NULL,
  codigo VARCHAR(50) NULL,
  nome VARCHAR(150) NOT NULL,
  cep VARCHAR(9) NOT NULL,
  logradouro VARCHAR(200) NOT NULL,
  numero VARCHAR(30) NOT NULL,
  complemento VARCHAR(100) NULL,
  bairro VARCHAR(100) NOT NULL,
  cidade VARCHAR(100) NOT NULL,
  uf CHAR(2) NOT NULL,
  latitude DECIMAL(10,7) NULL,
  longitude DECIMAL(10,7) NULL,
  raio_operacao_metros INT UNSIGNED NOT NULL DEFAULT 100,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  versao BIGINT UNSIGNED NOT NULL DEFAULT 1,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_unidade_codigo (empresa_id, codigo),
  UNIQUE KEY uk_unidade_id_empresa (id, empresa_id),
  KEY idx_unidade_empresa (empresa_id, ativo),
  CONSTRAINT fk_unidade_empresa FOREIGN KEY (empresa_id) REFERENCES empresa(id),
  CONSTRAINT ck_unidade_uf CHECK (uf REGEXP '^[A-Z]{2}$'),
  CONSTRAINT ck_unidade_lat CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
  CONSTRAINT ck_unidade_lon CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180),
  CONSTRAINT ck_unidade_raio CHECK (raio_operacao_metros BETWEEN 10 AND 5000)
) ENGINE=InnoDB;

-- ============================================================================
-- 6. SETOR
-- empresa_id redundante de forma intencional para permitir integridade composta
-- e consultas por tenant sem JOIN adicional.
-- ============================================================================
CREATE TABLE IF NOT EXISTS setor (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  empresa_id BIGINT UNSIGNED NOT NULL,
  unidade_id BIGINT UNSIGNED NOT NULL,
  nome VARCHAR(100) NOT NULL,
  descricao VARCHAR(500) NULL,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  versao BIGINT UNSIGNED NOT NULL DEFAULT 1,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_setor_unidade_nome (unidade_id, nome),
  UNIQUE KEY uk_setor_id_unidade_empresa (id, unidade_id, empresa_id),
  KEY idx_setor_empresa_unidade (empresa_id, unidade_id, ativo),
  CONSTRAINT fk_setor_unidade_empresa FOREIGN KEY (unidade_id, empresa_id)
    REFERENCES unidade(id, empresa_id)
) ENGINE=InnoDB;

-- ============================================================================
-- 7. PONTO OPERACIONAL
-- A FK composta impede setor de outra unidade/empresa.
-- ============================================================================
CREATE TABLE IF NOT EXISTS ponto_operacional (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  empresa_id BIGINT UNSIGNED NOT NULL,
  unidade_id BIGINT UNSIGNED NOT NULL,
  setor_id BIGINT UNSIGNED NOT NULL,
  codigo VARCHAR(50) NULL,
  nome VARCHAR(150) NOT NULL,
  descricao VARCHAR(500) NULL,
  latitude DECIMAL(10,7) NOT NULL,
  longitude DECIMAL(10,7) NOT NULL,
  raio_operacao_metros INT UNSIGNED NULL,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  versao BIGINT UNSIGNED NOT NULL DEFAULT 1,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_ponto_codigo (unidade_id, codigo),
  KEY idx_ponto_empresa_unidade (empresa_id, unidade_id, ativo),
  KEY idx_ponto_setor (setor_id, ativo),
  CONSTRAINT fk_ponto_setor_unidade_empresa FOREIGN KEY (setor_id, unidade_id, empresa_id)
    REFERENCES setor(id, unidade_id, empresa_id),
  CONSTRAINT ck_ponto_lat CHECK (latitude BETWEEN -90 AND 90),
  CONSTRAINT ck_ponto_lon CHECK (longitude BETWEEN -180 AND 180),
  CONSTRAINT ck_ponto_raio CHECK (raio_operacao_metros IS NULL OR raio_operacao_metros BETWEEN 10 AND 5000)
) ENGINE=InnoDB;

-- ============================================================================
-- 8. QR CODE OPERACIONAL
-- token e opaco. O QR nao precisa expor CNPJ, coordenadas ou IDs internos.
-- ============================================================================
CREATE TABLE IF NOT EXISTS qr_code_operacional (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  ponto_operacional_id BIGINT UNSIGNED NOT NULL,
  token CHAR(36) NOT NULL,
  status ENUM('ATIVO','INATIVO','BLOQUEADO') NOT NULL DEFAULT 'ATIVO',
  valido_de DATETIME(3) NULL,
  valido_ate DATETIME(3) NULL,
  motivo_bloqueio VARCHAR(500) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_qr_token (token),
  KEY idx_qr_ponto_status (ponto_operacional_id, status),
  CONSTRAINT fk_qr_ponto FOREIGN KEY (ponto_operacional_id) REFERENCES ponto_operacional(id),
  CONSTRAINT ck_qr_vigencia CHECK (valido_ate IS NULL OR valido_de IS NULL OR valido_ate > valido_de)
) ENGINE=InnoDB;

-- ============================================================================
-- 9. CONTRATO / ADESAO
-- documento_hash preserva evidencia do documento efetivamente assinado.
-- ============================================================================
CREATE TABLE IF NOT EXISTS contrato_empresa (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  empresa_id BIGINT UNSIGNED NOT NULL,
  tipo ENUM('ADESAO','TERMOS_COMERCIAIS','OUTRO') NOT NULL DEFAULT 'ADESAO',
  versao VARCHAR(30) NOT NULL,
  documento_url VARCHAR(500) NOT NULL,
  documento_hash CHAR(64) NOT NULL,
  status ENUM('PENDENTE','ASSINADO','CANCELADO') NOT NULL DEFAULT 'PENDENTE',
  assinado_por_auth_user_id BIGINT UNSIGNED NULL,
  ip_assinatura VARCHAR(45) NULL,
  user_agent VARCHAR(500) NULL,
  correlation_id VARCHAR(100) NULL,
  assinado_em DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_contrato_empresa_tipo_versao (empresa_id, tipo, versao),
  KEY idx_contrato_empresa_status (empresa_id, status),
  CONSTRAINT fk_contrato_empresa FOREIGN KEY (empresa_id) REFERENCES empresa(id),
  CONSTRAINT ck_contrato_hash CHECK (documento_hash REGEXP '^[0-9A-Fa-f]{64}$'),
  CONSTRAINT ck_contrato_assinatura CHECK (
    (status <> 'ASSINADO') OR (assinado_por_auth_user_id IS NOT NULL AND assinado_em IS NOT NULL)
  )
) ENGINE=InnoDB;

-- ============================================================================
-- 10. IDEMPOTENCIA
-- ============================================================================
CREATE TABLE IF NOT EXISTS idempotencia (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  chave VARCHAR(150) NOT NULL,
  operacao VARCHAR(100) NOT NULL,
  request_hash CHAR(64) NULL,
  status ENUM('PROCESSANDO','CONCLUIDO','ERRO') NOT NULL DEFAULT 'PROCESSANDO',
  response_status INT NULL,
  response_body JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  expires_at DATETIME(3) NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_idempotencia (operacao, chave),
  KEY idx_idempotencia_expiracao (expires_at)
) ENGINE=InnoDB;

-- ============================================================================
-- 11. TRANSACTIONAL OUTBOX
-- ============================================================================
CREATE TABLE IF NOT EXISTS outbox_event (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  event_id CHAR(36) NOT NULL,
  aggregate_type VARCHAR(100) NOT NULL,
  aggregate_id VARCHAR(100) NOT NULL,
  event_type VARCHAR(150) NOT NULL,
  event_version INT UNSIGNED NOT NULL DEFAULT 1,
  payload JSON NOT NULL,
  status ENUM('PENDENTE','PUBLICANDO','PUBLICADO','ERRO') NOT NULL DEFAULT 'PENDENTE',
  tentativas INT UNSIGNED NOT NULL DEFAULT 0,
  ultimo_erro VARCHAR(1000) NULL,
  proxima_tentativa_em DATETIME(3) NULL,
  publicado_em DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_outbox_event_id (event_id),
  KEY idx_outbox_publicacao (status, proxima_tentativa_em, created_at),
  KEY idx_outbox_aggregate (aggregate_type, aggregate_id, created_at)
) ENGINE=InnoDB;

-- ============================================================================
-- 12. AUDITORIA LOCAL DO DOMINIO - APPEND ONLY
-- ============================================================================
CREATE TABLE IF NOT EXISTS auditoria (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  entidade VARCHAR(100) NOT NULL,
  entidade_id VARCHAR(100) NOT NULL,
  acao VARCHAR(100) NOT NULL,
  actor_auth_user_id BIGINT UNSIGNED NULL,
  correlation_id VARCHAR(100) NULL,
  dados_anteriores JSON NULL,
  dados_novos JSON NULL,
  ip VARCHAR(45) NULL,
  user_agent VARCHAR(500) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_auditoria_entidade (entidade, entidade_id, created_at),
  KEY idx_auditoria_actor (actor_auth_user_id, created_at),
  KEY idx_auditoria_correlation (correlation_id)
) ENGINE=InnoDB;

-- ============================================================================
-- FUNCTIONS
-- ============================================================================
DROP FUNCTION IF EXISTS fn_cnpj_mascarado;
DELIMITER $$
CREATE FUNCTION fn_cnpj_mascarado(p_cnpj CHAR(14))
RETURNS VARCHAR(18)
DETERMINISTIC
BEGIN
  IF p_cnpj IS NULL OR CHAR_LENGTH(p_cnpj) <> 14 THEN
    RETURN NULL;
  END IF;
  RETURN CONCAT('**.', SUBSTRING(p_cnpj,3,3), '.', SUBSTRING(p_cnpj,6,3), '/', SUBSTRING(p_cnpj,9,4), '-**');
END$$
DELIMITER ;

-- ============================================================================
-- PROCEDURES
-- ============================================================================
DROP PROCEDURE IF EXISTS sp_cadastrar_empresa;
DELIMITER $$
CREATE PROCEDURE sp_cadastrar_empresa(
  IN p_cnpj CHAR(14),
  IN p_razao_social VARCHAR(200),
  IN p_nome_fantasia VARCHAR(200),
  IN p_email VARCHAR(254),
  IN p_telefone VARCHAR(20),
  IN p_whatsapp VARCHAR(20),
  IN p_actor_auth_user_id BIGINT UNSIGNED,
  IN p_correlation_id VARCHAR(100)
)
BEGIN
  DECLARE v_empresa_id BIGINT UNSIGNED;
  START TRANSACTION;

  INSERT INTO empresa(cnpj, razao_social, nome_fantasia, email, telefone, whatsapp)
  VALUES(p_cnpj, p_razao_social, p_nome_fantasia, p_email, p_telefone, p_whatsapp);
  SET v_empresa_id = LAST_INSERT_ID();

  INSERT INTO auditoria(entidade, entidade_id, acao, actor_auth_user_id, correlation_id, dados_novos)
  VALUES('EMPRESA', CAST(v_empresa_id AS CHAR), 'CADASTRADA', p_actor_auth_user_id, p_correlation_id,
         JSON_OBJECT('cnpj_mascarado', fn_cnpj_mascarado(p_cnpj), 'razao_social', p_razao_social, 'nome_fantasia', p_nome_fantasia));

  INSERT INTO outbox_event(event_id, aggregate_type, aggregate_id, event_type, event_version, payload)
  VALUES(UUID(), 'EMPRESA', CAST(v_empresa_id AS CHAR), 'empresa.cadastrada.v1', 1,
         JSON_OBJECT('empresaId', v_empresa_id, 'cnpjMascarado', fn_cnpj_mascarado(p_cnpj), 'razaoSocial', p_razao_social));

  COMMIT;
  SELECT v_empresa_id AS empresa_id;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_vincular_usuario_empresa;
DELIMITER $$
CREATE PROCEDURE sp_vincular_usuario_empresa(
  IN p_empresa_id BIGINT UNSIGNED,
  IN p_auth_user_id BIGINT UNSIGNED,
  IN p_papel VARCHAR(30),
  IN p_actor_auth_user_id BIGINT UNSIGNED,
  IN p_correlation_id VARCHAR(100)
)
BEGIN
  IF p_papel NOT IN ('ADMIN_EMPRESA','GERENTE') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Papel de usuario invalido';
  END IF;

  INSERT INTO usuario_empresa(empresa_id, auth_user_id, papel, ativo)
  VALUES(p_empresa_id, p_auth_user_id, p_papel, 1)
  ON DUPLICATE KEY UPDATE papel = VALUES(papel), ativo = 1, updated_at = CURRENT_TIMESTAMP(3);

  INSERT INTO auditoria(entidade, entidade_id, acao, actor_auth_user_id, correlation_id, dados_novos)
  VALUES('USUARIO_EMPRESA', CONCAT(p_empresa_id, ':', p_auth_user_id), 'VINCULADO', p_actor_auth_user_id, p_correlation_id,
         JSON_OBJECT('empresaId', p_empresa_id, 'authUserId', p_auth_user_id, 'papel', p_papel));
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_gerar_qr_operacional;
DELIMITER $$
CREATE PROCEDURE sp_gerar_qr_operacional(
  IN p_ponto_operacional_id BIGINT UNSIGNED,
  IN p_valido_de DATETIME(3),
  IN p_valido_ate DATETIME(3),
  IN p_actor_auth_user_id BIGINT UNSIGNED,
  IN p_correlation_id VARCHAR(100)
)
BEGIN
  DECLARE v_qr_id BIGINT UNSIGNED;
  DECLARE v_token CHAR(36);
  SET v_token = UUID();

  START TRANSACTION;
  INSERT INTO qr_code_operacional(ponto_operacional_id, token, status, valido_de, valido_ate)
  VALUES(p_ponto_operacional_id, v_token, 'ATIVO', p_valido_de, p_valido_ate);
  SET v_qr_id = LAST_INSERT_ID();

  INSERT INTO auditoria(entidade, entidade_id, acao, actor_auth_user_id, correlation_id, dados_novos)
  VALUES('QR_CODE_OPERACIONAL', CAST(v_qr_id AS CHAR), 'GERADO', p_actor_auth_user_id, p_correlation_id,
         JSON_OBJECT('pontoOperacionalId', p_ponto_operacional_id, 'status', 'ATIVO'));

  INSERT INTO outbox_event(event_id, aggregate_type, aggregate_id, event_type, event_version, payload)
  VALUES(UUID(), 'QR_CODE_OPERACIONAL', CAST(v_qr_id AS CHAR), 'empresa.qr-operacional.gerado.v1', 1,
         JSON_OBJECT('qrId', v_qr_id, 'pontoOperacionalId', p_ponto_operacional_id));
  COMMIT;

  SELECT v_qr_id AS qr_id, v_token AS token;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_alterar_status_qr;
DELIMITER $$
CREATE PROCEDURE sp_alterar_status_qr(
  IN p_qr_id BIGINT UNSIGNED,
  IN p_novo_status VARCHAR(20),
  IN p_motivo VARCHAR(500),
  IN p_actor_auth_user_id BIGINT UNSIGNED,
  IN p_correlation_id VARCHAR(100)
)
BEGIN
  DECLARE v_status_anterior VARCHAR(20);
  IF p_novo_status NOT IN ('ATIVO','INATIVO','BLOQUEADO') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Status de QR invalido';
  END IF;

  START TRANSACTION;
  SELECT status INTO v_status_anterior FROM qr_code_operacional WHERE id = p_qr_id FOR UPDATE;
  IF v_status_anterior IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'QR operacional nao encontrado';
  END IF;

  UPDATE qr_code_operacional
     SET status = p_novo_status,
         motivo_bloqueio = CASE WHEN p_novo_status = 'BLOQUEADO' THEN p_motivo ELSE NULL END
   WHERE id = p_qr_id;

  INSERT INTO auditoria(entidade, entidade_id, acao, actor_auth_user_id, correlation_id, dados_anteriores, dados_novos)
  VALUES('QR_CODE_OPERACIONAL', CAST(p_qr_id AS CHAR), 'STATUS_ALTERADO', p_actor_auth_user_id, p_correlation_id,
         JSON_OBJECT('status', v_status_anterior), JSON_OBJECT('status', p_novo_status, 'motivo', p_motivo));
  COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_assinar_contrato_empresa;
DELIMITER $$
CREATE PROCEDURE sp_assinar_contrato_empresa(
  IN p_contrato_id BIGINT UNSIGNED,
  IN p_auth_user_id BIGINT UNSIGNED,
  IN p_ip VARCHAR(45),
  IN p_user_agent VARCHAR(500),
  IN p_correlation_id VARCHAR(100)
)
BEGIN
  DECLARE v_status VARCHAR(20);
  START TRANSACTION;
  SELECT status INTO v_status FROM contrato_empresa WHERE id = p_contrato_id FOR UPDATE;
  IF v_status IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Contrato nao encontrado';
  END IF;
  IF v_status <> 'PENDENTE' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Contrato nao esta pendente';
  END IF;

  UPDATE contrato_empresa
     SET status = 'ASSINADO', assinado_por_auth_user_id = p_auth_user_id,
         ip_assinatura = p_ip, user_agent = p_user_agent,
         correlation_id = p_correlation_id, assinado_em = CURRENT_TIMESTAMP(3)
   WHERE id = p_contrato_id;

  INSERT INTO auditoria(entidade, entidade_id, acao, actor_auth_user_id, correlation_id, dados_novos, ip, user_agent)
  VALUES('CONTRATO_EMPRESA', CAST(p_contrato_id AS CHAR), 'ASSINADO', p_auth_user_id, p_correlation_id,
         JSON_OBJECT('status', 'ASSINADO'), p_ip, p_user_agent);
  COMMIT;
END$$
DELIMITER ;

-- ============================================================================
-- TRIGGERS DE IMUTABILIDADE
-- ============================================================================
DROP TRIGGER IF EXISTS trg_auditoria_no_update;
DROP TRIGGER IF EXISTS trg_auditoria_no_delete;
DROP TRIGGER IF EXISTS trg_contrato_assinado_no_update;
DROP TRIGGER IF EXISTS trg_contrato_assinado_no_delete;

DELIMITER $$
CREATE TRIGGER trg_auditoria_no_update
BEFORE UPDATE ON auditoria
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Registros de auditoria nao podem ser alterados';
END$$

CREATE TRIGGER trg_auditoria_no_delete
BEFORE DELETE ON auditoria
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Registros de auditoria nao podem ser excluidos';
END$$

CREATE TRIGGER trg_contrato_assinado_no_update
BEFORE UPDATE ON contrato_empresa
FOR EACH ROW
BEGIN
  IF OLD.status = 'ASSINADO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Contrato assinado e imutavel';
  END IF;
END$$

CREATE TRIGGER trg_contrato_assinado_no_delete
BEFORE DELETE ON contrato_empresa
FOR EACH ROW
BEGIN
  IF OLD.status = 'ASSINADO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Contrato assinado nao pode ser excluido';
  END IF;
END$$
DELIMITER ;

-- ============================================================================
-- VIEWS
-- ============================================================================
CREATE OR REPLACE VIEW vw_empresa_resumo AS
SELECT
  e.id,
  fn_cnpj_mascarado(e.cnpj) AS cnpj_mascarado,
  e.razao_social,
  e.nome_fantasia,
  e.email,
  e.status,
  e.cadastro_status,
  e.versao,
  (SELECT COUNT(*) FROM unidade u WHERE u.empresa_id = e.id AND u.ativo = 1) AS unidades_ativas,
  (SELECT COUNT(*) FROM usuario_empresa ue WHERE ue.empresa_id = e.id AND ue.ativo = 1) AS usuarios_ativos,
  e.created_at,
  e.updated_at
FROM empresa e;

CREATE OR REPLACE VIEW vw_estrutura_operacional AS
SELECT
  e.id AS empresa_id,
  e.razao_social,
  e.nome_fantasia,
  e.status AS empresa_status,
  u.id AS unidade_id,
  u.nome AS unidade_nome,
  u.ativo AS unidade_ativa,
  s.id AS setor_id,
  s.nome AS setor_nome,
  s.ativo AS setor_ativo,
  p.id AS ponto_operacional_id,
  p.nome AS ponto_operacional_nome,
  p.latitude,
  p.longitude,
  COALESCE(p.raio_operacao_metros, u.raio_operacao_metros) AS raio_operacao_metros,
  p.ativo AS ponto_operacional_ativo
FROM empresa e
JOIN unidade u ON u.empresa_id = e.id
JOIN setor s ON s.empresa_id = e.id AND s.unidade_id = u.id
JOIN ponto_operacional p ON p.empresa_id = e.id AND p.unidade_id = u.id AND p.setor_id = s.id;

CREATE OR REPLACE VIEW vw_qr_operacional AS
SELECT
  q.id AS qr_id,
  q.token,
  q.status AS qr_status,
  q.valido_de,
  q.valido_ate,
  q.motivo_bloqueio,
  p.id AS ponto_operacional_id,
  p.nome AS ponto_operacional_nome,
  s.id AS setor_id,
  s.nome AS setor_nome,
  u.id AS unidade_id,
  u.nome AS unidade_nome,
  e.id AS empresa_id,
  e.nome_fantasia,
  p.latitude,
  p.longitude,
  COALESCE(p.raio_operacao_metros, u.raio_operacao_metros) AS raio_operacao_metros,
  CASE
    WHEN q.status <> 'ATIVO' THEN 0
    WHEN q.valido_de IS NOT NULL AND CURRENT_TIMESTAMP(3) < q.valido_de THEN 0
    WHEN q.valido_ate IS NOT NULL AND CURRENT_TIMESTAMP(3) > q.valido_ate THEN 0
    WHEN p.ativo = 0 OR s.ativo = 0 OR u.ativo = 0 OR e.status <> 'ATIVA' THEN 0
    ELSE 1
  END AS qr_operacionalmente_valido
FROM qr_code_operacional q
JOIN ponto_operacional p ON p.id = q.ponto_operacional_id
JOIN setor s ON s.id = p.setor_id AND s.unidade_id = p.unidade_id AND s.empresa_id = p.empresa_id
JOIN unidade u ON u.id = p.unidade_id AND u.empresa_id = p.empresa_id
JOIN empresa e ON e.id = p.empresa_id;

-- ============================================================================
-- VALIDACOES FINAIS
-- ============================================================================
SELECT DATABASE() AS banco_atual;
SHOW TABLES;
SELECT TABLE_NAME
  FROM information_schema.VIEWS
 WHERE TABLE_SCHEMA = 'empresa_service'
 ORDER BY TABLE_NAME;

-- Fim do schema consolidado do Empresa Service.
