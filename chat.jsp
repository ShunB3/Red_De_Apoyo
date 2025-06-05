<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    String dbUrl = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser = "root";
    String dbPassword = "";

    Integer clienteId = (Integer) session.getAttribute("userId");
    String rol = (String) session.getAttribute("rol");

    String emprendedorNombre = request.getParameter("emprendedor_nombre");

    if (clienteId == null || !"cliente".equals(rol) || emprendedorNombre == null) {
        response.sendRedirect("Login_cliente.jsp");
        return;
    }

    java.util.List<String[]> mensajes = new java.util.ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT mensaje, emisor, fecha_envio FROM mensajes_chat WHERE cliente_id = ? AND emprendedor_nombre = ? ORDER BY fecha_envio ASC"
             )) {

            ps.setInt(1, clienteId);
            ps.setString(2, emprendedorNombre);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                mensajes.add(new String[] {
                    rs.getString("mensaje"),
                    rs.getString("emisor"),
                    rs.getString("fecha_envio")
                });
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Chat con <%= emprendedorNombre %></title>
    <style>
        body {
            background-color: #121212;
            color: #e0e0e0;
            font-family: 'Segoe UI', sans-serif;
            padding: 2rem;
        }

        .chat-box {
            max-width: 700px;
            margin: 0 auto;
            background-color: #1f1f1f;
            border-radius: 8px;
            padding: 1.5rem;
            box-shadow: 0 4px 12px rgba(0,0,0,0.4);
        }

        h2 {
            text-align: center;
            margin-bottom: 1.5rem;
            color: #00a5a5;
        }

        .mensaje {
            margin-bottom: 1rem;
            padding: 0.8rem;
            border-radius: 6px;
            max-width: 80%;
            word-wrap: break-word;
        }

        .cliente {
            background-color: #006f78;
            align-self: flex-end;
            margin-left: auto;
        }

        .emprendedor {
            background-color: #444;
            align-self: flex-start;
            margin-right: auto;
        }

        .chat-log {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
            margin-bottom: 2rem;
            max-height: 400px;
            overflow-y: auto;
        }

        form textarea {
            width: 100%;
            padding: 0.8rem;
            background-color: #2a2a2a;
            border: 1px solid #555;
            border-radius: 4px;
            color: #fff;
            resize: none;
            font-size: 1rem;
        }

        button {
            margin-top: 0.8rem;
            padding: 0.6rem 1.2rem;
            background-color: #00a5a5;
            color: white;
            border: none;
            border-radius: 4px;
            font-weight: bold;
            cursor: pointer;
        }

        button:hover {
            background-color: #008080;
        }
    </style>
</head>
<body>
<div class="chat-box">
    <h2>Chat con <%= emprendedorNombre %></h2>

    <div class="chat-log">
        <% for (String[] m : mensajes) {
             String clase = "cliente".equals(m[1]) ? "mensaje cliente" : "mensaje emprendedor";
        %>
        <div class="<%= clase %>">
            <%= m[0] %> <br>
            <small style="font-size: 0.75rem; color: #ccc;"><%= m[2] %></small>
        </div>
        <% } %>
    </div>

    <form action="enviar_mensaje.jsp" method="post">
        <input type="hidden" name="cliente_id" value="<%= clienteId %>">
        <input type="hidden" name="emprendedor_nombre" value="<%= emprendedorNombre %>">
        <input type="hidden" name="emisor" value="cliente">
        <textarea name="mensaje" rows="3" required placeholder="Escribe tu mensaje..."></textarea>
        <button type="submit">Enviar</button>
    </form>
</div>
</body>
</html>
