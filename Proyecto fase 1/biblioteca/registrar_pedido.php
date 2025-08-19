<?php
include 'conexion.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $id_usuario = $_POST['id_usuario'];
    $tipo_usuario = $_POST['tipo_usuario'];
    $codigo_material = $_POST['codigo_material'];
    $tipo_material = $_POST['tipo_material'];
    $fecha_reserva = $_POST['fecha_reserva'];

    $sql = "INSERT INTO Pedido (id_usuario, tipo_usuario, codigo_material, tipo_material, fecha_reserva, estado)
            VALUES ('$id_usuario', '$tipo_usuario', '$codigo_material', '$tipo_material', '$fecha_reserva', 'Reservado')";

    if ($conexion->query($sql) === TRUE) {
        header("Location: index.php?success=1");
    } else {
        header("Location: index.php?error=1");
    }
}
$conexion->close();
?>