<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    // 1) Validar que haya sesión activa (podría ser opcional si solo lo llaman desde mentores autenticados)
    Integer mentorId = (Integer) session.getAttribute("userId");
    String rol = (String) session.getAttribute("rol");
    if (mentorId == null || !"mentor".equals(rol)) {
        response.sendRedirect("Login_mentor.jsp");
        return;
    }

    // 2) Obtener el ID del emprendedor de la URL
    String emprIdStr = request.getParameter("emprendedor_id");
    int emprendedorId = 0;
    if (emprIdStr != null) {
        try {
            emprendedorId = Integer.parseInt(emprIdStr);
        } catch (NumberFormatException ex) {
            emprendedorId = 0;
        }
    }
    if (emprendedorId == 0) {
        out.println("<p style='color:red;'>Error: no se recibió un emprendedor válido.</p>");
        return;
    }

    // 3) Conexión a la base de datos
    String dbUrl  = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser = "root";
    String dbPass = "";

    // 4) Clase interna para cada publicación
    class Publicacion {
        int id;
        String titulo;
        String descripcion;
        String imagenUrl;
        Timestamp fechaPublicacion;
    }
    java.util.List<Publicacion> publicaciones = new java.util.ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass)) {
            // 5) Consulta: seleccionamos todos los campos necesarios, usando la columna fecha_publicacion
            String sql = 
              "SELECT id, titulo, descripcion, imagen_url, fecha_publicacion " +
              "FROM publicaciones " +
              "WHERE emprendedor_id = ? " +
              "ORDER BY fecha_publicacion DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, emprendedorId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Publicacion pub = new Publicacion();
                        pub.id               = rs.getInt("id");
                        pub.titulo           = rs.getString("titulo");
                        pub.descripcion      = rs.getString("descripcion");
                        pub.imagenUrl        = rs.getString("imagen_url");
                        pub.fechaPublicacion = rs.getTimestamp("fecha_publicacion");
                        publicaciones.add(pub);
                    }
                }
            }
        }
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error al cargar publicaciones: " + e.getMessage() + "</p>");
        e.printStackTrace(new java.io.PrintWriter(out));
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Publicaciones del Emprendedor</title>
  <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
  <style>
    body {
      background: #121212;
      color: #e0e0e0;
      font-family: 'Segoe UI', Arial, sans-serif;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: column;
      min-height: 100vh;
    }
    header {
      background: #1e1e1e;
      padding: 1rem 2rem;
      box-shadow: 0 2px 10px rgba(0,0,0,0.5);
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
    header h1 {
      margin: 0;
      font-size: 1.8rem;
      color: #00a5a5;
    }
    header a {
      background: #008891;
      color: #fff;
      padding: 0.5rem 1rem;
      border-radius: 6px;
      text-decoration: none;
      font-size: 0.9rem;
      transition: background 0.3s;
    }
    header a:hover {
      background: #006f78;
    }
    main {
      flex: 1;
      padding: 2rem 1.5rem;
      max-width: 1200px;
      margin: 0 auto;
    }
    h2 {
      text-align: center;
      margin-bottom: 2rem;
      color: #00a5a5;
      font-size: 1.6rem;
    }
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 1.5rem;
    }
    .card {
      background: #1f1f1f;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.5);
      overflow: hidden;
      transition: transform 0.3s, box-shadow 0.3s;
      display: flex;
      flex-direction: column;
      height: 100%;
    }
    .card:hover {
      transform: translateY(-5px);
      box-shadow: 0 8px 16px rgba(0,0,0,0.7);
    }
    .card img {
      width: 100%;
      height: 180px;
      object-fit: cover;
      background: #333;
    }
    .card .info {
      padding: 1rem;
      flex: 1;
      display: flex;
      flex-direction: column;
    }
    .card h3 {
      margin-bottom: 0.5rem;
      font-size: 1.25rem;
      color: #00c1c1;
    }
    .card .fecha {
      font-size: 0.85rem;
      color: #aaa;
      margin-bottom: 0.75rem;
    }
    .card p {
      flex: 1;
      font-size: 0.95rem;
      color: #ccc;
      margin-bottom: 1rem;
      line-height: 1.4;
      overflow: hidden;
    }
    .card .btn-back {
      margin-top: 1rem;
      background: #008891;
      color: #fff;
      padding: 0.6rem;
      text-align: center;
      border: none;
      border-radius: 6px;
      text-decoration: none;
      font-size: 0.9rem;
      transition: background 0.3s;
      align-self: flex-start;
    }
    .card .btn-back:hover {
      background: #006f78;
    }
    .empty-state {
      grid-column: 1 / -1;
      text-align: center;
      padding: 2rem;
      background: #1f1f1f;
      border-radius: 8px;
      color: #aaa;
      font-size: 1.2rem;
    }
    footer {
      background: #1e1e1e;
      color: #777;
      text-align: center;
      padding: 1rem;
      margin-top: auto;
    }
  </style>
</head>
<body>
  <header>
    <h1>Publicaciones del Emprendedor</h1>
    <a href="mis_mentoreados.jsp">← Volver</a>
  </header>
  <main>
    <h2>Lista de Publicaciones</h2>
    <div class="grid">
      <% if (publicaciones.isEmpty()) { %>
        <div class="empty-state">
          Este emprendedor aún no tiene publicaciones.
        </div>
      <% } else {
           for (Publicacion p : publicaciones) { %>
        <div class="card">
          <% if (p.imagenUrl != null && !p.imagenUrl.trim().isEmpty()) { %>
            <img src="<%= p.imagenUrl %>" alt="Imagen de <%= p.titulo %>">
          <% } else { %>
            <img src="images/default-business.jpg" alt="Sin imagen disponible">
          <% } %>
          <div class="info">
            <h3><%= p.titulo %></h3>
            <div class="fecha">
              Publicado: <%= p.fechaPublicacion.toLocalDateTime().toLocalDate() %>
            </div>
            <p><%= p.descripcion != null ? p.descripcion : "Sin descripción." %></p>
            <a href="mis_mentoreados.jsp" class="btn-back">← Regresar</a>
          </div>
        </div>
      <%   }
         } %>
    </div>
  </main>
  <footer>
    &copy; 2025 Red de Apoyo a Emprendedores Locales
  </footer>
</body>
</html>
