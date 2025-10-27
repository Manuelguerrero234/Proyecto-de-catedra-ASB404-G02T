-- =============================================
-- VERIFICACIONES ESPECÍFICAS POR TABLA
-- =============================================

USE BibliotecaDB;
GO

-- Verificación detallada de Usuarios
PRINT '=== DETALLE COMPLETO DE USUARIOS ==='
SELECT 
    UsuarioID as ID,
    Codigo as Código,
    Nombre as Nombre_Completo,
    Perfil as Tipo_Perfil,
    Email as Correo,
    Telefono as Teléfono,
    Carrera as Programa,
    CASE WHEN Activo = 1 THEN 'Activo' ELSE 'Inactivo' END as Estado
FROM Usuarios 
ORDER BY UsuarioID;
GO

-- Verificación detallada de Libros
PRINT '=== DETALLE COMPLETO DE LIBROS ==='
SELECT 
    l.LibroID as ID,
    l.Titulo as Título,
    a.Nombre as Autor,
    e.Nombre as Editorial,
    c.Nombre as Categoría,
    l.AnioPublicacion as Año,
    l.EjemplaresTotales as Total,
    l.EjemplaresDisponibles as Disponibles,
    l.ISBN,
    l.Ubicacion as Ubicación
FROM Libros l
INNER JOIN Autores a ON l.AutorID = a.AutorID
INNER JOIN Editoriales e ON l.EditorialID = e.EditorialID
INNER JOIN Categorias c ON l.CategoriaID = c.CategoriaID
ORDER BY l.LibroID;
GO

-- Verificación de integridad referencial
PRINT '=== VERIFICACIÓN DE INTEGRIDAD REFERENCIAL ==='

PRINT 'Préstamos con usuarios válidos:'
SELECT COUNT(*) as Total 
FROM Prestamos p
INNER JOIN Usuarios u ON p.UsuarioID = u.UsuarioID;
GO

PRINT 'Préstamos con libros válidos:'
SELECT COUNT(*) as Total 
FROM Prestamos p
INNER JOIN Libros l ON p.LibroID = l.LibroID;
GO

PRINT 'Reservas con usuarios y libros válidos:'
SELECT COUNT(*) as Total 
FROM Reservas r
INNER JOIN Usuarios u ON r.UsuarioID = u.UsuarioID
INNER JOIN Libros l ON r.LibroID = l.LibroID;
GO

PRINT 'Multas con préstamos válidos:'
SELECT COUNT(*) as Total 
FROM Multas m
INNER JOIN Prestamos p ON m.PrestamoID = p.PrestamoID;
GO

-- Verificación de triggers
PRINT '=== PRUEBA DE TRIGGERS ==='

PRINT 'Antes de actualizar préstamo a Devuelto:'
SELECT LibroID, EjemplaresDisponibles 
FROM Libros 
WHERE LibroID = 1;
GO

PRINT 'Actualizando préstamo a Devuelto...'
UPDATE Prestamos SET Estado = 'Devuelto' WHERE PrestamoID = 2;
GO

PRINT 'Después de actualizar préstamo a Devuelto:'
SELECT LibroID, EjemplaresDisponibles 
FROM Libros 
WHERE LibroID = 1;
GO

-- Restaurar estado original
UPDATE Prestamos SET Estado = 'Activo' WHERE PrestamoID = 2;
UPDATE Libros SET EjemplaresDisponibles = 3 WHERE LibroID = 1;
GO

PRINT '=== ESTADO FINAL DEL SISTEMA ==='
SELECT 
    (SELECT COUNT(*) FROM Usuarios WHERE Activo = 1) as Usuarios_Activos,
    (SELECT COUNT(*) FROM Libros WHERE Activo = 1) as Libros_Activos,
    (SELECT COUNT(*) FROM Prestamos WHERE Estado = 'Activo') as Prestamos_Vigentes,
    (SELECT COUNT(*) FROM Reservas WHERE Estado = 'Pendiente') as Reservas_Activas,
    (SELECT COUNT(*) FROM Multas WHERE Estado = 'Pendiente') as Multas_Sin_Pagar;
GO