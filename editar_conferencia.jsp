<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    Integer adminId = (Integer) session.getAttribute("adminId");
    if (adminId == null) {
        response.sendRedirect("Login_admin.jsp");
        return;
    }

    String id = request.getParameter("id");
    String titulo = "", descripcion = "", url = "";

    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/red_de_apoyo", "root", "");
         PreparedStatement ps = conn.prepareStatement("SELECT titulo, descripcion, url FROM conferencias_capacitacion WHERE id = ?")) {
        ps.setString(1, id);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                titulo = rs.getString("titulo");
                descripcion = rs.getString("descripcion");
                url = rs.getString("url");
            }
        }
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Editar Conferencia</title>
    <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
    <style>
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            background-color: #121212;
            color: #e0e0e0;
            margin: 0;
            padding: 0;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        header {
            background: #1e1e1e;
            padding: 1rem 2rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.3);
        }

        h1 {
            margin: 0;
            font-size: 1.8rem;
        }

        .container {
            max-width: 800px;
            margin: 2rem auto;
            padding: 0 1rem;
        }

        form {
            background: #1f1f1f;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.5);
        }

        label {
            display: block;
            margin-top: 1rem;
            font-weight: 500;
        }

        input, textarea {
            width: 100%;
            padding: 0.6rem;
            margin-top: 0.4rem;
            background: #2a2a2a;
            border: 1px solid #444;
            border-radius: 4px;
            color: #e0e0e0;
            font-size: 1rem;
        }

        textarea {
            min-height: 120px;
            resize: vertical;
        }

        .buttons {
            margin-top: 2rem;
            display: flex;
            gap: 1rem;
        }

        .btn {
            padding: 0.8rem 1.5rem;
            border: none;
            border-radius: 4px;
            font-weight: bold;
            cursor: pointer;
            font-size: 1rem;
            transition: all 0.3s ease;
        }

        .btn-primary {
            background: #008891;
            color: white;
        }

        .btn-primary:hover {
            background: #006f78;
        }

        .btn-secondary {
            background: #333;
            color: #e0e0e0;
        }

        .btn-secondary:hover {
            background: #444;
        }

        .btn-danger {
            background: #dc3545;
            color: white;
        }

        .btn-danger:hover {
            background: #c82333;
        }
    </style>
</head>
<body>
    <header>
        <h1>Editar Conferencia</h1>
    </header>

    <div class="container">
        <form action="actualizar_conferencia_action.jsp" method="post">
            <input type="hidden" name="id" value="<%= id %>">
            
            <label for="titulo">Título:</label>
            <input type="text" id="titulo" name="titulo" value="<%= titulo %>" required>
            
            <label for="descripcion">Descripción:</label>
            <textarea id="descripcion" name="descripcion" required><%= descripcion %></textarea>
            
            <label for="url">URL:</label>
            <input type="url" id="url" name="url" value="<%= url %>" required>
            
            <div class="buttons">
                <button type="submit" class="btn btn-primary">Guardar Cambios</button>
                <button type="button" class="btn btn-secondary" onclick="location.href='capacitaciones_ad.jsp'">Cancelar</button>
                <button type="button" class="btn btn-danger" onclick="if(confirm('¿Estás seguro de que deseas eliminar esta conferencia?')) location.href='eliminar_conferencia_action.jsp?id=<%= id %>'">Eliminar</button>
            </div>
        </form>
    </div>
</body>
</html>