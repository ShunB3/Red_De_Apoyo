<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
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
  <title>Capacitaciones Administrador</title>
  <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">

  <!-- ****************** FUENTES ****************** -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link
    href="https://fonts.googleapis.com/css2?family=Noto+Sans:wght@300;400;500;700&display=swap"
    rel="stylesheet"
  />
  <style>
    /* Aplica Noto Sans en todo el documento */
    html, body, h1, h2, h3, h4, h5, h6,
    p, a, button, input, textarea, select,
    table, th, td, ul, li, nav, header, footer {
      font-family: 'Noto Sans', sans-serif !important;
      -webkit-font-smoothing: antialiased;
      -moz-osx-font-smoothing: grayscale;
    }

    /* ===== Reset & Tema oscuro ===== */
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background: #121212;
      color: #fff;
      display: flex;
      flex-direction: column;
      min-height: 100vh;
    }
    /* ===== Header / Nav ===== */
    header {
      background: #1e1e1e;
      padding: 1rem 2rem;
      display: flex;
      align-items: center;
      justify-content: space-between;
      box-shadow: 0 2px 8px rgba(0,0,0,0.5);
    }
    header h1 {
      font-size: 1.8rem;
    }
    .nav-buttons {
      display: flex;
      gap: 1rem;
    }
    .nav-buttons .btn {
      padding: 0.6rem 1.2rem;
      background: #008891;
      color: #fff;
      border: none;
      border-radius: 4px;
      text-decoration: none;
      font-weight: bold;
      cursor: pointer;
      transition: background 0.3s;
    }
    .nav-buttons .btn:hover {
      background: #006f78;
    }

    .container {
      flex: 1;
      max-width: 1200px;
      margin: 2rem auto;
      padding: 0 1rem;
    }
    h2.section-title {
      text-align: center;
      font-size: 1.8rem;
      margin-bottom: 1rem;
      position: relative;
      padding-bottom: 0.5rem;
      color: #00a5a5;
    }
    h2.section-title:after {
      content: '';
      position: absolute;
      bottom: 0; left: 50%;
      transform: translateX(-50%);
      width: 60px; height: 3px;
      background: #00a5a5;
    }

    /* ===== Videos Capacitaciones ===== */
    .videos-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 1.5rem;
      margin-bottom: 3rem;
    }
    .video-card {
      background: #232323;
      border-radius: 8px;
      overflow: hidden;
      transition: transform 0.3s;
      position: relative;
    }
    .video-card:hover {
      transform: translateY(-5px);
    }
    .video-card .video-container {
      position: relative;
      width: 100%;
      padding-bottom: 56.25%;
    }
    .video-card .video-container iframe {
      position: absolute;
      top: 0; left: 0;
      width: 100%; height: 100%;
      border: none;
    }
    .video-card .video-info {
      padding: 1rem;
      text-align: center;
    }
    .video-card .video-info h3 {
      font-size: 1.1rem;
      margin-bottom: 0.5rem;
      color: #fff;
    }

    /* ===== Cursos ===== */
    .courses-list {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
      gap: 1rem;
      margin-bottom: 3rem;
    }
    .course-item {
      position: relative;
      display: flex;
      flex-direction: column;
    }
    .courses-list a.course-link {
      display: flex;
      align-items: center;
      justify-content: center;
      background: #232323;
      border: 1px solid #00a5a5;
      border-radius: 6px;
      padding: 0.75rem 1rem;
      color: #00c1c1;
      font-size: 1.1rem;
      text-decoration: none;
      transition: background 0.3s, color 0.3s, transform 0.2s;
    }
    .courses-list a.course-link::before {
      content: "🎓";
      margin-right: 0.5rem;
      font-size: 1.2rem;
    }
    .courses-list a.course-link:hover {
      background: #00a5a5;
      color: #121212;
      transform: translateY(-2px);
    }

    /* ===== Charlas y Conferencias ===== */
    .talks-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 1.5rem;
      margin-bottom: 3rem;
    }
    .talk-card {
      background: #1f1f1f;
      border-radius: 8px;
      padding: 1rem;
      text-align: center;
      box-shadow: 0 2px 8px rgba(0,0,0,0.3);
      transition: transform 0.3s;
      position: relative;
    }
    .talk-card:hover {
      transform: translateY(-3px);
    }
    .talk-card h3 {
      font-size: 1.2rem;
      margin-bottom: 0.5rem;
      color: #00a5a5;
    }
    .talk-card p {
      font-size: 0.95rem;
      color: #ccc;
      margin-bottom: 1rem;
    }
    .talk-card button {
      padding: 0.5rem 1rem;
      background: #008891;
      color: #fff;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      transition: background 0.3s;
    }
    .talk-card button:hover {
      background: #006f78;
    }

    /* ===== Botones de acción ===== */
    .action-buttons {
      position: absolute;
      top: 10px;
      right: 10px;
      display: flex;
      gap: 5px;
      z-index: 10;
    }
    
    .edit-btn, .delete-btn {
      border: none;
      border-radius: 4px;
      padding: 5px 8px;
      cursor: pointer;
      font-size: 12px;
      transition: background 0.3s;
    }
    
    .edit-btn {
      background: #008891;
      color: white;
    }
    .edit-btn:hover {
      background: #006f78;
    }
    
    .delete-btn {
      background: #dc3545;
      color: white;
    }
    .delete-btn:hover {
      background: #c82333;
    }

    /* ===== Modal ===== */
    .modal {
      display: none;
      position: fixed;
      top: 0; left: 0;
      width: 100%; height: 100%;
      background: rgba(0,0,0,0.7);
      justify-content: center;
      align-items: center;
      padding: 1rem;
    }
    .modal-content {
      background: #1f1f1f;
      width: 100%;
      max-width: 800px;
      max-height: 80%;
      overflow-y: auto;
      position: relative;
      border-radius: 6px;
    }
    .modal-close {
      position: absolute; top: 0.5rem; right: 0.75rem;
      background: none; border: none;
      font-size: 1.5rem; color: #888;
      cursor: pointer;
    }
    .modal-close:hover { color: #fff; }
    .modal .video-container {
      position: relative;
      width: 100%;
      padding-bottom: 56.25%;
    }
    .modal .video-container iframe {
      position: absolute;
      top: 0; left: 0;
      width: 100%; height: 100%;
      border: none;
    }

    footer {
      background: #1a1a1a;
      text-align: center;
      padding: 1rem;
      color: #888;
      margin-top: auto;
    }

    /* ===== Responsive ===== */
    @media(max-width: 992px) {
      .videos-grid { grid-template-columns: repeat(2,1fr); }
      .talks-grid  { grid-template-columns: 1fr; }
    }
    @media(max-width: 600px) {
      .videos-grid { grid-template-columns: 1fr; }
    }
  </style>
</head>
<body>
  <header>
    <h1>Capacitaciones Administrador</h1>
    <div class="nav-buttons">
      <a href="admin_home.jsp" class="btn">← Panel</a>
      <a href="subir_capacitacion.jsp" class="btn">+ Subir Capacitación</a>
      <a href="Logout.jsp" class="btn">Cerrar sesión</a>
    </div>
  </header>

  <div class="container">
    <!-- Sección: Videos Capacitación -->
    <h2 class="section-title">Videos Capacitación</h2>
    <div class="videos-grid">
      <%
        try (Connection conn = DriverManager.getConnection(
               "jdbc:mysql://localhost:3306/red_de_apoyo","root",""
             );
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(
               "SELECT id, titulo, url FROM videos_capacitacion ORDER BY fecha_creacion DESC"
             )) {
          while (rs.next()) {
            String url = rs.getString("url");
            int id = rs.getInt("id");
            String titulo = rs.getString("titulo");
            String videoId = "";
            if (url.contains("watch?v=")) videoId = url.split("watch\\?v=")[1];
            else if (url.contains("youtu.be/")) videoId = url.split("youtu.be/")[1];
            if (videoId.contains("&")) videoId = videoId.split("&")[0];
            String embed = "https://www.youtube.com/embed/" + videoId;
      %>
      <div class="video-card">
        <div class="action-buttons">
          <button class="edit-btn" onclick="location.href='editar_video.jsp?id=<%= id %>'" title="Editar">✎</button>
          <button class="delete-btn" onclick="confirmarEliminarVideo(<%= id %>, '<%= titulo.replace("'", "\\'") %>')" title="Eliminar">🗑</button>
        </div>
        <div class="video-container">
          <iframe src="<%= embed %>" allowfullscreen></iframe>
        </div>
        <div class="video-info">
          <h3><%= titulo %></h3>
        </div>
      </div>
      <%  }
        } catch(Exception e) {
          out.println("<p>Error al cargar videos: "+e.getMessage()+"</p>");
        }
      %>
    </div>

    <!-- Sección: Cursos -->
    <h2 class="section-title">Cursos</h2>
    <div class="courses-list">
      <%
        try (Connection conn = DriverManager.getConnection(
               "jdbc:mysql://localhost:3306/red_de_apoyo","root",""
             );
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(
               "SELECT id, titulo, url FROM cursos_capacitacion ORDER BY fecha_creacion DESC"
             )) {
          while (rs.next()) {
            int id = rs.getInt("id");
            String titulo = rs.getString("titulo");
      %>
      <div class="course-item">
        <div class="action-buttons">
          <button class="edit-btn" onclick="location.href='editar_curso.jsp?id=<%= id %>'" title="Editar">✎</button>
          <button class="delete-btn" onclick="confirmarEliminarCurso(<%= id %>, '<%= titulo.replace("'", "\\'") %>')" title="Eliminar">🗑</button>
        </div>
        <a href="<%= rs.getString("url") %>" target="_blank" class="course-link">
          <%= titulo %>
        </a>
      </div>
      <%  }
        } catch(Exception e) {
          out.println("<p>Error al cargar cursos: "+e.getMessage()+"</p>");
        }
      %>
    </div>

    <!-- Sección: Charlas & Conferencias -->
    <h2 class="section-title">Charlas & Conferencias</h2>
    <div class="talks-grid">
      <%
        try (Connection conn = DriverManager.getConnection(
               "jdbc:mysql://localhost:3306/red_de_apoyo","root",""
             );
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(
               "SELECT id, titulo, descripcion, url FROM conferencias_capacitacion ORDER BY fecha_creacion DESC"
             )) {
          while (rs.next()) {
            int id = rs.getInt("id");
            String titulo = rs.getString("titulo");
      %>
      <div class="talk-card">
        <div class="action-buttons">
          <button class="edit-btn" onclick="location.href='editar_conferencia.jsp?id=<%= id %>'" title="Editar">✎</button>
          <button class="delete-btn" onclick="confirmarEliminarConferencia(<%= id %>, '<%= titulo.replace("'", "\\'") %>')" title="Eliminar">🗑</button>
        </div>
        <a href="<%= rs.getString("url") %>" target="_blank" class="talk-link">
          <h3><%= titulo %></h3>
          <p><%= rs.getString("descripcion") %></p>
        </a>
      </div>
      <%  }
        } catch(Exception e) {
          out.println("<p>Error al cargar conferencias: "+e.getMessage()+"</p>");
        }
      %>
    </div>
  </div>

  <!-- Modal Global -->
  <div id="videoModal" class="modal">
    <div class="modal-content">
      <button class="modal-close" onclick="closeModal()">&times;</button>
      <div class="video-container">
        <iframe id="modalIframe" src="" allowfullscreen></iframe>
      </div>
    </div>
  </div>

  <script>
    function openModal(src) {
      document.getElementById('modalIframe').src = src;
      document.getElementById('videoModal').style.display = 'flex';
    }
    function closeModal() {
      document.getElementById('modalIframe').src = '';
      document.getElementById('videoModal').style.display = 'none';
    }
    window.addEventListener('click', e => {
      if (e.target.id === 'videoModal') closeModal();
    });

    // Funciones de confirmación para eliminar
    function confirmarEliminarVideo(id, titulo) {
      if (confirm('¿Estás seguro de que deseas eliminar el video "' + titulo + '"?\n\nEsta acción no se puede deshacer.')) {
        window.location.href = 'eliminar_video_action.jsp?id=' + id;
      }
    }

    function confirmarEliminarCurso(id, titulo) {
      if (confirm('¿Estás seguro de que deseas eliminar el curso "' + titulo + '"?\n\nEsta acción no se puede deshacer.')) {
        window.location.href = 'eliminar_curso_action.jsp?id=' + id;
      }
    }

    function confirmarEliminarConferencia(id, titulo) {
      if (confirm('¿Estás seguro de que deseas eliminar la conferencia "' + titulo + '"?\n\nEsta acción no se puede deshacer.')) {
        window.location.href = 'eliminar_conferencia_action.jsp?id=' + id;
      }
    }
  </script>

  <footer>
    &copy; 2025 Red de Apoyo a Emprendedores Locales
  </footer>
</body>
</html>