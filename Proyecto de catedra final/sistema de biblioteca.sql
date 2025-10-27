-- Crear base de datos
CREATE DATABASE BibliotecaDB;
GO

USE BibliotecaDB;
GO

-- Tabla de Usuarios
CREATE TABLE Usuarios (
    UsuarioID INT IDENTITY(1,1) PRIMARY KEY,
    Codigo VARCHAR(20) UNIQUE NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Perfil VARCHAR(20) NOT NULL CHECK (Perfil IN ('Estudiante', 'Profesor', 'Administrador')),
    Telefono VARCHAR(20),
    Carrera VARCHAR(100),
    Direccion TEXT,
    FechaRegistro DATETIME DEFAULT GETDATE(),
    Activo BIT DEFAULT 1
);
GO

-- Tabla de Categorías
CREATE TABLE Categorias (
    CategoriaID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Descripcion TEXT
);
GO

-- Tabla de Editoriales
CREATE TABLE Editoriales (
    EditorialID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Direccion TEXT,
    Telefono VARCHAR(20)
);
GO

-- Tabla de Autores
CREATE TABLE Autores (
    AutorID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Nacionalidad VARCHAR(50),
    FechaNacimiento DATE,
    Biografia TEXT
);
GO

-- Tabla de Libros
CREATE TABLE Libros (
    LibroID INT IDENTITY(1,1) PRIMARY KEY,
    ISBN VARCHAR(20) UNIQUE,
    Titulo VARCHAR(255) NOT NULL,
    AutorID INT NOT NULL,
    EditorialID INT NOT NULL,
    CategoriaID INT NOT NULL,
    AnioPublicacion INT,
    Edicion VARCHAR(20),
    Paginas INT,
    Idioma VARCHAR(20) DEFAULT 'Español',
    Descripcion TEXT,
    EjemplaresTotales INT DEFAULT 1,
    EjemplaresDisponibles INT DEFAULT 0,
    Ubicacion VARCHAR(50),
    FechaRegistro DATETIME DEFAULT GETDATE(),
    Activo BIT DEFAULT 1,
    FOREIGN KEY (AutorID) REFERENCES Autores(AutorID),
    FOREIGN KEY (EditorialID) REFERENCES Editoriales(EditorialID),
    FOREIGN KEY (CategoriaID) REFERENCES Categorias(CategoriaID)
);
GO

-- Tabla de Préstamos
CREATE TABLE Prestamos (
    PrestamoID INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioID INT NOT NULL,
    LibroID INT NOT NULL,
    FechaPrestamo DATETIME DEFAULT GETDATE(),
    FechaDevolucion DATE NOT NULL,
    FechaDevolucionReal DATETIME,
    Estado VARCHAR(20) DEFAULT 'Activo' CHECK (Estado IN ('Activo', 'Devuelto', 'Vencido', 'Perdido')),
    Renovaciones INT DEFAULT 0,
    DiasPrestamo INT DEFAULT 15,
    Observaciones TEXT,
    FOREIGN KEY (UsuarioID) REFERENCES Usuarios(UsuarioID),
    FOREIGN KEY (LibroID) REFERENCES Libros(LibroID)
);
GO

-- Tabla de Reservas
CREATE TABLE Reservas (
    ReservaID INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioID INT NOT NULL,
    LibroID INT NOT NULL,
    FechaReserva DATETIME DEFAULT GETDATE(),
    FechaExpiracion DATETIME,
    Estado VARCHAR(20) DEFAULT 'Pendiente' CHECK (Estado IN ('Pendiente', 'Activa', 'Cancelada', 'Completada')),
    Prioridad INT DEFAULT 1,
    FOREIGN KEY (UsuarioID) REFERENCES Usuarios(UsuarioID),
    FOREIGN KEY (LibroID) REFERENCES Libros(LibroID)
);
GO

-- Tabla de Multas
CREATE TABLE Multas (
    MultaID INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioID INT NOT NULL,
    PrestamoID INT NOT NULL,
    Monto DECIMAL(10,2) NOT NULL,
    FechaMulta DATETIME DEFAULT GETDATE(),
    FechaPago DATETIME,
    Estado VARCHAR(20) DEFAULT 'Pendiente' CHECK (Estado IN ('Pendiente', 'Pagada', 'Cancelada')),
    Motivo TEXT,
    DiasRetraso INT,
    FOREIGN KEY (UsuarioID) REFERENCES Usuarios(UsuarioID),
    FOREIGN KEY (PrestamoID) REFERENCES Prestamos(PrestamoID)
);
GO

