
    
    USE master;
	CREATE DATABASE Universidade;
	GO
	USE Universidade;
	GO
	CREATE TABLE ALUNOS
	(
		MATRICULA INT NOT NULL IDENTITY
			CONSTRAINT PK_ALUNO PRIMARY KEY,
		NOME VARCHAR(50) NOT NULL
	);
	GO
	CREATE TABLE CURSOS
	(
		CURSO CHAR(3) NOT NULL
			CONSTRAINT PK_CURSO PRIMARY KEY,
		NOME VARCHAR(50) NOT NULL
	);
	GO
	CREATE TABLE PROFESSOR
	(
		PROFESSOR INT IDENTITY NOT NULL
			CONSTRAINT PK_PROFESSOR PRIMARY KEY,
		NOME VARCHAR(50) NOT NULL
	);
	GO
	CREATE TABLE MATERIAS
	(
		SIGLA CHAR(3) NOT NULL,
		NOME VARCHAR(50) NOT NULL,
		CARGAHORARIA INT NOT NULL,
		CURSO CHAR(3) NOT NULL,
		PROFESSOR INT
			CONSTRAINT PK_MATERIA
			PRIMARY KEY (
							SIGLA,
							CURSO,
							PROFESSOR
						)
			CONSTRAINT FK_CURSO
			FOREIGN KEY (CURSO) REFERENCES CURSOS (CURSO),
		CONSTRAINT FK_PROFESSOR
			FOREIGN KEY (PROFESSOR)
			REFERENCES PROFESSOR (PROFESSOR)
	);
	GO

CREATE TABLE MATRICULA
	(
		MATRICULA INT,
		CURSO CHAR(3),
		MATERIA CHAR(3),
		PROFESSOR INT,
		PERLETIVO INT,
		N1 FLOAT,
		N2 FLOAT,
		N3 FLOAT,
		N4 FLOAT,
		TOTALPONTOS FLOAT,
		MEDIA FLOAT,
		F1 INT,
		F2 INT,
		F3 INT,
		F4 INT,
		TOTALFALTAS INT,
		PERCFREQ FLOAT,
		RESULTADO VARCHAR(20)
			CONSTRAINT PK_MATRICULA
			PRIMARY KEY (
							MATRICULA,
							CURSO,
							MATERIA,
							PROFESSOR,
							PERLETIVO
						),
		CONSTRAINT FK_ALUNOS_MATRICULA
			FOREIGN KEY (MATRICULA)
			REFERENCES ALUNOS (MATRICULA),
		CONSTRAINT FK_CURSOS_MATRICULA
			FOREIGN KEY (CURSO)
			REFERENCES CURSOS (CURSO),
		
		CONSTRAINT FK_PROFESSOR_MATRICULA
			FOREIGN KEY (PROFESSOR)
			REFERENCES PROFESSOR (PROFESSOR)
	);
	
ALTER TABLE MATRICULA ADD MEDIAFINAL FLOAT
GO
ALTER TABLE MATRICULA ADD NOTAEXAME FLOAT
GO

CREATE PROCEDURE INSERT_ALUNOS
    @NOME VARCHAR(50)
AS
BEGIN
    INSERT INTO ALUNOS (NOME) VALUES (@NOME);
END

-- EXEC INSERT_ALUNOS 'Pedro';
-- select * from ALUNOS


GO

CREATE PROCEDURE INSERT_CURSOS
    @CURSO VARCHAR(10),
    @NOME VARCHAR(50)
AS


BEGIN
    INSERT INTO CURSOS (CURSO, NOME)
    VALUES (@CURSO, @NOME);
END

-- EXEC INSERT_CURSOS @CURSO = 'BSI', @NOME = 'Bacharelado em Sistemas de Informação'
-- select * from CURSOS


	GO
  
CREATE PROCEDURE INSERT_PROFESSOR
    @NOME VARCHAR(50)
AS
BEGIN
    INSERT INTO PROFESSOR (NOME) 
    VALUES (@NOME)
