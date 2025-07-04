<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    String dbUrl      = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser     = "root";
    String dbPassword = "";

    Integer clienteId = (Integer) session.getAttribute("userId");
    String rol        = (String) session.getAttribute("rol");
    if (clienteId == null || !"cliente".equals(rol)) {
        response.sendRedirect("Login_cliente.jsp");
        return;
    }

    // Clase interna actualizada
    class Pub {
        int id;
        String titulo;
        String descripcion;
        int emprId;            // id del emprendedor
        String negocio;
        String emprNombre;
        String imagenUrl;
        boolean isFav;
    }

    java.util.List<Pub> list = new java.util.ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
             PreparedStatement ps = conn.prepareStatement(
               "SELECT " +
               "  p.id, p.titulo, p.descripcion, p.emprendedor_id, p.imagen_url, " +
               "  e.negocio, e.nombre, " +
               "  EXISTS(" +
               "    SELECT 1 FROM favoritos f " +
               "    WHERE f.cliente_id = ? AND f.publicacion_id = p.id" +
               "  ) AS is_fav " +
               "FROM publicaciones p " +
               "JOIN emprendedores e ON p.emprendedor_id = e.id " +
               "ORDER BY p.fecha_publicacion DESC"
             )) {

            ps.setInt(1, clienteId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Pub item = new Pub();
                    item.id          = rs.getInt("id");
                    item.titulo      = rs.getString("titulo");
                    item.descripcion = rs.getString("descripcion");
                    item.emprId      = rs.getInt("emprendedor_id");
                    item.imagenUrl   = rs.getString("imagen_url");
                    item.negocio     = rs.getString("negocio");
                    item.emprNombre  = rs.getString("nombre");
                    item.isFav       = rs.getBoolean("is_fav");
                    list.add(item);
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
  <title>Emprendimientos</title>
  <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
  <style>
    /* ===== Reset & Tema oscuro ===== */
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    body {
      font-family: 'Segoe UI', Arial, sans-serif;
      background-color: #121212;
      color: #ffffff;
      display: flex;
      flex-direction: column;
      min-height: 100vh;
    }

    /* ===== Header ===== */
    header {
      background-color: #1a1a1a;
      padding: 20px 0;
      box-shadow: 0 2px 10px rgba(0,0,0,0.5);
      display: flex;
      justify-content: center;
      align-items: center;
      position: relative;
    }
    header h1 {
      font-size: 2.2rem;
      color: #fff;
      position: relative;
    }
    header h1::after {
      content: '';
      position: absolute;
      bottom: -8px;
      left: 50%;
      transform: translateX(-50%);
      width: 80px;
      height: 3px;
      background: #00a5a5;
    }

    /* ===== Botón “Menú” ===== */
    .menu-button {
      position: absolute;
      right: 20px;
      top: 50%;
      transform: translateY(-50%);
      background-color: #00a5a5;
      color: #fff;
      border: none;
      padding: 10px 20px;
      border-radius: 4px;
      cursor: pointer;
      font-weight: bold;
      font-size: 16px;
      transition: background-color 0.3s;
      z-index: 2;
    }
    .menu-button:hover {
      background-color: #008080;
    }

    /* ===== Dropdown menú ===== */
    .dropdown {
      position: relative;
      display: inline-block;
    }
    .dropdown-content {
      display: none;
      position: fixed;
      background-color: #1f1f1f;
      min-width: 200px;
      box-shadow: 0 8px 16px rgba(0,0,0,0.5);
      border-radius: 4px;
      z-index: 1000;
      right: 20px;   /* alineado con el botón */
      top: 80px;     /* justo debajo del header */
      border: 1px solid #333;
      animation: slideInRight 0.3s ease-out;
    }
    @keyframes slideInRight {
      from {
        transform: translateX(100%);
        opacity: 0;
      }
      to {
        transform: translateX(0);
        opacity: 1;
      }
    }
    .dropdown-content a {
      color: #fff;
      padding: 12px 16px;
      text-decoration: none;
      display: block;
      transition: background-color 0.3s;
    }
    .dropdown-content a:hover {
      background-color: #00a5a5;
    }
    .dropdown-content a:first-child {
      border-top-left-radius: 4px;
      border-top-right-radius: 4px;
    }
    .dropdown-content a:last-child {
      border-bottom-left-radius: 4px;
      border-bottom-right-radius: 4px;
      border-bottom: none;
    }
    .dropdown.active .dropdown-content {
      display: block;
    }

    /* ===== Main ===== */
    main {
      flex: 1;
      padding: 2rem 0;
    }
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 1.8rem;
      max-width: 1200px;
      margin: 2rem auto;
      padding: 0 1.5rem;
    }

    /* ===== Card de publicación ===== */
    .card {
      background: #1f1f1f;
      border-radius: 8px;
      overflow: hidden;
      box-shadow: 0 4px 12px rgba(0,0,0,0.5);
      display: flex;
      flex-direction: column;
      transition: transform 0.3s, box-shadow 0.3s;
      height: 100%;
    }
    .card:hover {
      transform: translateY(-5px);
      box-shadow: 0 8px 16px rgba(0,0,0,0.6);
    }
    .card img {
      width: 100%;
      height: 200px;
      object-fit: cover;
      border-bottom: 3px solid #00a5a5;
    }
    .info {
      padding: 1.2rem;
      flex: 1;
      display: flex;
      flex-direction: column;
    }
    .info h3 {
      margin-bottom: 0.8rem;
      font-size: 1.3rem;
      color: #fff;
    }
    .info p {
      margin-bottom: 0.8rem;
      font-size: 0.95rem;
      color: #ccc;
    }
    .meta {
      margin-bottom: 1rem;
      font-size: 0.95rem;
      color: #e0e0e0;
    }
    .meta a {
      color: #00c1c1;
      text-decoration: none;
    }
    .meta a:hover {
      text-decoration: underline;
    }
    .action-buttons {
      display: flex;
      gap: 0.5rem;
      margin-top: auto;
    }
    .btn-fav, .btn-chat {
      flex: 1;
      padding: 0.5rem 1rem;
      border: none;
      border-radius: 4px;
      font-weight: bold;
      cursor: pointer;
      transition: background-color 0.3s;
    }
    .btn-fav {
      background-color: #00a5a5;
      color: #fff;
    }
    .btn-fav:hover {
      background-color: #008080;
    }
    .btn-fav.disabled {
      background-color: #555;
      cursor: default;
      opacity: 0.6;
    }
    .btn-chat {
      background-color: #444;
      color: #fff;
    }
    .btn-chat:hover {
      background-color: #333;
    }
    .empty-message {
      grid-column: 1/-1;
      text-align: center;
      padding: 2rem;
      background: #1f1f1f;
      border-radius: 8px;
      color: #aaa;
      font-size: 1.2rem;
    }

    /* ===== Footer ===== */
    footer {
      text-align: center;
      padding: 20px;
      background-color: #1a1a1a;
      color: #888;
      margin-top: auto;
      box-shadow: 0 -2px 10px rgba(0,0,0,0.3);
    }
  </style>
</head>
<body>
  <!-- ===== HEADER ===== -->
  <header>
    <h1>Emprendimientos</h1>
    <button class="menu-button" onclick="toggleDropdown()">Menú</button>
    <div class="dropdown">
      <div class="dropdown-content" id="dropdown-menu">
        <a href="cliente_perfil.jsp">Perfil</a>
        <a href="calendario_cl.jsp">Calendario</a>
        <a href="cliente_home.jsp">Emprendimientos</a>
        <a href="Logout.jsp" style="color:#ff4d4d;font-weight:bold;">Cerrar sesión</a>
      </div>
    </div>
  </header>

  <!-- ===== MAIN ===== -->
  <main>
    <div class="grid">
      <% if (list.isEmpty()) { %>
        <div class="empty-message">
          <p>No hay emprendimientos para mostrar en este momento.</p>
        </div>
      <% } else {
           for (Pub p : list) {
      %>
      <div class="card">
        <img src="<%= (p.imagenUrl != null && !p.imagenUrl.isEmpty()) ? p.imagenUrl : "images/default.jpg" %>"
             alt="Imagen de <%= p.titulo %>">
        <div class="info">
          <!-- Nombre del producto -->
          <h3><%= p.titulo %></h3>
          <!-- Descripción del producto -->
          <p><%= p.descripcion %></p>
          <!-- Nombre del negocio (enlace) y emprendedor -->
          <div class="meta">
            <strong>Negocio:</strong>
            <a href="perfil_emprendedor.jsp?emprendedor_id=<%= p.emprId %>">
              <%= p.negocio %>
            </a><br>
            <strong>Emprendedor:</strong> <%= p.emprNombre %>
          </div>
          <!-- Botones Favorito y Chatear lado a lado -->
          <div class="action-buttons">
            <% if (!p.isFav) { %>
              <form action="guardar_favorito.jsp" method="post" style="flex:1;">
                <input type="hidden" name="cliente_id" value="<%= clienteId %>">
                <input type="hidden" name="publicacion_id" value="<%= p.id %>">
                <button type="submit" class="btn-fav">★ Favorito</button>
              </form>
            <% } else { %>
              <button class="btn-fav disabled" disabled>★ Favorito</button>
            <% } %>
            <form action="chat_directo.jsp" method="get" style="flex:1;">
              <input type="hidden" name="cliente_id" value="<%= clienteId %>">
              <input type="hidden" name="emprendedor_nombre" value="<%= p.emprNombre %>">
              <input type="hidden" name="negocio" value="<%= p.negocio %>">
              <button type="submit" class="btn-chat">💬 Chatear</button>
            </form>
          </div>
        </div>
      </div>
      <% } } %>
    </div>
  </main>

  <!-- ===== Footer ===== -->
  <footer>
    <p>&copy; 2025 Red de Apoyo a Emprendedores</p>
  </footer>

  <script>
    function toggleDropdown() {
      const dropdown = document.querySelector('.dropdown');
      dropdown.classList.toggle('active');
    }
    // Cerrar dropdown al hacer clic fuera del botón
    window.onclick = function(event) {
      if (!event.target.matches('.menu-button')) {
        const dropdown = document.querySelector('.dropdown');
        if (dropdown.classList.contains('active')) {
          dropdown.classList.remove('active');
        }
      }
    }
  </script>
</body>
</html>
