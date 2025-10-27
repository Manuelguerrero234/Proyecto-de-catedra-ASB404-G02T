-- Trigger 1: Control autom�tico de disponibilidad al devolver libros
CREATE TRIGGER TR_ControlDevolucion_Libros
ON Prestamos
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON
    
    -- L�GICA: Cuando un pr�stamo cambia a "Devuelto", aumentar disponibilidad
    IF UPDATE(Estado)
    BEGIN
        UPDATE Libros
        SET EjemplaresDisponibles = EjemplaresDisponibles + 1
        FROM Libros l
        INNER JOIN inserted i ON l.LibroID = i.LibroID
        INNER JOIN deleted d ON i.PrestamoID = d.PrestamoID
        WHERE i.Estado = 'Devuelto' AND d.Estado != 'Devuelto'
        
        -- Actualizar fecha de devoluci�n real
        UPDATE Prestamos
        SET FechaDevolucionReal = GETDATE()
        FROM Prestamos p
        INNER JOIN inserted i ON p.PrestamoID = i.PrestamoID
        WHERE i.Estado = 'Devuelto' AND p.FechaDevolucionReal IS NULL
    END
END;
GO

-- Trigger 2: Validaci�n de pr�stamos - No permitir pr�stamos si no hay disponibilidad
CREATE TRIGGER TR_ValidarPrestamo_Disponibilidad
ON Prestamos
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON
    
    -- L�GICA: Verificar disponibilidad antes de insertar pr�stamo
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        INNER JOIN Libros l ON i.LibroID = l.LibroID
        WHERE l.EjemplaresDisponibles <= 0
    )
    BEGIN
        PRINT 'Error: No hay ejemplares disponibles para realizar el pr�stamo'
        RETURN
    END
    
    -- L�GICA: Verificar que el usuario no tenga pr�stamos vencidos
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
        PRINT 'Error: El usuario tiene pr�stamos vencidos pendientes'
        RETURN
    END
    
    -- Si pasa todas las validaciones, insertar el pr�stamo
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