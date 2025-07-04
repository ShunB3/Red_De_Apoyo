<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // 1) Validar que haya sesión (cualquier rol)
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("Login_emprendedor.jsp");
        return;
    }

    // 2) Parámetros obligatorios
    String cliParam  = request.getParameter("cliente_id");
    String empNombre = request.getParameter("emprendedor_nombre");
    String negocio   = request.getParameter("negocio");
    if (cliParam == null || empNombre == null || negocio == null) {
        out.println("Faltan parámetros para iniciar el chat.");
        return;
    }
    int clienteId = Integer.parseInt(cliParam);

    // 3) Obtener nombre del cliente
    String clienteNombre = "";
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection c = DriverManager.getConnection("jdbc:mysql://localhost:3306/red_de_apoyo","root","")) {
        PreparedStatement ps0 = c.prepareStatement("SELECT nombre FROM clientes WHERE id = ?");
        ps0.setInt(1, clienteId);
        try (ResultSet rs0 = ps0.executeQuery()) {
            if (rs0.next()) clienteNombre = rs0.getString("nombre");
        }
    }

    // 4) Cargar mensajes históricos
    class Msg { String remitente, texto, fecha; }
    List<Msg> msgs = new ArrayList<>();
    try (Connection c = DriverManager.getConnection("jdbc:mysql://localhost:3306/red_de_apoyo","root","");
         PreparedStatement ps = c.prepareStatement(
           "SELECT emisor, mensaje, DATE_FORMAT(fecha,'%Y-%m-%d %H:%i') AS fecha " +
           "FROM mensajes_chat " +
           "WHERE cliente_id=? AND emprendedor_nombre=? AND negocio=? " +
           "ORDER BY fecha"
         )) {
        ps.setInt(1, clienteId);
        ps.setString(2, empNombre);
        ps.setString(3, negocio);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Msg m = new Msg();
                m.remitente = rs.getString("emisor");   // "cliente" o "emprendedor"
                m.texto     = rs.getString("mensaje");
                m.fecha     = rs.getString("fecha");
                msgs.add(m);
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Chat con <%= clienteNombre %> – <%= negocio %></title>
    <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">

  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body {
      margin: 0; padding: 0;
      font-family: 'Segoe UI', sans-serif;
      background: #121212; color: #e0e0e0;
      display: flex; flex-direction: column; height: 100vh;
    }
    header {
      position: relative;
      background: #1f1f1f; padding: 1rem;
      text-align: center; border-bottom: 1px solid #333;
    }
    header h2 {
      margin: 0; font-size: 1.2rem;
    }
    /* Botón de volver */
    .btn-back {
      position: absolute; left: 1rem; top: 1rem;
      background: none; border: none;
      color: #00a5a5; font-size: 1rem;
      cursor: pointer;
    }
    .btn-back:hover {
      text-decoration: underline;
    }
    .chat-box {
      flex: 1; overflow-y: auto;
      padding: 1rem; display: flex; flex-direction: column;
    }
    .mensaje {
      max-width: 70%; margin-bottom: 1rem; display: flex; flex-direction: column;
    }
    .mensaje.cliente     { align-self: flex-start; }
    .mensaje.emprendedor { align-self: flex-end; }
    .burbuja {
      padding: 0.8rem 1rem; border-radius: 12px;
    }
    .mensaje.cliente     .burbuja { background: #00a5a5; border-radius:12px 12px 12px 0; }
    .mensaje.emprendedor .burbuja { background: #2a2a2a; border-radius:12px 12px 0 12px; }
    .info {
      font-size: 0.8rem; color: #aaa; margin-top: 0.3rem;
    }
    .input-area {
      padding: 1rem; background: #1f1f1f; border-top: 1px solid #333;
    }
    .input-area form {
      display: flex; gap: 0.5rem; max-width: 800px; margin: 0 auto;
    }
    .input-area input[type="text"] {
      flex: 1; padding: 0.8rem; border: none; border-radius: 4px;
      background: #2a2a2a; color: #fff;
    }
    .input-area button {
      padding: 0.8rem 1.5rem; background: #008891;
      color: #fff; border: none; border-radius: 4px; cursor: pointer;
    }
    .input-area button:hover {
      background: #006f78;
    }
    footer {
      text-align: center; padding: 0.8rem;
      background: #1f1f1f; color: #777; border-top: 1px solid #333;
    }
  </style>
</head>
<body>

<header>
  <button class="btn-back" onclick="location.href='emprendedor_home.jsp'">
    ← Volver
  </button>
  <h2>Chat con <%= clienteNombre %> – <%= negocio %></h2>
</header>

<div class="chat-box" id="chat-box">
  <% for (Msg m : msgs) { %>
    <div class="mensaje <%= m.remitente %>">
      <div class="burbuja"><%= m.texto %></div>
      <div class="info">
        <%= m.fecha %> — 
        <%= "cliente".equals(m.remitente) ? clienteNombre : "Tú" %>
      </div>
    </div>
  <% } %>
</div>

<div class="input-area">
  <form action="enviar_mensaje.jsp" method="post">
    <input type="hidden" name="cliente_id"         value="<%= clienteId %>">
    <input type="hidden" name="emprendedor_nombre" value="<%= empNombre %>">
    <input type="hidden" name="negocio"            value="<%= negocio %>">
    <input type="hidden" name="emisor"             value="emprendedor">
    <input type="text" name="mensaje" placeholder="Escribe tu mensaje..." autocomplete="off" required>
    <button type="submit">Enviar</button>
  </form>
</div>

<footer>
  &copy; 2025 Red de Apoyo a Emprendedores Locales
</footer>

<script>
  // Al cargar, hacer scroll al final
  window.addEventListener('load', () => {
    const box = document.getElementById('chat-box');
    box.scrollTop = box.scrollHeight;
  });
</script>

</body>
</html>
