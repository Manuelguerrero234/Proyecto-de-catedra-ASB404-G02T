-- Trigger 1: Control automático de disponibilidad al devolver libros
CREATE TRIGGER TR_ControlDevolucion_Libros
ON Prestamos
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON
    
    -- LÓGICA: Cuando un préstamo cambia a "Devuelto", aumentar disponibilidad
    IF UPDATE(Estado)
    BEGIN
        UPDATE Libros
        SET EjemplaresDisponibles = EjemplaresDisponibles + 1
        FROM Libros l
        INNER JOIN inserted i ON l.LibroID = i.LibroID
        INNER JOIN deleted d ON i.PrestamoID = d.PrestamoID
        WHERE i.Estado = 'Devuelto' AND d.Estado != 'Devuelto'
        
        -- Actualizar fecha de devolución real
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
    
    -- LÓGICA: Verificar disponibilidad antes de insertar préstamo
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
    
    -- LÓGICA: Verificar que el usuario no tenga préstamos vencidos
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
    
    -- Si pasa todas las validaciones, insertar el préstamo
    INSERT INTO Prestamos (
        UsuarioID, LibroID, FechaPrestamo, FechaDevolucion, 
        Estado, DiasPrestamo, Renovaciones
    )
    SELECT 
        UsuarioID, LibroID, FechaPrestamo, FechaDevolucion,
        Estado, DiasPrestamo, Renovaciones
    FROM inserted
    
    -- Actualizar disponibilidad del libro
    UPDATE Libros
    SET EjemplaresDisponibles = EjemplaresDisponibles - 1
    WHERE LibroID IN (SELECT LibroID FROM inserted)
END;
GO