--Código de Vistas, Procedimientos y Triggers

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