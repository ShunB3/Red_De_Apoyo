<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%
    // Validar sesión de cliente
    Integer clienteId = (Integer) session.getAttribute("userId");
    String rol = (String) session.getAttribute("rol");
    if (clienteId == null || !"cliente".equals(rol)) {
        response.sendRedirect("Login_cliente.jsp");
        return;
    }

    String emprendedorNombre = request.getParameter("emprendedor_nombre");
    String negocio = request.getParameter("negocio");

    if (emprendedorNombre == null || negocio == null) {
        out.println("Error: Falta información del emprendedor.");
        return;
    }

    String dbUrl = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser = "root";
    String dbPassword = "";

    class Mensaje {
        String emisor, texto, fecha;
    }

    java.util.List<Mensaje> mensajes = new java.util.ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT emisor, mensaje, DATE_FORMAT(fecha,'%Y-%m-%d %H:%i') AS fecha " +
                 "FROM mensajes_chat " +
                 "WHERE cliente_id = ? AND emprendedor_nombre = ? AND negocio = ? " +
                 "ORDER BY fecha ASC"
             )) {
            ps.setInt(1, clienteId);
            ps.setString(2, emprendedorNombre);
            ps.setString(3, negocio);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Mensaje m = new Mensaje();
                    m.emisor = rs.getString("emisor");
                    m.texto = rs.getString("mensaje");
                    m.fecha = rs.getString("fecha");
                    mensajes.add(m);
                }
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
    <title>Chat con <%= emprendedorNombre %> – <%= negocio %></title>
      <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">

    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background-color: #121212;
            color: #e0e0e0;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }
        header {
            background-color: #1f1f1f;
            padding: 1rem;
            text-align: center;
            font-size: 1.5rem;
            color: #fff;
            position: relative;
        }
        /* Botón volver */
        .btn-back {
            position: absolute;
            left: 1rem;
            top: 1rem;
            background: none;
            border: none;
            color: #00a5a5;
            font-size: 1rem;
            cursor: pointer;
        }
        .btn-back:hover {
            text-decoration: underline;
        }
        main {
            flex: 1;
            padding: 1.5rem;
            max-width: 800px;
            margin: 0 auto;
            width: 100%;
            box-sizing: border-box;
        }
        .chat-box {
            background: #1e1e1e;
            border-radius: 8px;
            padding: 1rem;
            height: 400px;
            overflow-y: auto;
            margin-bottom: 1rem;
        }
        .mensaje {
            margin-bottom: 1rem;
            padding: 0.5rem;
            background-color: #2a2a2a;
            border-radius: 6px;
        }
        .mensaje .emisor {
            font-weight: bold;
            color: #00a5a5;
        }
        .mensaje .fecha {
            font-size: 0.8rem;
            color: #aaa;
        }
        form {
            display: flex;
            gap: 0.5rem;
        }
        input[type="text"] {
            flex: 1;
            padding: 0.6rem;
            border-radius: 4px;
            border: none;
            background: #2a2a2a;
            color: #fff;
        }
        button[type="submit"] {
            padding: 0.6rem 1rem;
            background-color: #00a5a5;
            color: white;
            border: none;
            border-radius: 4px;
            font-weight: bold;
            cursor: pointer;
        }
        button[type="submit"]:hover {
            background-color: #008080;
        }
        footer {
            background: #1f1f1f;
            text-align: center;
            padding: 1rem;
            color: #777;
        }
    </style>
</head>
<body>

<header>
    <button class="btn-back" onclick="location.href='cliente_home.jsp'">
        ← Volver
    </button>
    Chat con <%= emprendedorNombre %> – <%= negocio %>
</header>

<main>
    <div class="chat-box" id="chat-box">
        <% for (Mensaje m : mensajes) { %>
            <div class="mensaje">
                <div class="emisor"><%= m.emisor %></div>
                <div><%= m.texto %></div>
                <div class="fecha"><%= m.fecha %></div>
            </div>
        <% } %>
    </div>

    <form action="enviar_mensaje.jsp" method="post">
        <input type="hidden" name="cliente_id" value="<%= clienteId %>">
        <input type="hidden" name="emprendedor_nombre" value="<%= emprendedorNombre %>">
        <input type="hidden" name="negocio" value="<%= negocio %>">
        <input type="hidden" name="emisor" value="cliente">
        <input type="text" name="mensaje" placeholder="Escribe tu mensaje..." required>
        <button type="submit">Enviar</button>
    </form>
</main>

<footer>
    &copy; 2025 Red de Apoyo a Emprendedores
</footer>

<script>
  // Auto scroll al final del chat
  window.onload = () => {
    const chatBox = document.getElementById('chat-box');
    chatBox.scrollTop = chatBox.scrollHeight;
  };
</script>

</body>
</html>