-- Insertar Categorías
INSERT INTO Categorias (Nombre, Descripcion) VALUES
('Literatura', 'Novelas y obras literarias clásicas y contemporáneas'),
('Ciencia Ficción', 'Libros de ciencia ficción, fantasía y futurismo'),
('Ciencias Exactas', 'Matemáticas, física, química y biología'),
('Tecnología', 'Informática, programación y desarrollo tecnológico'),
('Historia', 'Libros históricos, biografías y análisis social');
GO

-- Insertar Editoriales
INSERT INTO Editoriales (Nombre, Direccion, Telefono) VALUES
('Penguin Random House', 'New York, USA', '+1 212-782-9000'),
('Editorial Planeta', 'Barcelona, España', '+34 93-492-7000'),
('McGraw-Hill Education', 'New York, USA', '+1 212-904-6000'),
('Editorial Norma', 'Bogotá, Colombia', '+57 1-744-0700'),
('Fondo de Cultura Económica', 'Ciudad de México, México', '+52 55-544-0633');
GO

-- Insertar Autores
INSERT INTO Autores (Nombre, Nacionalidad, FechaNacimiento, Biografia) VALUES
('Gabriel García Márquez', 'Colombiano', '1927-03-06', 'Premio Nobel de Literatura 1982'),
('George Orwell', 'Británico', '1903-06-25', 'Escritor y periodista británico'),
('Isaac Asimov', 'Ruso-Americano', '1920-01-02', 'Escritor y profesor de bioquímica'),
('J.K. Rowling', 'Británica', '1965-07-31', 'Escritora de la serie Harry Potter'),
('Mario Vargas Llosa', 'Peruano', '1936-03-28', 'Premio Nobel de Literatura 2010');
GO

-- Insertar Usuarios
INSERT INTO Usuarios (Codigo, Nombre, Email, PasswordHash, Perfil, Telefono, Carrera) VALUES
('ESTU001', 'Carlos Andrés López', 'carlos.lopez@universidad.edu', 'estudiante123', 'Estudiante', '+57 300 123 4567', 'Ingeniería de Sistemas'),
('ESTU002', 'María Fernanda García', 'maria.garcia@universidad.edu', 'estudiante456', 'Estudiante', '+57 301 234 5678', 'Medicina'),
('PROF001', 'Ana Isabel Martínez', 'ana.martinez@universidad.edu', 'profesor123', 'Profesor', '+57 302 345 6789', 'Literatura'),
('PROF002', 'Roberto Carlos Díaz', 'roberto.diaz@universidad.edu', 'profesor456', 'Profesor', '+57 303 456 7890', 'Matemáticas'),
('ADMIN001', 'Administrador Sistema', 'admin@biblioteca.edu', 'admin123', 'Administrador', '+57 304 567 8901', 'Sistemas');
GO

-- Insertar Libros
INSERT INTO Libros (ISBN, Titulo, AutorID, EditorialID, CategoriaID, AnioPublicacion, Edicion, Paginas, EjemplaresTotales, EjemplaresDisponibles, Ubicacion, Descripcion) VALUES
('978-843-972-572-5', 'Cien años de soledad', 1, 2, 1, 1967, '1ra', 471, 5, 5, 'EST-A001', 'Una obra maestra del realismo mágico'),
('978-849-989-094-6', '1984', 2, 1, 2, 1949, '1ra', 326, 3, 3, 'EST-B001', 'Novela distópica sobre el control totalitario'),
('978-846-633-487-3', 'La ciudad y los perros', 5, 2, 1, 1962, '1ra', 408, 4, 4, 'EST-A002', 'Primera novela del boom latinoamericano'),
('978-607-16-3917-8', 'Fundación', 3, 3, 2, 1951, '1ra', 255, 2, 2, 'EST-B002', 'Clásico de la ciencia ficción'),
('978-847-888-445-5', 'Harry Potter y la piedra filosofal', 4, 1, 2, 1997, '1ra', 309, 6, 6, 'EST-B003', 'Primer libro de la serie Harry Potter');
GO

