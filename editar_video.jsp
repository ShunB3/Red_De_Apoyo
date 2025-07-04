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
         PreparedStatement ps = conn.prepareStatement("SELECT titulo, descripcion, url FROM videos_capacitacion WHERE id = ?")) {
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
    <title>Editar Video</title>
    <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
    <style>
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            background-color: #121212;
            color: #e0e0e0;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background: #1e1e1e;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }
        h1 {
            color: #008891;
            text-align: center;
            margin-bottom: 30px;
        }
        form {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }
        label {
            font-weight: bold;
            margin-bottom: 5px;
        }
        input[type="text"], textarea {
            width: 100%;
            padding: 8px;
            border: 1px solid #444;
            border-radius: 4px;
            background: #2a2a2a;
            color: #e0e0e0;
        }
        textarea {
            height: 100px;
            resize: vertical;
        }
        .buttons {
            display: flex;
            gap: 10px;
            justify-content: center;
            margin-top: 20px;
        }
        button {
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: bold;
        }
        .save-btn {
            background: #008891;
            color: white;
        }
        .save-btn:hover {
            background: #006f78;
        }
        .delete-btn {
            background: #dc3545;
            color: white;
        }
        .delete-btn:hover {
            background: #bb2d3b;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Editar Video</h1>
        <form action="actualizar_video_action.jsp" method="post">
            <input type="hidden" name="id" value="<%= id %>">
            
            <div>
                <label for="titulo">Título:</label>
                <input type="text" id="titulo" name="titulo" value="<%= titulo %>" required>
            </div>
            
            <div>
                <label for="descripcion">Descripción:</label>
                <textarea id="descripcion" name="descripcion" required><%= descripcion %></textarea>
            </div>
            
            <div>
                <label for="url">URL del Video:</label>
                <input type="text" id="url" name="url" value="<%= url %>" required>
            </div>
            
            <div class="buttons">
                <button type="submit" class="save-btn">Guardar Cambios</button>
                <button type="button" onclick="location.href='capacitaciones_ad.jsp'" style="background: #444; color: white;">Cancelar</button>
                <button type="button" class="delete-btn" onclick="if(confirm('¿Estás seguro de que deseas eliminar este video?')) location.href='eliminar_video_action.jsp?id=<%= id %>'">
                    Eliminar Video
                </button>
            </div>
        </form>
    </div>
</body>
</html>