END

--- EXEC INSERT_PROFESSOR 'Dornel'
--- select * from PROFESSOR

GO

CREATE PROCEDURE INSERT_MATERIAS 
(
    @sigla CHAR(3),
    @nome VARCHAR(50),
    @cargahoraria INT,
    @curso CHAR(3),
    @professor INT
)
AS
BEGIN
    SET NOCOUNT ON;
    
    
    IF NOT EXISTS (SELECT 1 FROM CURSOS WHERE CURSO = @curso)
    BEGIN
        PRINT 'Curso não encontrado na tabela de cursos.';
        RETURN;
    END
    
    IF NOT EXISTS (SELECT 1 FROM PROFESSOR WHERE PROFESSOR = @professor)
    BEGIN
        PRINT 'Professor não encontrado na tabela de professores.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM MATERIAS WHERE SIGLA = @sigla AND CURSO = @curso AND PROFESSOR = @professor)
    BEGIN
        PRINT 'Matéria já cadastrada para este curso e professor.';
        RETURN;
    END

    INSERT INTO MATERIAS (SIGLA, NOME, CARGAHORARIA, CURSO, PROFESSOR)
    VALUES (@sigla, @nome, @cargahoraria, @curso, @professor);
    
    PRINT 'Matéria cadastrada com sucesso.';
END

-- EXEC INSERT_MATERIAS 'BDA', 'Banco de Dados', 80, 'BSI', 1;
-- select * from MATERIAS




GO

CREATE PROCEDURE INSERT_MATRICULA
    @MATRICULA INT,
    @CURSO CHAR(3),
    @MATERIA CHAR(3),
    @PROFESSOR INT,
    @PERLETIVO INT
AS
BEGIN
    INSERT INTO MATRICULA (MATRICULA, CURSO, MATERIA, PROFESSOR, PERLETIVO)
    VALUES (@MATRICULA, @CURSO, @MATERIA, @PROFESSOR, @PERLETIVO);
END


--EXEC INSERT_MATRICULA 1, 'BSI', 'BDA', 1, 2023
--select * from MATRICULA

GO

CREATE PROCEDURE sp_CadastraNotas
	(
		@MATRICULA INT,
		@CURSO CHAR(3),
		@MATERIA CHAR(3),
		@PERLETIVO CHAR(4),
		@NOTA FLOAT,
		@FALTA INT,
		@BIMESTRE INT
	)
	AS
BEGIN

		IF @BIMESTRE = 1
		    BEGIN

                UPDATE MATRICULA
                SET N1 = @NOTA,
                    F1 = @FALTA,
                    TOTALPONTOS = @NOTA,
                    TOTALFALTAS = @FALTA,
                    MEDIA = @NOTA
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
		    END

        ELSE 
        
        IF @BIMESTRE = 2
            BEGIN

                UPDATE MATRICULA
                SET N2 = @NOTA,
                    F2 = @FALTA,
                    TOTALPONTOS = @NOTA + N1,
                    TOTALFALTAS = @FALTA + F1,
                    MEDIA = (@NOTA + N1) / 2
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
            END

        ELSE 
        
        IF @BIMESTRE = 3
            BEGIN

                UPDATE MATRICULA
                SET N3 = @NOTA,
                    F3 = @FALTA,
                    TOTALPONTOS = @NOTA + N1 + N2,
                    TOTALFALTAS = @FALTA + F1 + F2,
                    MEDIA = (@NOTA + N1 + N2) / 3
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
            END

        ELSE 
        
        IF @BIMESTRE = 4
            BEGIN

                DECLARE @RESULTADO VARCHAR(50),
                        @FREQUENCIA FLOAT,
                        @MEDIAFINAL FLOAT,
                        @CARGAHORA INT 
                
                SET @CARGAHORA = (
                    SELECT CARGAHORARIA FROM MATERIAS 
                    WHERE       SIGLA = @MATERIA
                            AND CURSO = @CURSO)

                UPDATE MATRICULA
                SET N4 = @NOTA,
                    F4 = @FALTA,
                    TOTALPONTOS = @NOTA + N1 + N2 + N3,
                    TOTALFALTAS = @FALTA + F1 + F2 + F3,
                    MEDIA = (@NOTA + N1 + N2 + N3) / 4,
                    MEDIAFINAL = (@NOTA + N1 + N2 + N3) / 4,
                    PERCFREQ = 100 -( ((@FALTA + F1 + F2 + F3)*@CARGAHORA )/100)

                    --RESULTADO
                    ,RESULTADO = 
                    CASE 
                        WHEN ((@NOTA + N1 + N2 + N3) / 4) >= 7 
                            AND (100 -( ((@FALTA + F1 + F2 + F3)*@CARGAHORA )/100))>=75
                        THEN 'APROVADO'
                        
                        WHEN ((@NOTA + N1 + N2 + N3) / 4) >= 3 
                            AND (100 -( ((@FALTA + F1 + F2 + F3)*@CARGAHORA )/100))>=75 
                        THEN 'EXAME' 
                        
                        ELSE 'REPROVADO'
                    
                    END

                        WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;


            END
        ELSE 
        
        IF @BIMESTRE = 5

            BEGIN

                UPDATE MATRICULA
                SET NOTAEXAME = @NOTA
                --FALTA CALCULAR O RESULTADO PÓS EXAME
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
            END

		SELECT * FROM MATRICULA	WHERE MATRICULA = @MATRICULA
