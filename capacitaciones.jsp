<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Capacitaciones - Red de Apoyo</title>
  <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
  <!-- Fuentes y FontAwesome -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans:wght@300;400;500;700&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.4.0/css/all.min.css">
  <style>
    /* Reset y tipografía */
    *, *::before, *::after { box-sizing: border-box; margin:0; padding:0; }
    html, body, h1,h2,h3,h4,h5,h6, p,a,button,input,textarea,select,ul,li,nav,header,footer {
      font-family:'Noto Sans',sans-serif; -webkit-font-smoothing:antialiased; -moz-osx-font-smoothing:grayscale;
    }
    body { background:#121212; color:#fff; display:flex; flex-direction:column; min-height:100vh; }

    /* Header con hamburguesa idéntico */
    header {
      background:#1e1e1e; padding:1rem 2rem;
      display:flex; align-items:center; justify-content:space-between;
      position:relative; z-index:100;
    }
    header h1 { font-size:1.8rem; color:#00a5a5; }
    .menu-toggle {
      background:none; border:none; color:#fff; font-size:1.5rem;
      cursor:pointer; padding:.5rem; border-radius:4px;
      display:flex; align-items:center; gap:.5rem; transition:background .3s;
    }
    .menu-toggle:hover { background:rgba(255,255,255,0.1); }

    /* Overlay idéntico */
    .menu-overlay {
      position:fixed; top:0; left:0; width:100%; height:100%;
      background:rgba(0,0,0,.5); opacity:0; visibility:hidden;
      transition:opacity .3s,visibility .3s; z-index:99;
    }
    .menu-overlay.active { opacity:1; visibility:visible; }

    /* Side‑menu idéntico */
    .side-menu {
      position:fixed; top:0; right:-350px; width:350px; height:100vh;
      background:linear-gradient(135deg,#1e1e1e,#2a2a2a);
      box-shadow:-5px 0 20px rgba(0,0,0,.5);
      transition:right .4s; z-index:100;
      display:flex; flex-direction:column;
    }
    .side-menu.active { right:0; }
    .side-menu-header {
      padding:1.5rem; background:#161616;
      border-bottom:2px solid #008080;
      display:flex; justify-content:space-between; align-items:center;
    }
    .side-menu-title { color:#00a5a5; font-size:1.3rem; font-weight:bold; }
    .close-menu {
      background:none; border:none; color:#fff; font-size:1.8rem;
      cursor:pointer; border-radius:50%; padding:.25rem;
      transition:transform .2s;
    }
    .close-menu:hover { transform:rotate(90deg); }

    .side-menu-content { flex:1; overflow-y:auto; }
    .user-info {
      background:#252525; margin:1rem; padding:1rem;
      border-left:4px solid #008080;
    }
    .user-info h4 { margin-bottom:.5rem; color:#00a5a5; }
    .user-info p { color:#ccc; font-size:.9rem; margin:.25rem 0; }

    .menu-section { margin-bottom:2rem; }
    .menu-section-title {
      color:#00a5a5; font-size:.85rem; font-weight:bold;
      text-transform:uppercase; margin:0 1.5rem .5rem; padding-bottom:.25rem;
      border-bottom:1px solid #333;
    }
    .menu-item {
      display:flex; align-items:center; gap:1rem;
      padding:1rem 1.5rem; color:#fff; text-decoration:none;
      font-weight:500; transition:all .3s; border-left:4px solid transparent;
    }
    .menu-item:hover {
      background:rgba(0,165,165,.1); border-left-color:#00a5a5;
      color:#00a5a5; transform:translateX(5px);
    }
    .menu-item-icon { font-size:1.2rem; width:24px; text-align:center; }

    /* Contenedor de contenido */
    .container {
      flex:1; max-width:1200px; margin:2rem auto; padding:0 1rem;
    }
    .nav-buttons { display:flex; gap:1rem; justify-content:center; margin-bottom:2rem; }
    .btn {
      background:#008891; color:#fff; padding:.7rem 1.5rem;
      border:none; border-radius:4px; text-decoration:none; font-weight:500;
      transition:background .3s;
    }
    .btn:hover { background:#006f78; }

    /* Secciones */
    h2.section-title {
      text-align:center; font-size:1.8rem; margin-bottom:1rem;
      position:relative; color:#00a5a5; padding-bottom:.5rem;
    }
    h2.section-title:after {
      content:''; position:absolute; bottom:0; left:50%;
      transform:translateX(-50%); width:60px; height:3px;
      background:#00a5a5;
    }

    .videos-grid {
      display:grid; grid-template-columns:repeat(3,1fr);
      gap:1.5rem; margin-bottom:3rem;
    }
    .video-card {
      background:#232323; border-radius:8px; overflow:hidden;
      transition:transform .3s;
    }
    .video-card:hover { transform:translateY(-5px); }
    .video-container { position:relative; width:100%; padding-bottom:56.25%; }
    .video-container iframe { position:absolute; top:0; left:0; width:100%; height:100%; border:none; }
    .video-info { padding:1rem; text-align:center; }
    .video-info h3 { color:#fff; font-size:1.1rem; }

    .courses-list {
      display:grid; grid-template-columns:repeat(auto-fill,minmax(200px,1fr));
      gap:1rem; margin-bottom:3rem;
    }
    .course-link {
      display:flex; align-items:center; justify-content:center;
      background:#232323; border:1px solid #00a5a5; border-radius:6px;
      padding:.75rem 1rem; color:#00c1c1; text-decoration:none;
      transition:transform .2s;
    }
    .course-link:hover { transform:translateY(-2px); background:#00a5a5; color:#121212; }

    .talks-grid {
      display:grid; grid-template-columns:repeat(2,1fr);
      gap:1.5rem; margin-bottom:3rem;
    }
    .talk-card {
      background:#1f1f1f; border-radius:8px; padding:1rem;
      text-align:center; box-shadow:0 2px 8px rgba(0,0,0,.3);
      transition:transform .3s;
    }
    .talk-card:hover { transform:translateY(-3px); }
    .talk-card h3 { color:#00a5a5; margin-bottom:.5rem; }
    .talk-card p { color:#ccc; margin-bottom:1rem; }
    .talk-card button {
      background:#008891; color:#fff; padding:.5rem 1rem;
      border:none; border-radius:4px; cursor:pointer;
      transition:background .3s;
    }
    .talk-card button:hover { background:#006f78; }

    /* Modal */
    .modal {
      display:none; position:fixed; top:0; left:0;
      width:100%; height:100%; background:rgba(0,0,0,.7);
      justify-content:center; align-items:center; padding:1rem;
    }
    .modal-content {
      background:#1f1f1f; border-radius:6px;
      max-width:800px; width:100%; max-height:80%; overflow-y:auto;
      position:relative;
    }
    .modal-close {
      position:absolute; top:.5rem; right:.75rem;
      background:none; border:none; color:#888; font-size:1.5rem;
      cursor:pointer;
    }
    .modal-close:hover { color:#fff; }
    .modal .video-container { position:relative; width:100%; padding-bottom:56.25%; }
    .modal .video-container iframe { position:absolute; top:0; left:0; width:100%; height:100%; border:none; }

    footer { background:#1a1a1a; text-align:center; padding:1rem; color:#888; margin-top:auto; }

    @media(max-width:992px) {
      .videos-grid{grid-template-columns:repeat(2,1fr);}
      .talks-grid{grid-template-columns:1fr;}
    }
    @media(max-width:600px) {
      .videos-grid, .courses-list{grid-template-columns:1fr;}
    }
  </style>
</head>
<body>
  <!-- HEADER -->
  <header>
    <h1>Capacitaciones</h1>
    <button class="menu-toggle" onclick="toggleMenu()">
      <i class="fas fa-bars"></i> Menú
    </button>
  </header>

  <!-- OVERLAY -->
  <div class="menu-overlay" onclick="closeMenu()"></div>

  <!-- SIDE‑MENU -->
  <nav class="side-menu" id="sideMenu">
    <div class="side-menu-header">
      <span class="side-menu-title">Navegación</span>
      <button class="close-menu" onclick="closeMenu()">×</button>
    </div>
    <div class="side-menu-content">
      <div class="user-info">
        <h4>¡Hola, Emprendedor!</h4>
        <p><strong>Email:</strong> tu@correo.com</p>
        <p><strong>Negocio:</strong> Mi Empresa</p>
      </div>
      <div class="menu-section">
        <div class="menu-section-title">Principal</div>
        <a href="mentores.jsp" class="menu-item">👨‍🏫 Ver Mentores</a>
        <a href="capacitaciones.jsp" class="menu-item">📚 Capacitaciones</a>
        <a href="agregar_publicacion.jsp" class="menu-item">➕ Nueva Publicación</a>
        <a href="editar_perfil_emprendedor.jsp" class="menu-item">👤 Editar Perfil</a>
      </div>
      <div class="menu-section">
        <div class="menu-section-title">Cuenta</div>
        <a href="Logout.jsp" class="menu-item">🚪 Cerrar Sesión</a>
      </div>
    </div>
  </nav>

  <!-- CONTENIDO -->
  <div class="container">
    

    <h2 class="section-title">Videos de Capacitación</h2>
    <div class="videos-grid">
      <% 
        try (Connection conn = DriverManager.getConnection(
               "jdbc:mysql://localhost:3306/red_de_apoyo","root",""
             );
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(
               "SELECT titulo, url FROM videos_capacitacion ORDER BY fecha_creacion DESC"
             )) {
          while (rs.next()) {
            String url = rs.getString("url");
            String vid = "";
            if (url.contains("watch?v=")) vid = url.split("watch\\?v=")[1].split("&")[0];
            else if (url.contains("youtu.be/")) vid = url.split("youtu.be/")[1].split("&")[0];
      %>
      <div class="video-card">
        <div class="video-container">
          <iframe src="https://www.youtube.com/embed/<%=vid%>" allowfullscreen></iframe>
        </div>
        <div class="video-info">
          <h3><%= rs.getString("titulo") %></h3>
        </div>
      </div>
      <%  }
        } catch(Exception e) {
          out.println("<p>Error al cargar videos: "+e.getMessage()+"</p>");
        }
      %>
    </div>

    <h2 class="section-title">Cursos</h2>
    <div class="courses-list">
      <%
        try (Connection conn = DriverManager.getConnection(
               "jdbc:mysql://localhost:3306/red_de_apoyo","root",""
             );
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(
               "SELECT titulo, url FROM cursos_capacitacion ORDER BY fecha_creacion DESC"
             )) {
          while (rs.next()) {
      %>
      <a href="<%= rs.getString("url") %>" target="_blank" class="course-link">
        <%= rs.getString("titulo") %>
      </a>
      <%  }
        } catch(Exception e) {
          out.println("<p>Error al cargar cursos: "+e.getMessage()+"</p>");
        }
      %>
    </div>

    <h2 class="section-title">Charlas & Conferencias</h2>
    <div class="talks-grid">
      <%
        try {
          Class.forName("com.mysql.cj.jdbc.Driver");
          Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/red_de_apoyo","root","");
          Statement st = conn.createStatement();
          ResultSet rs = st.executeQuery(
            "SELECT titulo, descripcion, url FROM conferencias_capacitacion ORDER BY fecha_creacion DESC"
          );
          while (rs.next()) {
            String raw = rs.getString("url"), vid = "";
            if (raw.contains("watch?v=")) vid = raw.split("watch\\?v=")[1].split("&")[0];
            else if (raw.contains("youtu.be/")) vid = raw.split("youtu.be/")[1].split("&")[0];
      %>
      <div class="talk-card">
        <h3><%= rs.getString("titulo") %></h3>
        <p><%= rs.getString("descripcion") %></p>
        <button onclick="openModal('https://www.youtube-nocookie.com/embed/<%=vid%>?rel=0')">
          <i class="fas fa-play-circle"></i> Ver Video
        </button>
      </div>
      <%  }
        } catch(Exception ignore){}
      %>
    </div>
  </div>

  <!-- Modal global -->
  <div id="videoModal" class="modal" onclick="closeModal()">
    <div class="modal-content" onclick="event.stopPropagation()">
      <button class="modal-close" onclick="closeModal()">×</button>
      <div class="video-container">
        <iframe id="modalIframe" src="" allowfullscreen></iframe>
      </div>
    </div>
  </div>

  <footer>&copy; 2025 Red de Apoyo a Emprendedores Locales</footer>

  <script>
    function toggleMenu() {
      document.getElementById('sideMenu').classList.toggle('active');
      document.querySelector('.menu-overlay').classList.toggle('active');
    }
    function closeMenu() {
      document.getElementById('sideMenu').classList.remove('active');
      document.querySelector('.menu-overlay').classList.remove('active');
    }
    function openModal(src) {
      document.getElementById('modalIframe').src = src;
      document.getElementById('videoModal').style.display = 'flex';
    }
    function closeModal() {
      document.getElementById('modalIframe').src = '';
      document.getElementById('videoModal').style.display = 'none';
    }
    document.addEventListener('keydown', e => {
      if (e.key === 'Escape') {
        closeMenu();
        closeModal();
      }
    });
  </script>
</body>
</html>
