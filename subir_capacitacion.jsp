<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    Integer adminId = (Integer) session.getAttribute("adminId");
    if (adminId == null) {
        response.sendRedirect("Login_admin.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Subir Capacitación</title>
    <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
    <style>
        body { background: #121212; color: #e0e0e0; font-family: 'Segoe UI', Arial, sans-serif; }
        form { background: #1f1f1f; padding: 2rem; border-radius: 8px; max-width: 500px; margin: 2rem auto; }
        label { display: block; margin-top: 1rem; }
        input, textarea, select { width: 100%; padding: 0.5rem; margin-top: 0.3rem; background: #2a2a2a; border: 1px solid #444; border-radius: 4px; color: #e0e0e0; }
        .btn { margin-top: 1.5rem; background: #008891; border: none; border-radius: 4px; color: white; font-weight: bold; cursor: pointer; padding: 0.75rem; }
        .btn:hover { background: #006f78; }
    </style>
    <script>
        function mostrarCampos() {
            var tipo = document.getElementById('tipo').value;
            document.getElementById('descripcion').style.display = (tipo === 'video' || tipo === 'conferencia') ? 'block' : 'none';
        }
    </script>
</head>
<body>
    <form action="subir_capacitacion_action.jsp" method="post">
        <label for="tipo">Tipo de capacitación:</label>
        <select name="tipo" id="tipo" onchange="mostrarCampos()" required>
            <option value="">Selecciona...</option>
            <option value="video">Video</option>
            <option value="curso">Curso</option>
            <option value="conferencia">Conferencia</option>
        </select>
        <label for="titulo">Título:</label>
        <input type="text" name="titulo" id="titulo" required>
        <div id="descripcion" style="display:none;">
            <label for="descripcion">Descripción:</label>
            <textarea name="descripcion"></textarea>
        </div>
        <label for="url">URL:</label>
        <input type="url" name="url" id="url" required>
        <button class="btn" type="submit">Subir</button>
    </form>
    <script>mostrarCampos();</script>
</body>
</html>