END


--EXEC sp_CadastraNotas @MATRICULA = 1,      -- int
                      @CURSO = 'BSI',      -- char(3)
                      @MATERIA = 'BDA',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 2,          -- int
                      @BIMESTRE = 1;      -- int
GO
--EXEC sp_CadastraNotas @MATRICULA = 1,      -- int
                      @CURSO = 'BSI',      -- char(3)
                      @MATERIA = 'BDA',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 2,         -- int  
                      @BIMESTRE = 2;      -- int
GO
--EXEC sp_CadastraNotas @MATRICULA = 1,      -- int
                      @CURSO = 'BSI',      -- char(3)
                      @MATERIA = 'BDA',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 2,         -- int 
                      @BIMESTRE = 3;      -- int
GO
--EXEC sp_CadastraNotas @MATRICULA = 1,      -- int
                      @CURSO = 'BSI',      -- char(3)
                      @MATERIA = 'BDA',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 2,          -- int
                      @BIMESTRE = 4;      -- int 

GO            

CREATE PROCEDURE NOTAEXAME (
    @MATRICULA INT,
    @CURSO CHAR(3),
    @MATERIA CHAR(3),
    @PERLETIVO INT,
    @NOTA FLOAT 
)
AS
BEGIN
    DECLARE @MEDINAFINALEXAME FLOAT
    UPDATE MATRICULA
    SET NOTAEXAME = @NOTA,
        @MEDINAFINALEXAME = ((MEDIAFINAL + @NOTA) / 2),
        MEDIAFINAL = @MEDINAFINALEXAME
         WHERE @MATRICULA = MATRICULA
         AND @CURSO = CURSO
         AND @MATERIA = MATERIA
         AND @PERLETIVO = PERLETIVO

        IF @MEDINAFINALEXAME >= 5
            UPDATE MATRICULA
            SET RESULTADO = 'APROVADO'
            WHERE @MATRICULA = MATRICULA
            AND @CURSO = CURSO
            AND @MATERIA = MATERIA
            AND @PERLETIVO = PERLETIVO

        ELSE
        UPDATE MATRICULA
        SET RESULTADO = 'REPROVADO'
        WHERE @MATRICULA = MATRICULA
        AND @CURSO = CURSO
        AND @MATERIA = MATERIA
        AND @PERLETIVO = PERLETIVO
END

---EXEC NOTAEXAME 1, 'BSI', 'BDA', 2023, 1

SELECT * FROM MATRICULA