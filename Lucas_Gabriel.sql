
CREATE DATABASE hospital_db;
USE hospital_db;

CREATE TABLE paciente (
    id_paciente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    data_nascimento DATE NOT NULL,
    sexo ENUM('M', 'F') NOT NULL,
    endereco VARCHAR(200),
    telefone VARCHAR(20),
    email VARCHAR(100) UNIQUE
);

CREATE TABLE medico (
    id_medico INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    especialidade VARCHAR(100) NOT NULL,
    crm VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE consulta (
    id_consulta INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_medico INT NOT NULL,
    data_consulta DATETIME NOT NULL,
    status ENUM('Agendada', 'Realizada', 'Cancelada') DEFAULT 'Agendada',
    CONSTRAINT fk_paciente FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente) ON DELETE CASCADE,
    CONSTRAINT fk_medico FOREIGN KEY (id_medico) REFERENCES medico(id_medico) ON DELETE CASCADE
);


CREATE TABLE prontuario (
    id_prontuario INT AUTO_INCREMENT PRIMARY KEY,
    id_consulta INT UNIQUE NOT NULL,
    descricao TEXT NOT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_consulta FOREIGN KEY (id_consulta) REFERENCES consulta(id_consulta) ON DELETE CASCADE
);



CREATE TABLE auditoria_consultas (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_consulta INT NOT NULL,
    acao VARCHAR(50) NOT NULL,
    data_acao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(100) NOT NULL
);


CREATE INDEX idx_medico_data ON consulta (id_medico, data_consulta);


CREATE FULLTEXT INDEX idx_descricao ON prontuario (descricao);



CREATE VIEW view_agenda_medico AS
SELECT 
    c.id_medico,
    p.nome AS nome_paciente,
    c.data_consulta,
    c.status
FROM 
    consulta c
JOIN 
    paciente p ON c.id_paciente = p.id_paciente;



DELIMITER $$

CREATE TRIGGER trg_consulta_cancelada
AFTER UPDATE ON consulta
FOR EACH ROW
BEGIN
    IF NEW.status = 'Cancelada' THEN
        INSERT INTO auditoria_consultas (id_consulta, acao, usuario)
        VALUES (NEW.id_consulta, 'Consulta Cancelada', CURRENT_USER());
    END IF;
END $$

DELIMITER ;

Explicação

	1.	Tabelas:
	•	Criamos tabelas relacionadas com chaves estrangeiras para garantir a integridade referencial.
	•	Usamos ON DELETE CASCADE para remover automaticamente registros dependentes ao excluir um registro pai.
	2.	Auditoria:
	•	A tabela auditoria_consultas registra ações realizadas sobre as consultas, incluindo quem realizou e quando.
	3.	Índices:
	•	O índice composto em consulta otimiza consultas por médico e data.
	•	O índice full-text em prontuario facilita buscas eficientes no campo descricao.
	4.	View:
	•	A view view_agenda_medico organiza os dados de forma que o médico visualize sua agenda de maneira simplificada.
	5.	Trigger:
	•	A trigger trg_consulta_cancelada insere um registro na tabela de auditoria quando o status de uma consulta é alterado para “Cancelada”.
