<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.net.URLEncoder, java.util.*" %>
<%
    // 1) Validar sesión de emprendedor
    String rol     = (String) session.getAttribute("rol");
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null || !"emprendedor".equals(rol)) {
        response.sendRedirect("Login_emprendedor.jsp");
        return;
    }

    // 2) Configuración de BD
    String dbUrl      = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser     = "root";
    String dbPassword = "";

    // Variables de perfil
    String nombre      = "";
    String email       = "";
    String telefono    = "";
    String negocio     = "";
    String descripcion = "";

    // Modelos internos
    class Post { int id; String titulo, descripcion, imagenUrl; Timestamp fecha; }
    class ChatResumen { int clienteId; String clienteNombre; }

    List<Post> posts          = new ArrayList<>();
    List<ChatResumen> chatsClientes = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword)) {
            // 3) Datos de perfil
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT nombre, email, telefono, negocio, descripcion FROM emprendedores WHERE id = ?"
            )) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        nombre      = rs.getString("nombre");
                        email       = rs.getString("email");
                        telefono    = rs.getString("telefono");
                        negocio     = rs.getString("negocio");
                        descripcion = rs.getString("descripcion");
                    }
                }
            }

            // 4) Publicaciones propias
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT id, titulo, descripcion, imagen_url, fecha_publicacion " +
                    "FROM publicaciones WHERE emprendedor_id = ? ORDER BY fecha_publicacion DESC"
            )) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Post p = new Post();
                        p.id          = rs.getInt("id");
                        p.titulo      = rs.getString("titulo");
                        p.descripcion = rs.getString("descripcion");
                        p.imagenUrl   = rs.getString("imagen_url");
                        p.fecha       = rs.getTimestamp("fecha_publicacion");
                        posts.add(p);
                    }
                }
            }

            // 5) Chats recibidos de CLIENTES
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT DISTINCT m.cliente_id, c.nombre " +
                    "FROM mensajes_chat m " +
                    "JOIN clientes c ON m.cliente_id = c.id " +
                    "WHERE m.emprendedor_nombre = ? AND m.negocio = ? AND m.emisor = 'cliente'"
            )) {
                ps.setString(1, nombre);
                ps.setString(2, negocio);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        ChatResumen cr = new ChatResumen();
                        cr.clienteId     = rs.getInt("cliente_id");
                        cr.clienteNombre = rs.getString("nombre");
                        chatsClientes.add(cr);
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
  <title>Panel de Emprendedor</title>
  <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
  <style>
    /* --- Botón "+ Nueva publicación" --- */
    .posts .actions { margin-bottom: 1rem; }
    .posts .actions a.btn {
      background-color: #00a5a5;
      color: #ffffff;
      padding: 0.6rem 1.2rem;
      border-radius: 4px;
      text-decoration: none;
      font-size: 1rem;
      font-weight: bold;
      transition: background-color 0.3s, transform 0.2s;
      display: inline-block;
    }
    .posts .actions a.btn:hover {
      background-color: #008080;
      transform: translateY(-2px);
    }

    /* Botón editar publicación */
    .post-card .edit-post-btn {
      position: absolute; top: 8px; right: 8px;
      background: #008080; color: #121212;
      padding: 0.3rem 0.6rem; border: none;
      border-radius: 4px; font-size: 0.9rem;
      cursor: pointer; font-weight: bold;
      transition: background 0.3s;
    }
    .post-card .edit-post-btn:hover { background: rgb(2, 238, 255); }

    body { margin:0; background:#121212; color:#fff; font-family:Arial,sans-serif; }
    
    /* --- HEADER MEJORADO --- */
    header { 
      background:#1e1e1e; 
      padding:1rem; 
      display:flex; 
      align-items:center; 
      justify-content:space-between;
      position: relative;
      z-index: 1000;
    }
    header h1 { 
      margin:0; 
      font-size:1.8rem; 
      flex-grow: 1;
    }

    /* Botón del menú hamburguesa */
    .menu-toggle {
      background: none;
      border: none;
      color: #fff;
      font-size: 1.5rem;
      cursor: pointer;
      padding: 0.5rem;
      border-radius: 4px;
      transition: background 0.3s;
      display: flex;
      align-items: center;
      gap: 0.5rem;
      font-weight: bold;
    }
    .menu-toggle:hover {
      background: rgba(255, 255, 255, 0.1);
    }

    /* Menú lateral desplegable */
    .side-menu {
      position: fixed;
      top: 0;
      right: -350px;
      width: 350px;
      height: 100vh;
      background: linear-gradient(135deg, #1e1e1e 0%, #2a2a2a 100%);
      box-shadow: -5px 0 20px rgba(0, 0, 0, 0.5);
      transition: right 0.4s cubic-bezier(0.4, 0, 0.2, 1);
      z-index: 1001;
      display: flex;
      flex-direction: column;
    }

    .side-menu.active {
      right: 0;
    }

    /* Header del menú lateral */
    .side-menu-header {
      padding: 1.5rem;
      background: #161616;
      border-bottom: 2px solid #008080;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .side-menu-title {
      font-size: 1.3rem;
      font-weight: bold;
      color: #00a5a5;
      margin: 0;
    }

    .close-menu {
      background: none;
      border: none;
      color: #fff;
      font-size: 1.8rem;
      cursor: pointer;
      padding: 0.25rem;
      border-radius: 50%;
      width: 40px;
      height: 40px;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: background 0.3s, transform 0.2s;
    }
    .close-menu:hover {
      background: rgba(255, 255, 255, 0.1);
      transform: rotate(90deg);
    }

    /* Contenido del menú */
    .side-menu-content {
      flex: 1;
      padding: 1rem 0;
      overflow-y: auto;
    }

    /* Sección de navegación */
    .menu-section {
      margin-bottom: 2rem;
    }

    .menu-section-title {
      color: #00a5a5;
      font-size: 0.9rem;
      font-weight: bold;
      text-transform: uppercase;
      letter-spacing: 1px;
      margin: 0 1.5rem 1rem;
      padding-bottom: 0.5rem;
      border-bottom: 1px solid #333;
    }

    .menu-item {
      display: block;
      color: #fff;
      text-decoration: none;
      padding: 1rem 1.5rem;
      transition: all 0.3s;
      border-left: 4px solid transparent;
      font-weight: 500;
      display: flex;
      align-items: center;
      gap: 1rem;
    }

    .menu-item:hover {
      background: rgba(0, 165, 165, 0.1);
      border-left-color: #00a5a5;
      color: #00a5a5;
      transform: translateX(5px);
    }

    .menu-item-icon {
      font-size: 1.2rem;
      width: 24px;
      text-align: center;
    }

    /* Información del usuario en el menú */
    .user-info {
      background: #252525;
      margin: 1rem;
      padding: 1rem;
      border-radius: 8px;
      border-left: 4px solid #008080;
    }

    .user-info h4 {
      margin: 0 0 0.5rem;
      color: #00a5a5;
      font-size: 1.1rem;
    }

    .user-info p {
      margin: 0.25rem 0;
      color: #ccc;
      font-size: 0.9rem;
    }

    /* Overlay para cerrar el menú */
    .menu-overlay {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0, 0, 0, 0.5);
      opacity: 0;
      visibility: hidden;
      transition: all 0.3s;
      z-index: 999;
    }

    .menu-overlay.active {
      opacity: 1;
      visibility: visible;
    }

    /* Resto de estilos originales */
    .container { display:flex; max-width:1200px; margin:1rem auto; gap:1rem; padding:0 1rem; }
    .chats, .posts, .profile { background:#1f1f1f; border-radius:8px; padding:1rem; }
    .chats { flex:1; }
    .posts { flex:2; position: relative; }
    .profile { flex:1; }
    h2 { margin-top:0; }

    .chat-section { margin-bottom: 1.5rem; background: #252525; border-radius: 6px; padding: 1rem; border-left: 4px solid #008080; }
    .chat-section h3 { margin: 0 0 0.75rem 0; color: #008080; font-size: 1.1rem; }
    .chat-section ul { list-style:none; padding:0; margin:0; }
    .chat-section li { margin-bottom:0.5rem; }
    .chat-section a { color:#00a5a5; text-decoration:none; }
    .chat-section a:hover { text-decoration:underline; }
    .chat-empty { color: #888; font-style: italic; }

    .post-card {
      margin-bottom:1rem; background:#222; border-radius:6px; overflow:hidden; position:relative;
    }
    .post-card img { width:100%; height:200px; object-fit:cover; }
    .post-card .info { padding:0.75rem; }
    .post-card h3 { margin:0 0 0.5rem; }
    .post-card p { margin:0 0 0.5rem; color:#ccc; }
    .post-card small { color:#777; }

    .profile .field { margin-bottom:0.75rem; }
    .profile label { font-weight:bold; display:block; margin-bottom:0.25rem; }
    .profile .edit-btn {
      display: inline-block;
      margin-top: 1rem;
      background: #00a5a5;
      color: #fff;
      padding: 0.5rem 1rem;
      border-radius: 4px;
      text-decoration: none;
      font-weight: bold;
      transition: background 0.3s;
    }
    .profile .edit-btn:hover { background: #008080; }

    footer { text-align:center; padding:1rem; background:#1e1e1e; color:#888; margin-top:1rem; }

    @media (max-width: 768px) {
      .container { flex-direction: column; }
      .side-menu { width: 100%; right: -100%; }
      header h1 { font-size: 1.4rem; }
    }
  </style>
</head>
<body>
<header>
  <h1>Panel de Emprendedor</h1>
  <button class="menu-toggle" onclick="toggleMenu()">
    <span class="menu-item-icon">☰</span>
    Menú
  </button>
</header>

<!-- Overlay para cerrar el menú -->
<div class="menu-overlay" onclick="closeMenu()"></div>

<!-- Menú lateral -->
<div class="side-menu" id="sideMenu">
  <div class="side-menu-header">
    <h3 class="side-menu-title">Navegación</h3>
    <button class="close-menu" onclick="closeMenu()">&times;</button>
  </div>
  
  <div class="side-menu-content">
    <!-- Información del usuario -->
    <div class="user-info">
      <h4>¡Hola, <%= nombre %>!</h4>
      <p><strong>Negocio:</strong> <%= negocio %></p>
      <p><strong>Email:</strong> <%= email %></p>
    </div>

    <!-- Navegación principal -->
    <div class="menu-section">
      <div class="menu-section-title">Navegación</div>
      <a href="mentores.jsp" class="menu-item">
        <span class="menu-item-icon">👨‍🏫</span>
        Ver Mentores
      </a>
      <a href="capacitaciones.jsp" class="menu-item">
        <span class="menu-item-icon">📚</span>
        Capacitaciones
      </a>
      <a href="agregar_publicacion.jsp" class="menu-item">
        <span class="menu-item-icon">➕</span>
        Nueva Publicación
      </a>
      <a href="editar_perfil_emprendedor.jsp" class="menu-item">
        <span class="menu-item-icon">👤</span>
        Editar Perfil
      </a>
    </div>

    <!-- Acciones -->
    <div class="menu-section">
      <div class="menu-section-title">Cuenta</div>
      <a href="Logout.jsp" class="menu-item">
        <span class="menu-item-icon">🚪</span>
        Cerrar Sesión
      </a>
    </div>
  </div>
</div>

<div class="container">
  <!-- Chats con clientes -->
  <div class="chats">
    <h2>Mensajes</h2>
    <div class="chat-section">
      <h3>👥 Chats con Clientes</h3>
      <ul>
        <% if (chatsClientes.isEmpty()) { %>
          <li class="chat-empty">No hay chats con clientes aún.</li>
        <% } else {
             for (ChatResumen cr : chatsClientes) { %>
          <li>
            <a href="chat_directo_emprendedor.jsp?cliente_id=<%=cr.clienteId%>&emprendedor_nombre=<%=URLEncoder.encode(nombre,"UTF-8")%>&negocio=<%=URLEncoder.encode(negocio,"UTF-8")%>">
              💬 <%= cr.clienteNombre %>
            </a>
          </li>
        <% }} %>
      </ul>
    </div>
  </div>

  <!-- Mis Publicaciones -->
  <div class="posts">
    <h2>Mis Publicaciones</h2>
    <!--div class="actions">
      <a href="agregar_publicacion.jsp" class="btn">+ Nueva publicación</a>
    </div-->
    <br>
    <% if (posts.isEmpty()) { %>
      <p>No has publicado nada aún.</p>
    <% } else {
         for (Post p : posts) { %>
      <div class="post-card">
        <a href="editar_publicacion.jsp?id=<%=p.id%>" class="edit-post-btn">✎</a>
        <% if (p.imagenUrl != null && !p.imagenUrl.isEmpty()) { %>
          <img src="<%= p.imagenUrl %>" alt="">
        <% } %>
        <div class="info">
          <h3><%= p.titulo %></h3>
          <p><%= p.descripcion %></p>
          <small><%= p.fecha.toLocalDateTime().toLocalDate() %></small>
        </div>
      </div>
    <% }} %>
  </div>

  <!-- Perfil -->
  <div class="profile">
    <h2>Perfil</h2>
    <div class="field">
      <label>Nombre:</label>
      <div><%= nombre %></div>
    </div>
    <div class="field">
      <label>Email:</label>
      <div><%= email %></div>
    </div>
    <div class="field">
      <label>Teléfono:</label>
      <div><%= (telefono == null || telefono.trim().isEmpty()) ? "Sin número de contacto" : telefono %></div>
    </div>
    <div class="field">
      <label>Negocio:</label>
      <div><%= negocio %></div>
    </div>
    <div class="field">
      <label>Descripción:</label>
      <div><%= descripcion %></div>
    </div>
    <!--a href="editar_perfil_emprendedor.jsp" class="edit-btn">Editar Perfil</a-->
  </div>
</div>

<footer>
  &copy; 2025 Red de Apoyo a Emprendedores Locales
</footer>

<script>
function toggleMenu() {
  const menu = document.getElementById('sideMenu');
  const overlay = document.querySelector('.menu-overlay');
  
  menu.classList.toggle('active');
  overlay.classList.toggle('active');
}

function closeMenu() {
  const menu = document.getElementById('sideMenu');
  const overlay = document.querySelector('.menu-overlay');
  
  menu.classList.remove('active');
  overlay.classList.remove('active');
}

// Cerrar menú con tecla Escape
document.addEventListener('keydown', function(e) {
  if (e.key === 'Escape') {
    closeMenu();
  }
});

// Cerrar menú al hacer clic en un enlace (opcional)
document.querySelectorAll('.menu-item').forEach(item => {
  item.addEventListener('click', function() {
    closeMenu();
  });
});
</script>
</body>
</html>