<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    String rol = (String) session.getAttribute("rol");

    if (userId == null || !"cliente".equals(rol)) {
        response.sendRedirect("Login_cliente.jsp");
        return;
    }

    String nombre = "", email = "", fotoUrl = "";

    String dbUrl  = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser = "root";
    String dbPass = "";

    // 1) Cargar datos básicos del cliente
    try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
         PreparedStatement ps = conn.prepareStatement(
             "SELECT nombre, email, foto_url FROM clientes WHERE id = ?"
         )) {
        ps.setInt(1, userId);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                nombre = rs.getString("nombre");
                email  = rs.getString("email");
                fotoUrl= rs.getString("foto_url");
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    // 2) Definir clase interna Favorito (ahora incluye el campo id)
    class Favorito {
        int id;               // ← aquí agregamos el identificador
        String titulo;
        String imagenUrl;
        String negocio;
        String emprendedor;
    }
    java.util.List<Favorito> favoritos = new java.util.ArrayList<>();

    // 3) Cargar la lista de favoritos del cliente (traer f.id)
    try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
         PreparedStatement ps = conn.prepareStatement(
           "SELECT " +
           "  f.id AS fav_id, " +
           "  p.titulo, p.imagen_url, " +
           "  e.negocio, e.nombre AS emprendedor " +
           "FROM favoritos f " +
           "JOIN publicaciones p ON f.publicacion_id = p.id " +
           "JOIN emprendedores e ON p.emprendedor_id = e.id " +
           "WHERE f.cliente_id = ?"
         )) {
        ps.setInt(1, userId);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Favorito f = new Favorito();
                f.id           = rs.getInt("fav_id");            // ← asignamos el id
                f.titulo       = rs.getString("titulo");
                f.imagenUrl    = rs.getString("imagen_url");
                f.negocio      = rs.getString("negocio");
                f.emprendedor  = rs.getString("emprendedor");
                favoritos.add(f);
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
  <title>Mi Perfil – Cliente</title>
  <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
  <style>
    body {
      background-color: #121212;
      color: #e0e0e0;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      margin: 0;
      padding: 0;
    }
    header {
      background-color: #1e1e1e;
      padding: 1rem;
      display: flex;
      justify-content: space-between;
      align-items: center;
      position: relative;
    }
    header h1 {
      margin: 0;
      flex-grow: 1;
      text-align: center;
    }
    .menu-toggle {
      background-color: #00a5a5;
      border: none;
      color: white;
      font-size: 1rem;
      font-weight: bold;
      cursor: pointer;
      padding: 0.75rem 1.5rem;
      border-radius: 6px;
      transition: background-color 0.3s;
    }
    .menu-toggle:hover {
      background-color: #008a8a;
    }
    .nav-menu {
      position: absolute;
      top: 100%;
      right: 1rem;
      background-color: #2a2a2a;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.5);
      min-width: 180px;
      z-index: 1000;
      opacity: 0;
      visibility: hidden;
      transform: translateY(-10px);
      transition: all 0.3s ease;
    }
    .nav-menu.show {
      opacity: 1;
      visibility: visible;
      transform: translateY(0);
    }
    .nav-menu a {
      display: block;
      color: #e0e0e0;
      padding: 0.75rem 1rem;
      text-decoration: none;
      font-weight: bold;
      border-bottom: 1px solid rgba(255, 255, 255, 0.1);
      transition: background-color 0.3s;
    }
    .nav-menu a:last-child {
      border-bottom: none;
    }
    .nav-menu a:hover {
      background-color: #00a5a5;
      color: white;
    }
    .nav-menu a:first-child {
      border-top-left-radius: 8px;
      border-top-right-radius: 8px;
    }
    .nav-menu a:last-child {
      border-bottom-left-radius: 8px;
      border-bottom-right-radius: 8px;
    }
    main {
      max-width: 1200px;
      margin: 2rem auto;
      padding: 1rem;
    }
    .profile-container {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 2rem;
      min-height: 70vh;
    }
    .favoritos-section {
      background: #1f1f1f;
      border-radius: 8px;
      padding: 1.5rem;
      box-shadow: 0 4px 12px rgba(0,0,0,0.5);
    }
    .favoritos-section h2 {
      border-bottom: 2px solid #00a5a5;
      padding-bottom: 0.5rem;
      margin-bottom: 1.5rem;
      margin-top: 0;
    }
    .favoritos-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 1rem;
    }

    /* SECCIÓN DE PERFIL MEJORADA */
    .perfil-section {
      background: linear-gradient(135deg, #2a2a2a 0%, #1f1f1f 100%);
      border-radius: 16px;
      padding: 2rem;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
      border: 1px solid rgba(255, 255, 255, 0.1);
      position: relative;
      overflow: hidden;
    }
    .perfil-section::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      height: 4px;
      background: linear-gradient(90deg, #00a5a5, #00d4d4, #00a5a5);
      background-size: 200% 100%;
      animation: shimmer 3s ease-in-out infinite;
    }
    @keyframes shimmer {
      0%, 100% { background-position: -200% 0; }
      50%      { background-position:  200% 0; }
    }
    .perfil-section h2 {
      color: #ffffff;
      font-size: 1.5rem;
      font-weight: 600;
      margin-bottom: 2rem;
      margin-top: 1rem;
      text-align: center;
      position: relative;
      border: none;
    }
    .perfil-section h2::after {
      content: '';
      position: absolute;
      bottom: -8px;
      left: 50%;
      transform: translateX(-50%);
      width: 60px;
      height: 3px;
      background: linear-gradient(90deg, #00a5a5, #00d4d4);
      border-radius: 2px;
    }
    .info-grid {
      display: grid;
      gap: 1.5rem;
      margin-top: 1rem;
    }
    .info-item {
      background: rgba(255, 255, 255, 0.05);
      border-radius: 12px;
      padding: 1.25rem;
      border-left: 4px solid #00a5a5;
      transition: all 0.3s ease;
      position: relative;
      overflow: hidden;
    }
    .info-item::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: linear-gradient(135deg, rgba(0, 165, 165, 0.1) 0%, transparent 50%);
      opacity: 0;
      transition: opacity 0.3s ease;
    }
    .info-item:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 24px rgba(0, 165, 165, 0.15);
      background: rgba(255, 255, 255, 0.08);
    }
    .info-item:hover::before {
      opacity: 1;
    }
    .info-label {
      color: #00d4d4;
      font-weight: 600;
      font-size: 0.9rem;
      margin-bottom: 0.5rem;
      display: flex;
      align-items: center;
      gap: 0.5rem;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    .info-label::before {
      content: '';
      width: 8px;
      height: 8px;
      background: #00a5a5;
      border-radius: 50%;
      box-shadow: 0 0 8px rgba(0, 165, 165, 0.5);
    }
    .info-value {
      color: #ffffff;
      font-size: 1.1rem;
      font-weight: 500;
      line-height: 1.4;
      position: relative;
      z-index: 1;
    }
    .stats-highlight {
      background: linear-gradient(135deg, rgba(0, 165, 165, 0.2) 0%, rgba(0, 212, 212, 0.1) 100%);
      border-left-color: #00d4d4;
    }
    .stats-highlight .info-value {
      color: #00f0f0;
      font-weight: 600;
      font-size: 1.2rem;
    }
    /* AVATAR MEJORADO */
    .avatar {
      width: 100px;
      height: 100px;
      border-radius: 50%;
      background: linear-gradient(135deg, #00a5a5, #00d4d4);
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto 1.5rem auto;
      overflow: hidden;
      font-size: 2.8rem;
      color: #fff;
      box-shadow: 0 8px 24px rgba(0, 165, 165, 0.3);
      border: 4px solid rgba(255, 255, 255, 0.1);
      transition: all 0.3s ease;
      position: relative;
    }
    .avatar:hover {
      transform: scale(1.05);
      box-shadow: 0 12px 32px rgba(0, 165, 165, 0.4);
    }
    .avatar img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      border-radius: 50%;
      display: block;
    }
    .avatar span {
      display: block;
      width: 100%;
      text-align: center;
      line-height: 1;
      font-weight: 700;
      font-size: 2.8rem;
      text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
    }
    /* RESTO DE ESTILOS ORIGINALES */
    .card {
      background: rgba(255, 255, 255, 0.05);
      border-radius: 8px;
      overflow: hidden;
      box-shadow: 0 2px 8px rgba(0,0,0,0.3);
      transition: transform 0.3s ease;
    }
    .card:hover {
      transform: translateY(-2px);
    }
    .card img {
      width: 100%;
      height: 120px;
      object-fit: cover;
    }
    .card .desc {
      padding: 1rem;
    }
    .desc h3 {
      margin: 0 0 0.5rem;
      font-size: 0.9rem;
    }
    .desc small {
      color: rgba(255,255,255,0.6);
      font-size: 0.8rem;
    }
    @media (max-width: 768px) {
      .profile-container {
        grid-template-columns: 1fr;
        gap: 1rem;
      }
      .favoritos-grid {
        grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
      }
      .perfil-section {
        padding: 1.5rem;
      }
      .avatar {
        width: 80px;
        height: 80px;
        font-size: 2.2rem;
      }
      .info-item {
        padding: 1rem;
      }
      .info-value {
        font-size: 1rem;
      }
    }
    footer {
      background-color: #1e1e1e;
      color: #777;
      text-align: center;
      padding: 1rem;
      margin-top: 2rem;
    }
    .empty-state {
      text-align: center;
      color: rgba(255, 255, 255, 0.6);
      padding: 2rem;
      font-style: italic;
    }
    .photo-options {
      margin-top: 0.5rem;
      text-align: center;
    }
    .photo-options button {
      background-color: #00a5a5;
      color: white;
      border: none;
      padding: 0.5rem 1rem;
      margin: 0 0.5rem;
      cursor: pointer;
      border-radius: 4px;
      font-size: 0.9rem;
    }
    .photo-options button:hover {
      background-color: #008a8a;
    }
    .modal {
      display: none;
      position: fixed;
      z-index: 1000;
      left: 0;
      top: 0;
      width: 100%;
      height: 100%;
      overflow: auto;
      background-color: rgba(0,0,0,0.9);
    }
    .modal-content {
      margin: auto;
      display: block;
      width: 80%;
      max-width: 700px;
      position: relative;
      top: 50%;
      transform: translateY(-50%);
    }
    .close {
      position: absolute;
      top: 15px;
      right: 35px;
      color: #f1f1f1;
      font-size: 40px;
      font-weight: bold;
      cursor: pointer;
    }
    .close:hover,
    .close:focus {
      color: #bbb;
      text-decoration: none;
    }
  </style>
</head>
<body>

<header>
  <div style="width: 4rem;"></div>
  <h1>Mi Perfil – Cliente</h1>
  <button class="menu-toggle" onclick="toggleMenu()">Menú</button>
  <div class="nav-menu" id="navMenu">
    <a href="cliente_perfil.jsp">Perfil</a>
    <a href="calendario_cl.jsp">Calendario</a>
    <a href="cliente_home.jsp">Emprendimientos</a>
    <a href="Logout.jsp" style="color:#ff4d4d;font-weight:bold;">Cerrar sesión</a>
  </div>
</header>

<main>
  <div class="profile-container">
    <!-- COLUMNA IZQUIERDA: FAVORITOS -->
    <div class="favoritos-section">
      <h2>Mis Favoritos</h2>
      <% if (favoritos.isEmpty()) { %>
        <div class="empty-state">
          <p>Aún no has guardado publicaciones como favoritas.</p>
        </div>
      <% } else { %>
        <div class="favoritos-grid">
          <% for (Favorito f : favoritos) { %>
            <div class="card">
              <img src="<%= f.imagenUrl %>" alt="Imagen">
              <div class="desc">
                <h3><%= f.titulo %></h3>
                <small><%= f.negocio %> – <%= f.emprendedor %></small>
                <!-- FORMULARIO PARA QUITAR EL FAVORITO usando f.id -->
                <form action="quitar_favorito.jsp" method="post" style="margin-top:0.5rem;">
                  <input type="hidden" name="favorito_id" value="<%= f.id %>" />
                  <button type="submit"
                          style="background:#ff4d4d;color:#fff;border:none;
                                 padding:0.4rem 1rem;border-radius:4px;
                                 cursor:pointer;">
                    Quitar de favoritos
                  </button>
                </form>
              </div>
            </div>
          <% } %>
        </div>
      <% } %>
    </div>

    <!-- COLUMNA DERECHA: INFORMACIÓN DEL PERFIL -->
    <div class="perfil-section">
      <div class="avatar">
        <% if (fotoUrl != null && !fotoUrl.isEmpty()) { %>
          <img src="<%= fotoUrl %>" alt="Foto de <%= nombre %>" id="profilePhoto" />
        <% } else { %>
          <span><%= (nombre != null && !nombre.isEmpty()) ? nombre.charAt(0) : "?" %></span>
        <% } %>
      </div>

      <h2>Información Personal</h2>
      <div class="info-grid">
        <div class="info-item">
          <div class="info-label">Nombre Completo</div>
          <div class="info-value"><%= (nombre != null) ? nombre : "No especificado" %></div>
        </div>
        <div class="info-item">
          <div class="info-label">Correo Electrónico</div>
          <div class="info-value"><%= (email != null) ? email : "No especificado" %></div>
        </div>
        <div class="info-item">
          <div class="info-label">Tipo de Usuario</div>
          <div class="info-value">Cliente</div>
        </div>
        <div class="info-item stats-highlight">
          <div class="info-label">Favoritos Guardados</div>
          <div class="info-value"><%= favoritos.size() %> publicaciones</div>
        </div>
      </div>
    </div>
  </div>
</main>

<footer>
  © 2025 Red de Apoyo a Emprendedores Locales
</footer>

<!-- MODAL PARA VER FOTO AMPLIADA -->
<div id="photoModal" class="modal">
  <div class="modal-content">
    <span class="close" onclick="closeModal()">&times;</span>
    <img id="modalImage" src="" alt="Foto ampliada" />
  </div>
</div>

<!-- FORMULARIO OCULTO PARA CAMBIAR FOTO DE PERFIL -->
<form id="uploadForm" action="actualizar_foto_action.jsp"
      method="post" enctype="multipart/form-data" style="display:none;">
  <input type="file" name="foto" accept="image/*" onchange="this.form.submit()" />
  <!-- Incluimos también el hidden con el userId del cliente -->
  <input type="hidden" name="cliente_id" value="<%= userId %>" />
</form>

<script>
  function toggleMenu() {
    const menu = document.getElementById('navMenu');
    menu.classList.toggle('show');
  }
  document.addEventListener('click', function(event) {
    const menu   = document.getElementById('navMenu');
    const toggle = document.querySelector('.menu-toggle');
    if (!menu.contains(event.target) && !toggle.contains(event.target)) {
      menu.classList.remove('show');
    }
  });

  function viewPhoto(url) {
    var modal    = document.getElementById('photoModal');
    var modalImg = document.getElementById('modalImage');
    modal.style.display = "block";
    modalImg.src = url;
  }
  function closeModal() {
    var modal = document.getElementById('photoModal');
    modal.style.display = "none";
  }
  function changePhoto() {
    document.querySelector('#uploadForm input[type="file"]').click();
  }
  document.getElementById('photoModal')
          .addEventListener('click', function(event) {
    if (event.target === this) {
      closeModal();
    }
  });
</script>

</body>
</html>