-- Insertar Préstamos
INSERT INTO Prestamos (UsuarioID, LibroID, FechaPrestamo, FechaDevolucion, Estado, DiasPrestamo) VALUES
(1, 1, '2024-01-15', '2024-01-30', 'Activo', 15),
(2, 3, '2024-01-10', '2024-01-25', 'Devuelto', 15),
(3, 2, '2024-01-20', '2024-02-04', 'Activo', 15),
(1, 4, '2024-01-05', '2024-01-20', 'Vencido', 15),
(4, 5, '2024-01-18', '2024-02-02', 'Activo', 15);
GO

-- Insertar Reservas
INSERT INTO Reservas (UsuarioID, LibroID, FechaReserva, FechaExpiracion, Estado, Prioridad) VALUES
(2, 1, '2024-01-26', '2024-01-30', 'Pendiente', 1),
(3, 4, '2024-01-25', '2024-01-29', 'Pendiente', 1),
(1, 2, '2024-01-22', '2024-01-26', 'Completada', 1),
(4, 3, '2024-01-24', '2024-01-28', 'Cancelada', 1),
(2, 5, '2024-01-27', '2024-01-31', 'Pendiente', 1);
GO

-- Insertar Multas
INSERT INTO Multas (UsuarioID, PrestamoID, Monto, FechaMulta, Estado, Motivo, DiasRetraso) VALUES
(1, 4, 7500.00, '2024-01-21', 'Pendiente', 'Devolución tardía', 5),
(2, 2, 2500.00, '2024-01-26', 'Pagada', 'Daño menor en libro', 2),
(3, 3, 0.00, '2024-01-22', 'Cancelada', 'Error del sistema', 0),
(1, 1, 0.00, '2024-01-15', 'Pagada', 'Multa preventiva', 0),
(4, 5, 5000.00, '2024-01-19', 'Pendiente', 'Pérdida temporal', 3);
GO

-- Vista 1: Libros Disponibles con información completa
CREATE VIEW VW_LibrosDisponibles_Completo AS
SELECT 
    l.LibroID,
    l.Titulo,
    a.Nombre AS Autor,
    a.Nacionalidad,
    e.Nombre AS Editorial,
    c.Nombre AS Categoria,
    l.AnioPublicacion,
    l.EjemplaresDisponibles,
    l.ISBN,
    l.Ubicacion,
    l.Descripcion
FROM Libros l
INNER JOIN Autores a ON l.AutorID = a.AutorID
INNER JOIN Editoriales e ON l.EditorialID = e.EditorialID
INNER JOIN Categorias c ON l.CategoriaID = c.CategoriaID
WHERE l.Activo = 1 AND l.EjemplaresDisponibles > 0;
GO

-- Vista 2: Préstamos Activos con detalles extendidos
CREATE VIEW VW_Prestamos_Detallados AS
SELECT 
    p.PrestamoID,
    u.Codigo AS CodigoUsuario,
    u.Nombre AS NombreUsuario,
    u.Perfil,
    u.Email,
    l.Titulo AS Libro,
    a.Nombre AS Autor,
    e.Nombre AS Editorial,
    p.FechaPrestamo,
    p.FechaDevolucion,
    p.Estado,
    DATEDIFF(DAY, GETDATE(), p.FechaDevolucion) AS DiasRestantes,
    p.Renovaciones
FROM Prestamos p
INNER JOIN Usuarios u ON p.UsuarioID = u.UsuarioID
INNER JOIN Libros l ON p.LibroID = l.LibroID
INNER JOIN Autores a ON l.AutorID = a.AutorID
INNER JOIN Editoriales e ON l.EditorialID = e.EditorialID
WHERE p.Estado = 'Activo';
GO

-- Vista 3: Reporte de Multas Pendientes
CREATE VIEW VW_Multas_Pendientes AS
SELECT 
    m.MultaID,
    u.Codigo AS CodigoUsuario,
    u.Nombre AS NombreUsuario,
    u.Perfil,
    l.Titulo AS Libro,
    p.FechaPrestamo,
    p.FechaDevolucion,
    m.Monto,
    m.FechaMulta,
    m.DiasRetraso,
    m.Motivo
