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
    -- VALIDACIÓN 1: Verificar que el ISBN no exista
    IF EXISTS (SELECT 1 FROM Libros WHERE ISBN = @ISBN)
    BEGIN
        PRINT 'Error: El ISBN ya existe en el sistema'
        RETURN -1
    END
    
    -- VALIDACIÓN 2: Verificar que el autor exista
    IF NOT EXISTS (SELECT 1 FROM Autores WHERE AutorID = @AutorID)
    BEGIN
        PRINT 'Error: El autor especificado no existe'
        RETURN -1
    END
    
    -- VALIDACIÓN 3: Verificar que la editorial exista
    IF NOT EXISTS (SELECT 1 FROM Editoriales WHERE EditorialID = @EditorialID)
    BEGIN
        PRINT 'Error: La editorial especificada no existe'
        RETURN -1
    END
    
    -- VALIDACIÓN 4: Verificar que la categoría exista
    IF NOT EXISTS (SELECT 1 FROM Categorias WHERE CategoriaID = @CategoriaID)
    BEGIN
        PRINT 'Error: La categoría especificada no existe'
        RETURN -1
    END
    
    -- VALIDACIÓN 5: Año de publicación razonable
    IF @AnioPublicacion < 1500 OR @AnioPublicacion > YEAR(GETDATE())
    BEGIN
        PRINT 'Error: El año de publicación no es válido'
        RETURN -1
    END
    
    -- Insertar libro
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
    
    -- Obtener datos actuales del préstamo
    SELECT 
        @EstadoActual = Estado,
        @RenovacionesActual = Renovaciones,
        @FechaDevolucion = FechaDevolucion,
        @DiasPrestamo = DiasPrestamo
    FROM Prestamos 
    WHERE PrestamoID = @PrestamoID
    
    -- LÓGICA DE NEGOCIO 1: Verificar que el préstamo esté activo
    IF @EstadoActual != 'Activo'
    BEGIN
        PRINT 'Error: Solo se pueden renovar préstamos activos'
        RETURN -1
    END
    
    -- LÓGICA DE NEGOCIO 2: Verificar límite de renovaciones
    IF @RenovacionesActual >= @MaxRenovaciones
    BEGIN
        PRINT 'Error: Se ha alcanzado el máximo de renovaciones permitidas'
        RETURN -1
    END
    
    -- LÓGICA DE NEGOCIO 3: Verificar que no haya multas pendientes
    IF EXISTS (SELECT 1 FROM Multas WHERE PrestamoID = @PrestamoID AND Estado = 'Pendiente')
    BEGIN
        PRINT 'Error: No se puede renovar con multas pendientes'
        RETURN -1
    END
    
    -- Actualizar préstamo
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
    
    -- LÓGICA DE NEGOCIO: Identificar préstamos vencidos sin multa
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
        -- Calcular monto de multa
        SET @MontoMulta = @DiasRetraso * @TarifaDiaria
        
        -- Insertar multa
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