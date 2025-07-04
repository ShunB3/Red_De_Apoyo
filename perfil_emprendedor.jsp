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

    // Variables de perfil
    String nombre = "", email = "", negocio = "", descripcion = "", telefono = "";
    String categoria = "", direccion = "", ciudad = "", departamento = "";
    String instagram = "", facebook = "", tiktok = "";

    class Pub { int id; String titulo, descripcion, imagenUrl; Timestamp fecha; }
    List<Pub> publicaciones = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword)) {
            // Perfil completo con redes sociales
            String sql = "SELECT nombre, email, negocio, descripcion, telefono, categoria, direccion, ciudad, departamento, instagram, facebook, tiktok FROM emprendedores WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, emprendedorId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        nombre      = rs.getString("nombre");
                        email       = rs.getString("email");
                        negocio     = rs.getString("negocio");
                        descripcion = rs.getString("descripcion");
                        telefono    = rs.getString("telefono");
                        categoria   = rs.getString("categoria");
                        direccion   = rs.getString("direccion");
                        ciudad      = rs.getString("ciudad");
                        departamento= rs.getString("departamento");
                        instagram   = rs.getString("instagram");
                        facebook    = rs.getString("facebook");
                        tiktok      = rs.getString("tiktok");
                    }
                }
            }
            // Publicaciones
            String psPub = "SELECT id, titulo, descripcion, imagen_url, fecha_publicacion FROM publicaciones WHERE emprendedor_id = ? ORDER BY fecha_publicacion DESC";
            try (PreparedStatement ps2 = conn.prepareStatement(psPub)) {
                ps2.setInt(1, emprendedorId);
                try (ResultSet rs2 = ps2.executeQuery()) {
                    while (rs2.next()) {
                        Pub p = new Pub();
                        p.id          = rs2.getInt("id");
                        p.titulo      = rs2.getString("titulo");
                        p.descripcion = rs2.getString("descripcion");
                        p.imagenUrl   = rs2.getString("imagen_url");
                        p.fecha       = rs2.getTimestamp("fecha_publicacion");
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
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Perfil de <%= nombre %></title>
  <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
  <!-- FontAwesome (JSDelivr CDN) -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.4.0/css/all.min.css" integrity="" crossorigin="anonymous">
<style>
    body {font-family:'Segoe UI',Arial,sans-serif;background:#121212;color:#fff;margin:0;min-height:100vh;display:flex;flex-direction:column;}
    header, footer {background:#1a1a1a;padding:1rem;text-align:center;}
    header h1 {margin:0;font-size:2rem;}
    header a {color:#00a5a5;text-decoration:none;font-size:.9rem;}
    header a:hover {text-decoration:underline;}
    .container {flex:1;max-width:1000px;margin:2rem auto;padding:0 1rem;display:grid;grid-template-columns:1fr 2fr;gap:2rem;}
    @media(max-width:768px){.container{grid-template-columns:1fr;}}
    .profile, .posts {background:#1f1f1f;border-radius:8px;padding:1.5rem;box-shadow:0 4px 12px rgba(0,0,0,.5);}
    .profile h2, .posts h2 {margin:0 0 .75rem;border-bottom:2px solid #00a5a5;padding-bottom:.5rem;}
    .fields-grid {display:grid;grid-template-columns:1fr 1fr;gap:1rem;}
    .field {display:flex;flex-direction:column;}
    .field label {font-weight:bold;color:#00a5a5;margin-bottom:.25rem;}
    .field .value {color:#ccc;word-wrap:break-word;}
    .social-links {display:flex;gap:1rem;margin-top:1rem;}
    .social-links a {color:#fff;text-decoration:none;}
    .social-links a:hover {opacity:.8;}
    .social-links i {transition:transform .2s;}
    .social-links i:hover {transform:scale(1.1);}
    .pub-card {display:flex;gap:1rem;background:#222;border-radius:6px;overflow:hidden;margin-bottom:1rem;}
    .pub-card img {width:180px;height:120px;object-fit:cover;}
    .pub-info {padding:1rem;flex:1;}
    .pub-info h3 {margin:0 0 .5rem;font-size:1.2rem;color:#00c1c1;}
    .pub-info p  {margin:0 0 .5rem;color:#ccc;}
    .pub-info small{color:#777;}
  </style>
</head>
<body>
  <header>
    <h1>Perfil de <%= nombre %></h1>
    <a href="cliente_home.jsp">← Volver</a>
  </header>
  <div class="container">
    <section class="profile">
      <h2>Datos del Emprendedor</h2>
      <div class="fields-grid">
        <div class="field"><label>Nombre:</label><div class="value"><%= nombre %></div></div>
        <div class="field"><label>Negocio:</label><div class="value"><%= negocio %></div></div>
        <div class="field"><label>Email:</label><div class="value"><%= email %></div></div>
        <div class="field"><label>Teléfono:</label><div class="value"><%= telefono!=null&&!telefono.trim().isEmpty()?telefono:"Sin número" %></div></div>
        <div class="field"><label>Categoría:</label><div class="value"><%= categoria %></div></div>
        <div class="field"><label>Ciudad/Depto:</label><div class="value"><%= ciudad %> / <%= departamento %></div></div>
        <div class="field" style="grid-column:1 / -1;"><label>Dirección:</label><div class="value"><%= direccion %></div></div>
        <div class="field" style="grid-column:1 / -1;"><label>Descripción:</label><div class="value"><%= descripcion %></div></div>
      </div>
      <div class="social-links">
        <% if (instagram != null && !instagram.trim().isEmpty()) { %>
          <a href="<%= instagram %>" target="_blank" title="Instagram">
            <i class="fab fa-instagram fa-2x"></i>
          </a>
        <% } %>
        <% if (facebook != null && !facebook.trim().isEmpty()) { %>
          <a href="<%= facebook %>" target="_blank" title="Facebook">
            <i class="fab fa-facebook-f fa-2x"></i>
          </a>
        <% } %>
        <% if (tiktok != null && !tiktok.trim().isEmpty()) { %>
          <a href="<%= tiktok %>" target="_blank" title="TikTok">
            <i class="fab fa-tiktok fa-2x"></i>
          </a>
        <% } %>
      </div>
    </section>
    <section class="posts">
      <h2>Publicaciones</h2>
      <% if (publicaciones.isEmpty()) { %>
        <p>No hay publicaciones.</p>
      <% } else {
           for (Pub p : publicaciones) { %>
        <div class="pub-card">
          <% if (p.imagenUrl != null && !p.imagenUrl.isEmpty()) { %>
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