FROM Multas m
INNER JOIN Usuarios u ON m.UsuarioID = u.UsuarioID
INNER JOIN Prestamos p ON m.PrestamoID = p.PrestamoID
INNER JOIN Libros l ON p.LibroID = l.LibroID
WHERE m.Estado = 'Pendiente';
GO

-- Procedimiento 1: INGRESO DE DATOS CON VALIDACIÓN - Registrar Nuevo Libro
CREATE PROCEDURE sp_RegistrarNuevoLibro
    @ISBN VARCHAR(20),
    @Titulo VARCHAR(255),
    @AutorID INT,
    @EditorialID INT,
    @CategoriaID INT,
    @AnioPublicacion INT,
    @EjemplaresTotales INT,
    @Ubicacion VARCHAR(50),
    @Descripcion TEXT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Libros WHERE ISBN = @ISBN)
    BEGIN
        PRINT 'Error: El ISBN ya existe en el sistema'
        RETURN -1
    END
    
    IF NOT EXISTS (SELECT 1 FROM Autores WHERE AutorID = @AutorID)
    BEGIN
        PRINT 'Error: El autor especificado no existe'
        RETURN -1
    END
    
    IF NOT EXISTS (SELECT 1 FROM Editoriales WHERE EditorialID = @EditorialID)
    BEGIN
        PRINT 'Error: La editorial especificada no existe'
        RETURN -1
    END
    
    IF NOT EXISTS (SELECT 1 FROM Categorias WHERE CategoriaID = @CategoriaID)
    BEGIN
        PRINT 'Error: La categoría especificada no existe'
        RETURN -1
    END
    
    IF @AnioPublicacion < 1500 OR @AnioPublicacion > YEAR(GETDATE())
    BEGIN
        PRINT 'Error: El año de publicación no es válido'
        RETURN -1
    END
    
    INSERT INTO Libros (
        ISBN, Titulo, AutorID, EditorialID, CategoriaID, 
        AnioPublicacion, EjemplaresTotales, EjemplaresDisponibles, 
        Ubicacion, Descripcion
    )
    VALUES (
        @ISBN, @Titulo, @AutorID, @EditorialID, @CategoriaID,
        @AnioPublicacion, @EjemplaresTotales, @EjemplaresTotales,
        @Ubicacion, @Descripcion
    )
    
    PRINT 'Libro registrado exitosamente: ' + @Titulo
    RETURN 1
END;
GO

-- Procedimiento 2: LÓGICA DE NEGOCIO - Renovar Préstamo
CREATE PROCEDURE sp_RenovarPrestamo
    @PrestamoID INT,
    @UsuarioID INT
AS
BEGIN
    DECLARE @EstadoActual VARCHAR(20)
    DECLARE @RenovacionesActual INT
    DECLARE @FechaDevolucion DATE
    DECLARE @DiasPrestamo INT
    DECLARE @MaxRenovaciones INT = 2
    
    SELECT 
        @EstadoActual = Estado,
        @RenovacionesActual = Renovaciones,
        @FechaDevolucion = FechaDevolucion,
        @DiasPrestamo = DiasPrestamo
    FROM Prestamos 
    WHERE PrestamoID = @PrestamoID
    
    IF @EstadoActual != 'Activo'
    BEGIN
        PRINT 'Error: Solo se pueden renovar préstamos activos'
        RETURN -1
    END
    
    IF @RenovacionesActual >= @MaxRenovaciones
    BEGIN
        PRINT 'Error: Se ha alcanzado el máximo de renovaciones permitidas'
        RETURN -1
    END
    
    IF EXISTS (SELECT 1 FROM Multas WHERE PrestamoID = @PrestamoID AND Estado = 'Pendiente')
    BEGIN
        PRINT 'Error: No se puede renovar con multas pendientes'
        RETURN -1
    END
    
    UPDATE Prestamos 
    SET FechaDevolucion = DATEADD(DAY, @DiasPrestamo, @FechaDevolucion),
        Renovaciones = @RenovacionesActual + 1
    WHERE PrestamoID = @PrestamoID
    
    PRINT 'Préstamo renovado exitosamente. Nueva fecha: ' + CONVERT(VARCHAR, DATEADD(DAY, @DiasPrestamo, @FechaDevolucion))
    RETURN 1
