<?php include 'conexion.php'; ?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sistema de Biblioteca - UDB</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="header">
        <h1>📚 Sistema de Servicios Bibliotecarios</h1>
        <p>Universidad Don Bosco - Gestión de Préstamos</p>
    </div>

    <div class="container">
        <div class="form-section">
            <h2>📋 Registrar Nuevo Pedido</h2>
            <form action="registrar_pedido.php" method="post">
                <div class="form-group">
                    <label for="id_usuario">🔢 ID Usuario:</label>
                    <input type="number" id="id_usuario" name="id_usuario" required>
                </div>

                <div class="form-group">
                    <label for="tipo_usuario">👥 Tipo Usuario:</label>
                    <select id="tipo_usuario" name="tipo_usuario" required>
                        <option value="Lector">👤 Lector</option>
                        <option value="Bibliotecario">👨‍💼 Bibliotecario</option>
                        <option value="Escuela">🏫 Escuela</option>
                        <option value="Docente">👨‍🏫 Docente</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="codigo_material">🏷️ Código Material:</label>
                    <input type="text" id="codigo_material" name="codigo_material" required>
                </div>

                <div class="form-group">
                    <label for="tipo_material">📦 Tipo Material:</label>
                    <select id="tipo_material" name="tipo_material" required>
                        <option value="Libro">📗 Libro</option>
                        <option value="Revista">📰 Revista</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="fecha_reserva">📅 Fecha Reserva:</label>
                    <input type="date" id="fecha_reserva" name="fecha_reserva" required>
                </div>

                <button type="submit" class="btn">✅ Registrar Pedido</button>
            </form>
        </div>

        <div class="table-section">
            <h2>📊 Lista de Pedidos Registrados</h2>
            <?php
            $sql = "SELECT * FROM Pedido ORDER BY fecha_reserva DESC";
            $result = $conexion->query($sql);

            if ($result->num_rows > 0) {
                echo "<table class='pedidos-table'>
                        <tr>
                            <th>ID</th>
                            <th>Usuario</th>
                            <th>Tipo</th>
                            <th>Material</th>
                            <th>Tipo</th>
                            <th>Reserva</th>
                            <th>Entrega</th>
                            <th>Estado</th>
                        </tr>";
                while($row = $result->fetch_assoc()) {
                    $estado_class = $row['estado'] == 'Reservado' ? 'estado-reservado' : 'estado-entregado';
                    echo "<tr>
                            <td>".$row['id_pedido']."</td>
                            <td>".$row['id_usuario']."</td>
                            <td>".$row['tipo_usuario']."</td>
                            <td>".$row['codigo_material']."</td>
                            <td>".$row['tipo_material']."</td>
                            <td>".$row['fecha_reserva']."</td>
                            <td>".($row['fecha_entrega'] ? $row['fecha_entrega'] : 'Pendiente')."</td>
                            <td><span class='$estado_class'>".$row['estado']."</span></td>
                        </tr>";
                }
                echo "</table>";
            } else {
                echo "<p style='text-align: center; color: #7f8c8d;'>No hay pedidos registrados todavía.</p>";
            }
            $conexion->close();
            ?>
        </div>
    </div>

    <div class="footer">
        <p>Sistema desarrollado para Universidad Don Bosco - © 2025</p>
    </div>
</body>
</html>