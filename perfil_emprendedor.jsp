<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.net.URLEncoder, java.util.*" %>
<%
    // 1) Validar sesión de cliente
    Integer clienteId = (Integer) session.getAttribute("userId");
    String rol = (String) session.getAttribute("rol");
    if (clienteId == null || !"cliente".equals(rol)) {
        response.sendRedirect("Login_cliente.jsp");
        return;
    }

    // 2) Leer emprendedor_id
    String empParam = request.getParameter("emprendedor_id");
    if (empParam == null) {
        out.println("<p style='color:red;'>Falta el parámetro de emprendedor.</p>");
        return;
    }
    int emprendedorId = Integer.parseInt(empParam);

    // 3) Conexión a BD
    String dbUrl      = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser     = "root";
    String dbPassword = "";

    String nombre      = "", email = "", negocio = "", descripcion = "", telefono = "";

    class Pub { int id; String titulo, descripcion, imagenUrl; Timestamp fecha; }
    java.util.List<Pub> publicaciones = new java.util.ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl,dbUser,dbPassword)) {
            // Perfil + teléfono
            try (PreparedStatement ps = conn.prepareStatement(
                "SELECT nombre, email, negocio, descripcion, telefono FROM emprendedores WHERE id = ?"
            )) {
                ps.setInt(1, emprendedorId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        nombre      = rs.getString("nombre");
                        email       = rs.getString("email");
                        negocio     = rs.getString("negocio");
                        descripcion = rs.getString("descripcion");
                        telefono    = rs.getString("telefono");
                    }
                }
            }
            // Publicaciones
            try (PreparedStatement ps = conn.prepareStatement(
                "SELECT id, titulo, descripcion, imagen_url, fecha_publicacion " +
                "FROM publicaciones WHERE emprendedor_id = ? ORDER BY fecha_publicacion DESC"
            )) {
                ps.setInt(1, emprendedorId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Pub p = new Pub();
                        p.id          = rs.getInt("id");
                        p.titulo      = rs.getString("titulo");
                        p.descripcion = rs.getString("descripcion");
                        p.imagenUrl   = rs.getString("imagen_url");
                        p.fecha       = rs.getTimestamp("fecha_publicacion");
                        publicaciones.add(p);
                    }
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace(new java.io.PrintWriter(out));
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Perfil de <%= nombre %></title>
    <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">

  <style>
    body {
      font-family: 'Segoe UI', Arial, sans-serif;
      background-color: #121212;
      color: #fff;
      margin: 0; padding: 0;
      display: flex; flex-direction: column;
      min-height: 100vh;
    }
    header {
      background: #1a1a1a;
      padding: 1rem;
      text-align: center;
      box-shadow: 0 2px 8px rgba(0,0,0,0.5);
    }
    header h1 { margin: 0; font-size: 2rem; }
    header a { color: #00a5a5; text-decoration: none; font-size: 0.9rem; }
    header a:hover { text-decoration: underline; }

    .container {
      flex: 1;
      max-width: 1000px;
      margin: 2rem auto;
      padding: 0 1rem;
      display: flex;
      gap: 2rem;
    }
    .profile, .posts {
      background: #1f1f1f;
      border-radius: 8px;
      padding: 1.5rem;
      box-shadow: 0 4px 12px rgba(0,0,0,0.5);
    }
    .profile { flex: 1; }
    .profile h2 {
      margin-top: 0;
      border-bottom: 2px solid #00a5a5;
      padding-bottom: 0.5rem;
    }
    .profile .field {
      margin-bottom: 1rem;
    }
    .profile .field label {
      font-weight: bold;
      display: block;
      margin-bottom: 0.25rem;
    }
    .profile .field .value {
      color: #ccc;
    }
    .profile .field .value a {
      color: #00a5a5;
      text-decoration: none;
      font-weight: bold;
    }
    .profile .field .value a:hover {
      text-decoration: underline;
    }

    .posts { flex: 2; }
    .posts h2 {
      margin-top: 0;
      border-bottom: 2px solid #00a5a5;
      padding-bottom: 0.5rem;
    }
    .pub-card {
      display: flex; gap: 1rem;
      background: #222; border-radius: 6px;
      overflow: hidden; margin-bottom: 1rem;
    }
    .pub-card img {
      width: 180px; height: 120px;
      object-fit: cover;
    }
    .pub-info {
      padding: 1rem; flex: 1;
    }
    .pub-info h3 {
      margin: 0 0 0.5rem; font-size: 1.2rem;
      color: #00c1c1;
    }
    .pub-info p {
      margin: 0 0 0.5rem; color: #ccc;
    }
    .pub-info small {
      color: #777;
    }

    footer {
      text-align: center;
      padding: 1rem;
      background: #1a1a1a;
      color: #888;
      margin-top: auto;
    }
  </style>
</head>
<body>
  <header>
    <h1>Perfil de <%= nombre %></h1>
    <a href="cliente_home.jsp">← Volver</a>
  </header>
  <div class="container">
    <section class="profile">
      <h2>Datos Personales</h2>
      <div class="field">
        <label>Nombre:</label>
        <div class="value"><%= nombre %></div>
      </div>
      <div class="field">
        <label>Email:</label>
        <div class="value"><%= email %></div>
      </div>
      <div class="field">
        <label>Teléfono:</label>
        <div class="value">
          <% if (telefono != null && !telefono.trim().isEmpty()) { 
               String telClean = telefono.replaceAll("\\D+", "");
               String waLink = "https://wa.me/" + telClean;
          %>
            <a href="<%= waLink %>" target="_blank">📱 <%= telefono %></a>
          <% } else { %>
            Sin número de contacto
          <% } %>
        </div>
      </div>
      <div class="field">
        <label>Negocio:</label>
        <div class="value"><%= negocio %></div>
      </div>
      <div class="field">
        <label>Descripción:</label>
        <div class="value"><%= descripcion %></div>
      </div>
    </section>

    <section class="posts">
      <h2>Publicaciones</h2>
      <% if (publicaciones.isEmpty()) { %>
        <p>No hay publicaciones.</p>
      <% } else {
           for (Pub p : publicaciones) { %>
        <div class="pub-card">
          <% if (p.imagenUrl != null) { %>
            <img src="<%= p.imagenUrl %>" alt="Imagen de <%= p.titulo %>"/>
          <% } %>
          <div class="pub-info">
            <h3><%= p.titulo %></h3>
            <p><%= p.descripcion %></p>
            <small><%= p.fecha.toLocalDateTime().toLocalDate() %></small>
          </div>
        </div>
      <% } } %>
    </section>
  </div>
  <footer>&copy; 2025 Red de Apoyo a Emprendedores Locales</footer>
</body>
</html>