END;
GO

-- Procedimiento 3: LÓGICA DE NEGOCIO - Calcular y Aplicar Multas Automáticas
CREATE PROCEDURE sp_CalcularMultasAutomaticas
AS
BEGIN
    DECLARE @PrestamoID INT, @UsuarioID INT, @DiasRetraso INT, @MontoMulta DECIMAL(10,2)
    DECLARE @TarifaDiaria DECIMAL(10,2) = 500.00
    DECLARE @MultasAplicadas INT = 0
    
    DECLARE PrestamosVencidos CURSOR FOR
    SELECT 
        p.PrestamoID,
        p.UsuarioID,
        DATEDIFF(DAY, p.FechaDevolucion, GETDATE()) AS DiasRetraso
    FROM Prestamos p
    WHERE p.Estado = 'Activo'
    AND p.FechaDevolucion < CAST(GETDATE() AS DATE)
    AND NOT EXISTS (
        SELECT 1 FROM Multas m 
        WHERE m.PrestamoID = p.PrestamoID AND m.Estado = 'Pendiente'
    )
    
    OPEN PrestamosVencidos
    FETCH NEXT FROM PrestamosVencidos INTO @PrestamoID, @UsuarioID, @DiasRetraso
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @MontoMulta = @DiasRetraso * @TarifaDiaria
        
        INSERT INTO Multas (UsuarioID, PrestamoID, Monto, Estado, Motivo, DiasRetraso)
        VALUES (@UsuarioID, @PrestamoID, @MontoMulta, 'Pendiente', 'Devolución tardía automática', @DiasRetraso)
        
        SET @MultasAplicadas = @MultasAplicadas + 1
        
        PRINT 'Multa aplicada - Préstamo: ' + CAST(@PrestamoID AS VARCHAR) + 
              ', Días: ' + CAST(@DiasRetraso AS VARCHAR) + 
              ', Monto: $' + CAST(@MontoMulta AS VARCHAR)
        
        FETCH NEXT FROM PrestamosVencidos INTO @PrestamoID, @UsuarioID, @DiasRetraso
    END
    
    CLOSE PrestamosVencidos
    DEALLOCATE PrestamosVencidos
    
    PRINT 'Proceso completado. Multas aplicadas: ' + CAST(@MultasAplicadas AS VARCHAR)
    RETURN @MultasAplicadas
END;
GO

-- Trigger 1: Control automático de disponibilidad al devolver libros
CREATE TRIGGER TR_ControlDevolucion_Libros
ON Prestamos
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON
    
    IF UPDATE(Estado)
    BEGIN
        UPDATE Libros
        SET EjemplaresDisponibles = EjemplaresDisponibles + 1
        FROM Libros l
        INNER JOIN inserted i ON l.LibroID = i.LibroID
        INNER JOIN deleted d ON i.PrestamoID = d.PrestamoID
        WHERE i.Estado = 'Devuelto' AND d.Estado != 'Devuelto'
        
        UPDATE Prestamos
        SET FechaDevolucionReal = GETDATE()
        FROM Prestamos p
        INNER JOIN inserted i ON p.PrestamoID = i.PrestamoID
        WHERE i.Estado = 'Devuelto' AND p.FechaDevolucionReal IS NULL
    END
END;
GO

-- Trigger 2: Validación de préstamos - No permitir préstamos si no hay disponibilidad
CREATE TRIGGER TR_ValidarPrestamo_Disponibilidad
ON Prestamos
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON
    
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        INNER JOIN Libros l ON i.LibroID = l.LibroID
        WHERE l.EjemplaresDisponibles <= 0
    )
    BEGIN
        PRINT 'Error: No hay ejemplares disponibles para realizar el préstamo'
        RETURN
    END
    
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        INNER JOIN Usuarios u ON i.UsuarioID = u.UsuarioID
        WHERE EXISTS (
            SELECT 1 FROM Prestamos p 
            WHERE p.UsuarioID = u.UsuarioID 
            AND p.Estado = 'Vencido'
        )
    )
    BEGIN
        PRINT 'Error: El usuario tiene préstamos vencidos pendientes'
        RETURN
    END
    
    INSERT INTO Prestamos (
        UsuarioID, LibroID, FechaPrestamo, FechaDevolucion, 
        Estado, DiasPrestamo, Renovaciones
    )
    SELECT 
        UsuarioID, LibroID, FechaPrestamo, FechaDevolucion,
        Estado, DiasPrestamo, Renovaciones
    FROM inserted
    
    UPDATE Libros
    SET EjemplaresDisponibles = EjemplaresDisponibles - 1
    WHERE LibroID IN (SELECT LibroID FROM inserted)
