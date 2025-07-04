<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.net.URLEncoder, java.util.*" %>
<%
    // Validación de sesión de emprendedor
    String rol     = (String) session.getAttribute("rol");
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null || !"emprendedor".equals(rol)) {
        response.sendRedirect("Login_emprendedor.jsp");
        return;
    }

    // Conexión a BD
    String dbUrl      = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser     = "root";
    String dbPassword = "";

    // Variables de perfil y sociales
    String nombre = "", email = "", telefono = "", negocio = "", categoria = "", direccion = "", ciudad = "", departamento = "", descripcion = "";
    String instagram = "", facebook = "", tiktok = "";

    class Post { int id; String titulo, descripcion, imagenUrl; Timestamp fecha; }
    class ChatResumen { int clienteId; String clienteNombre; }
    List<Post> posts = new ArrayList<>();
    List<ChatResumen> chatsClientes = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword)) {
            // Cargar datos de emprendedor incluyendo redes
            String sql = "SELECT nombre, email, telefono, negocio, categoria, direccion, ciudad, departamento, descripcion, instagram, facebook, tiktok " +
                         "FROM emprendedores WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        nombre      = rs.getString("nombre");
                        email       = rs.getString("email");
                        telefono    = rs.getString("telefono");
                        negocio     = rs.getString("negocio");
                        categoria   = rs.getString("categoria");
                        direccion   = rs.getString("direccion");
                        ciudad      = rs.getString("ciudad");
                        departamento= rs.getString("departamento");
                        descripcion = rs.getString("descripcion");
                        instagram   = rs.getString("instagram");
                        facebook    = rs.getString("facebook");
                        tiktok      = rs.getString("tiktok");
                    }
                }
            }
            // Posts
            String sqlPosts = "SELECT id, titulo, descripcion, imagen_url, fecha_publicacion " +
                              "FROM publicaciones WHERE emprendedor_id = ? ORDER BY fecha_publicacion DESC";
            try (PreparedStatement ps2 = conn.prepareStatement(sqlPosts)) {
                ps2.setInt(1, userId);
                try (ResultSet rs2 = ps2.executeQuery()) {
                    while (rs2.next()) {
                        Post p = new Post();
                        p.id          = rs2.getInt("id");
                        p.titulo      = rs2.getString("titulo");
                        p.descripcion = rs2.getString("descripcion");
                        p.imagenUrl   = rs2.getString("imagen_url");
                        p.fecha       = rs2.getTimestamp("fecha_publicacion");
                        posts.add(p);
                    }
                }
            }
            // Chats
            String sqlChats = "SELECT DISTINCT m.cliente_id, c.nombre " +
                              "FROM mensajes_chat m JOIN clientes c ON m.cliente_id = c.id " +
                              "WHERE m.emprendedor_nombre = ? AND m.negocio = ? AND m.emisor = 'cliente'";
            try (PreparedStatement ps3 = conn.prepareStatement(sqlChats)) {
                ps3.setString(1, nombre);
                ps3.setString(2, negocio);
                try (ResultSet rs3 = ps3.executeQuery()) {
                    while (rs3.next()) {
                        ChatResumen cr = new ChatResumen();
                        cr.clienteId     = rs3.getInt("cliente_id");
                        cr.clienteNombre = rs3.getString("nombre");
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
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Panel de Emprendedor</title>
  <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
  <!-- FontAwesome -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.4.0/css/all.min.css">
  <style>
    /* Reset global */
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {margin:0; background:#121212; color:#fff; font-family:Arial,sans-serif; min-height:100vh; display:flex; flex-direction:column;}
    header, footer {background:#1e1e1e; padding:1rem; text-align:center;}
    header {display:flex; justify-content:space-between; align-items:center;}
    .menu-toggle, .close-menu {background:none; border:none; color:#fff; cursor:pointer; font-size:1.2rem;}
    .menu-overlay {position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); visibility:hidden; opacity:0; transition:opacity .3s, visibility .3s; z-index:999;}
    .menu-overlay.active {visibility:visible; opacity:1;}
    .side-menu {position:fixed; top:0; right:-300px; width:300px; height:100vh; background:linear-gradient(135deg,#1e1e1e,#2a2a2a); box-shadow:-5px 0 20px rgba(0,0,0,.5); transition:right .4s; z-index:1001;}
    .side-menu.active {right:0;}
    .side-menu-header {padding:1rem; background:#161616; border-bottom:2px solid #008080; display:flex; justify-content:space-between; align-items:center;}
    .side-menu-title {color:#00a5a5; font-size:1.2rem; font-weight:bold;}
    .side-menu-content {overflow-y:auto; height:calc(100% - 56px);}
    .user-info {background:#252525; margin:1rem; padding:1rem; border-left:4px solid #008080;}
    .user-info h4 {margin:0 0 .5rem; color:#00a5a5;}
    .user-info p {margin:.25rem 0; color:#ccc; font-size:.9rem;}
    .menu-section {margin:1rem 0;}
    .menu-section-title {color:#00a5a5; font-size:.9rem; font-weight:bold; text-transform:uppercase; margin:0 1rem .5rem; border-bottom:1px solid #333;}
    .menu-item {display:flex; align-items:center; gap:1rem; color:#fff; padding:.75rem 1rem; text-decoration:none; font-weight:500; transition:all .3s; border-left:4px solid transparent;}
    .menu-item:hover {background:rgba(0,165,165,.1); border-left-color:#00a5a5; color:#00a5a5; transform:translateX(5px);}

    .container {display:flex; max-width:1200px; margin:1rem auto; gap:1rem; padding:0 1rem; flex:1;}
    @media(max-width:768px){.container{flex-direction:column;}}
    .chats, .posts, .profile {background:#1f1f1f; border-radius:8px; padding:1rem; overflow:auto;}
    .chats {flex:1;} .posts {flex:2; position:relative;} .profile {flex:1;}

    h2 {margin-top:0; border-bottom:2px solid #00a5a5; padding-bottom:.5rem;}

    .chat-section {margin-bottom:1rem; background:#252525; border-radius:6px; padding:1rem; border-left:4px solid #008080;}
    .chat-section h3 {margin:0 0 .75rem; color:#008080;}
    .chat-section ul {list-style:none; padding:0; margin:0;}
    .chat-section li {margin-bottom:.5rem;}
    .chat-section a {color:#00a5a5; text-decoration:none;}
    .chat-section a:hover {text-decoration:underline;}

    .btn {background:#00a5a5; color:#fff; padding:.6rem 1.2rem; border-radius:4px; text-decoration:none; font-weight:bold; display:inline-block; transition:transform .2s;}
    .btn:hover {transform:translateY(-2px);}

    .post-card {position:relative; margin-bottom:1rem; background:#222; border-radius:6px; overflow:hidden;}
    .post-card img {width:100%; height:200px; object-fit:cover;}
    .info {padding:.75rem;}
    .info h3, .post-card h3 {margin:0 0 .5rem; font-size:1.2rem; color:#00c1c1;}
    .info p, .post-card p {margin:0 0 .5rem; color:#ccc;}
    .info small, .post-card small {color:#777;}
    .edit-post-btn {position:absolute; top:8px; right:8px; background:#008080; color:#121212; padding:.3rem .6rem; border:none; border-radius:4px; font-weight:bold; cursor:pointer; transition:background .3s;}
    .edit-post-btn:hover {background:rgb(2,238,255);}

    .profile .field {display:flex; justify-content:space-between; align-items:center; padding:.5rem 0; border-bottom:1px solid #333;}
    .profile .field:last-child {border:none;}
    .profile .label {color:#00a5a5; font-weight:bold;}
    .profile .value {color:#ccc; text-align:right; max-width:70%;}

    .social-links {display:flex; gap:1rem; margin-top:1rem;}
    .social-links a {color:#fff; font-size:1.5rem; transition:opacity .2s;}
    .social-links a:hover {opacity:.7;}
</style>
</head>
<body>
  <header>
    <h1>Panel de Emprendedor</h1>
    <button class="menu-toggle" onclick="toggleMenu()">☰ Menú</button>
  </header>
  <div class="menu-overlay" onclick="closeMenu()"></div>
  <div class="side-menu" id="sideMenu">
    <div class="side-menu-header">
      <span class="side-menu-title">Navegación</span>
      <button class="close-menu" onclick="closeMenu()">×</button>
    </div>
    <div class="side-menu-content">
      <div class="user-info">
        <h4>¡Hola, <%= nombre %>!</h4>
        <p><strong>Negocio:</strong> <%= negocio %></p>
        <p><strong>Email:</strong> <%= email %></p>
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
  </div>
  <div class="container">
    <div class="chats">
      <h2>Mensajes</h2>
      <div class="chat-section">
        <h3>👥 Chats con Clientes</h3>
        <ul>
          <% if (chatsClientes.isEmpty()) { %>
            <li>No hay chats con clientes aún.</li>
          <% } else {
               for (ChatResumen cr : chatsClientes) { %>
            <li><a href="chat_directo_emprendedor.jsp?cliente_id=<%=cr.clienteId%>&emprendedor_nombre=<%=URLEncoder.encode(nombre,"UTF-8")%>&negocio=<%=URLEncoder.encode(negocio,"UTF-8")%>">💬 <%= cr.clienteNombre %></a></li>
          <% }} %>
        </ul>
      </div>
    </div>
    <div class="posts">
      <h2>Mis Publicaciones</h2>
      <% if (posts.isEmpty()) { %>
        <p>No has publicado nada aún.</p>
      <% } else {
           for (Post p : posts) { %>
        <div class="post-card">
          <button onclick="location.href='editar_publicacion.jsp?id=<%= p.id %>'" class="edit-post-btn">✎</button>
          <% if (p.imagenUrl != null && !p.imagenUrl.isEmpty()) { %>
            <img src="<%= p.imagenUrl %>" alt=""><% } %>
          <div class="info"><h3><%= p.titulo %></h3><p><%= p.descripcion %></p><small><%= p.fecha.toLocalDateTime().toLocalDate() %></small></div>
        </div>
      <% }} %>
    </div>
    <div class="profile">
      <h2>Perfil</h2>
      <div class="field"><span class="label">Nombre:</span><span class="value"><%= nombre %></span></div>
      <div class="field"><span class="label">Email:</span><span class="value"><%= email %></span></div>
      <div class="field"><span class="label">Teléfono:</span><span class="value"><%= telefono %></span></div>
      <div class="field"><span class="label">Negocio:</span><span class="value"><%= negocio %></span></div>
      <div class="field"><span class="label">Categoría:</span><span class="value"><%= categoria %></span></div>
      <div class="field"><span class="label">Dirección:</span><span class="value"><%= direccion %></span></div>
      <div class="field"><span class="label">Ciudad:</span><span class="value"><%= ciudad %></span></div>
      <div class="field"><span class="label">Departamento:</span><span class="value"><%= departamento %></span></div>
      <div class="field"><span class="label">Descripción:</span><span class="value"><%= descripcion %></span></div>
      <!-- Redes Sociales -->
      <div class="social-links">
        <% if (instagram != null && !instagram.trim().isEmpty()) { %>
          <a href="<%= instagram %>" target="_blank" title="Instagram"><i class="fab fa-instagram"></i></a>
        <% } %>
        <% if (facebook != null && !facebook.trim().isEmpty()) { %>
          <a href="<%= facebook %>" target="_blank" title="Facebook"><i class="fab fa-facebook-f"></i></a>
        <% } %>
        <% if (tiktok != null && !tiktok.trim().isEmpty()) { %>
          <a href="<%= tiktok %>" target="_blank" title="TikTok"><i class="fab fa-tiktok"></i></a>
        <% } %>
      </div>
    </div>
  </div>
  <footer>&copy; 2025 Red de Apoyo a Emprendedores Locales</footer>
  <script>
    function toggleMenu(){ document.getElementById('sideMenu').classList.toggle('active'); document.querySelector('.menu-overlay').classList.toggle('active'); }
    function closeMenu(){ document.getElementById('sideMenu').classList.remove('active'); document.querySelector('.menu-overlay').classList.remove('active'); }
    document.addEventListener('keydown', e => { if (e.key==='Escape') closeMenu(); });
  </script>
</body>
</html>