END;
GO

-- Crear roles específicos
CREATE ROLE rol_estudiante;
CREATE ROLE rol_profesor;
CREATE ROLE rol_administrador;
GO

-- ROL 1: ESTUDIANTE (Permisos limitados)
GRANT SELECT ON VW_LibrosDisponibles_Completo TO rol_estudiante;
GRANT SELECT ON VW_Prestamos_Detallados TO rol_estudiante;
GRANT EXECUTE ON sp_RenovarPrestamo TO rol_estudiante;
GRANT SELECT, INSERT ON Reservas TO rol_estudiante;
GRANT SELECT ON Prestamos TO rol_estudiante;
GRANT SELECT ON Multas TO rol_estudiante;
DENY DELETE ON Reservas TO rol_estudiante;
DENY INSERT, UPDATE, DELETE ON Prestamos TO rol_estudiante;
DENY INSERT, UPDATE, DELETE ON Multas TO rol_estudiante;
GO

-- ROL 2: PROFESOR (Permisos extendidos)
GRANT SELECT ON VW_LibrosDisponibles_Completo TO rol_profesor;
GRANT SELECT ON VW_Prestamos_Detallados TO rol_profesor;
GRANT SELECT ON VW_Multas_Pendientes TO rol_profesor;
GRANT EXECUTE ON sp_RenovarPrestamo TO rol_profesor;
GRANT EXECUTE ON sp_CalcularMultasAutomaticas TO rol_profesor;
GRANT SELECT, INSERT, UPDATE ON Reservas TO rol_profesor;
GRANT SELECT, INSERT ON Prestamos TO rol_profesor;
GRANT SELECT ON Multas TO rol_profesor;
DENY DELETE ON Prestamos TO rol_profesor;
DENY INSERT, UPDATE, DELETE ON Multas TO rol_profesor;
GO

-- ROL 3: ADMINISTRADOR (Permisos completos)
GRANT SELECT, INSERT, UPDATE, DELETE ON Usuarios TO rol_administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON Libros TO rol_administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON Prestamos TO rol_administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON Reservas TO rol_administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON Multas TO rol_administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON Autores TO rol_administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON Editoriales TO rol_administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON Categorias TO rol_administrador;
GRANT EXECUTE ON sp_RegistrarNuevoLibro TO rol_administrador;
GRANT EXECUTE ON sp_RenovarPrestamo TO rol_administrador;
GRANT EXECUTE ON sp_CalcularMultasAutomaticas TO rol_administrador;
GRANT SELECT ON VW_LibrosDisponibles_Completo TO rol_administrador;
GRANT SELECT ON VW_Prestamos_Detallados TO rol_administrador;
GRANT SELECT ON VW_Multas_Pendientes TO rol_administrador;
GO

-- Crear usuarios de ejemplo para cada rol
CREATE LOGIN usuario_estudiante WITH PASSWORD = 'Estudiante_2024!';
CREATE LOGIN usuario_profesor WITH PASSWORD = 'Profesor_2024!';
CREATE LOGIN usuario_admin WITH PASSWORD = 'Admin_2024!';
GO

CREATE USER usuario_estudiante FOR LOGIN usuario_estudiante;
CREATE USER usuario_profesor FOR LOGIN usuario_profesor;
CREATE USER usuario_admin FOR LOGIN usuario_admin;
GO

-- Asignar usuarios a roles
ALTER ROLE rol_estudiante ADD MEMBER usuario_estudiante;
ALTER ROLE rol_profesor ADD MEMBER usuario_profesor;
ALTER ROLE rol_administrador ADD MEMBER usuario_admin;
GO


