<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    // No se requiere sesión aquí, porque al hacer clic se redirige a login si no hay cliente
    String dbUrl      = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser     = "root";
    String dbPassword = "";

    // Clase interna con los campos adicionales de producto
    class Pub {
        int id;
        String titulo;
        String descripcion;
        String negocio;
        String emprNombre;
        String imagenUrl;
    }
    java.util.List<Pub> list = new java.util.ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
             PreparedStatement ps = conn.prepareStatement(
               "SELECT " +
               "  p.id, p.titulo, p.descripcion, p.imagen_url, " +
               "  e.negocio, e.nombre " +
               "FROM publicaciones p " +
               "JOIN emprendedores e ON p.emprendedor_id = e.id " +
               "ORDER BY p.fecha_publicacion DESC"
             );
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Pub item = new Pub();
                item.id          = rs.getInt("id");
                item.titulo      = rs.getString("titulo");
                item.descripcion = rs.getString("descripcion");
                item.imagenUrl   = rs.getString("imagen_url");
                item.negocio     = rs.getString("negocio");
                item.emprNombre  = rs.getString("nombre");
                list.add(item);
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
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Emprendimientos</title>
  <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
  <style>
    /* Reset y tema oscuro */
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Segoe UI', Arial, sans-serif;
      background-color: #121212;
      color: #ffffff;
      display: flex;
      flex-direction: column;
      min-height: 100vh;
    }

    /* Header */
    header {
      background-color: #1e1e1e;
      padding: 1rem;
      position: relative;
      border-bottom: 2px solid #333;
    }
    .header-container {
      max-width: 1200px;
      margin: 0 auto;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    header h1 {
      font-size: 1.8rem;
      color: #fff;
      font-weight: 600;
    }

    /* Botón de menú hamburguesa */
    .menu-toggle {
      background: none;
      border: none;
      color: #fff;
      font-size: 1.5rem;
      cursor: pointer;
      padding: 0.5rem;
      border-radius: 4px;
      transition: background-color 0.3s ease;
      position: relative;
      z-index: 1001;
    }
    .menu-toggle:hover {
      background-color: #333;
    }

    /* Icono hamburguesa */
    .hamburger {
      width: 24px;
      height: 18px;
      position: relative;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
    }
    .hamburger span {
      width: 100%;
      height: 2px;
      background-color: #fff;
      border-radius: 2px;
      transition: all 0.3s ease;
    }

    /* Animación del icono cuando está activo */
    .menu-toggle.active .hamburger span:nth-child(1) {
      transform: rotate(45deg) translate(5px, 5px);
    }
    .menu-toggle.active .hamburger span:nth-child(2) {
      opacity: 0;
    }
    .menu-toggle.active .hamburger span:nth-child(3) {
      transform: rotate(-45deg) translate(7px, -6px);
    }

    /* Overlay para cerrar el menú */
    .menu-overlay {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background-color: rgba(0, 0, 0, 0.5);
      opacity: 0;
      visibility: hidden;
      transition: all 0.3s ease;
      z-index: 998;
    }
    .menu-overlay.active {
      opacity: 1;
      visibility: visible;
    }

    /* Menú desplegable */
    .slide-menu {
      position: fixed;
      top: 0;
      right: -350px;
      width: 350px;
      height: 100vh;
      background: linear-gradient(135deg, #1e1e1e 0%, #2a2a2a 100%);
      box-shadow: -5px 0 15px rgba(0, 0, 0, 0.3);
      transition: right 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      z-index: 999;
      display: flex;
      flex-direction: column;
    }
    .slide-menu.active {
      right: 0;
    }

    /* Header del menú */
    .menu-header {
      padding: 2rem 1.5rem 1.5rem;
      border-bottom: 1px solid #333;
    }
    .menu-header h2 {
      color: #00c1c1;
      font-size: 1.4rem;
      margin-bottom: 0.5rem;
    }
    .menu-header p {
      color: #aaa;
      font-size: 0.9rem;
    }

    /* Navegación del menú */
    .menu-nav {
      flex: 1;
      padding: 1rem 0;
    }
    .menu-nav ul {
      list-style: none;
      padding: 0;
      margin: 0;
    }
    .menu-nav li {
      margin: 0.5rem 0;
    }
    .menu-nav a {
      display: flex;
      align-items: center;
      padding: 1rem 1.5rem;
      color: #e0e0e0;
      text-decoration: none;
      font-weight: 500;
      transition: all 0.3s ease;
      position: relative;
    }
    .menu-nav a:hover {
      background-color: #333;
      color: #00c1c1;
      transform: translateX(5px);
    }
    .menu-nav a.active {
      background-color: #008891;
      color: #fff;
    }
    .menu-nav a.active::before {
      content: '';
      position: absolute;
      left: 0;
      top: 0;
      bottom: 0;
      width: 4px;
      background-color: #00c1c1;
    }

    /* Iconos del menú */
    .menu-icon {
      width: 20px;
      height: 20px;
      margin-right: 1rem;
      opacity: 0.7;
    }

    /* Footer del menú */
    .menu-footer {
      padding: 1.5rem;
      border-top: 1px solid #333;
    }
    .login-btn {
      width: 100%;
      background: linear-gradient(135deg, #008891 0%, #00a5a5 100%);
      color: #fff;
      padding: 0.8rem 1rem;
      border: none;
      border-radius: 6px;
      cursor: pointer;
      font-weight: 600;
      font-size: 1rem;
      transition: transform 0.2s ease, box-shadow 0.2s ease;
    }
    .login-btn:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(0, 136, 145, 0.4);
    }

    /* Responsive */
    @media (max-width: 480px) {
      .slide-menu {
        width: 100%;
        right: -100%;
      }
    }

    /* Contenedor principal */
    main {
      flex: 1;
      padding: 2rem 1rem;
    }

    /* Grid de emprendimientos */
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 1.8rem;
      max-width: 1200px;
      margin: 2rem auto;
      padding: 0 1.5rem;
    }

    /* Tarjetas */
    .card {
      background: #1f1f1f;
      border-radius: 8px;
      overflow: hidden;
      box-shadow: 0 4px 12px rgba(0,0,0,0.5);
      display: flex;
      flex-direction: column;
      transition: transform 0.3s, box-shadow 0.3s;
      cursor: pointer;
      text-decoration: none;
      color: inherit;
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
      padding: 1rem;
      flex: 1;
      display: flex;
      flex-direction: column;
    }
    .info h3 {
      font-size: 1.25rem;
      margin-bottom: 0.5rem;
      color: #00c1c1;
    }
    .info p.desc {
      font-size: 0.95rem;
      margin-bottom: 0.75rem;
      color: #ccc;
      flex-grow: 1;
    }
    .info .meta {
      font-size: 0.9rem;
      color: rgba(255,255,255,0.7);
      margin-bottom: 0.5rem;
    }
    .info .meta strong {
      color: #00a5a5;
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

    /* Footer */
    footer {
      background-color: #1e1e1e;
      text-align: center;
      padding: 1rem;
      margin-top: auto;
      color: #777;
    }
  </style>
</head>
<body>
  <header>
    <div class="header-container">
      <h1>RED_DE_APOYO</h1>
      
      <!-- Botón de menú hamburguesa -->
      <button class="menu-toggle" id="menuToggle">
        <div class="hamburger">
          <span></span>
          <span></span>
          <span></span>
        </div>
      </button>
    </div>
  </header>

  <!-- Overlay para cerrar el menú -->
  <div class="menu-overlay" id="menuOverlay"></div>

  <!-- Menú deslizante -->
  <div class="slide-menu" id="slideMenu">
    <div class="menu-header">
      <h2>Navegación</h2>
      <p>Explora todas las secciones</p>
    </div>
    
    <nav class="menu-nav">
      <ul>
        <li>
          <a href="index.jsp">
            <svg class="menu-icon" fill="currentColor" viewBox="0 0 20 20">
              <path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z"/>
            </svg>
            Inicio
          </a>
        </li>
        <li>
          <a href="emprendimientos.jsp" class="active">
            <svg class="menu-icon" fill="currentColor" viewBox="0 0 20 20">
              <path d="M13 6a3 3 0 11-6 0 3 3 0 016 0zM18 8a2 2 0 11-4 0 2 2 0 014 0zM14 15a4 4 0 00-8 0v3h8v-3z"/>
            </svg>
            Emprendimientos
          </a>
        </li>
        <li>
          <a href="calendario.jsp">
            <svg class="menu-icon" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clipRule="evenodd"/>
            </svg>
            Calendario
          </a>
        </li>
      </ul>
    </nav>
    
    <div class="menu-footer">
      <button class="login-btn" onclick="location.href='seleccionar_rol.jsp'">
        Iniciar Sesión
      </button>
    </div>
  </div>

  <main>
    <div class="grid">
      <% if (list.isEmpty()) { %>
        <div class="empty-message">
          No hay emprendimientos para mostrar en este momento.
        </div>
      <% } else {
           for (Pub p : list) {
      %>
      <!--
        La tarjeta entera es un enlace. Al hacer clic, lleva a Login_cliente.jsp
        para forzar login si no se ha iniciado sesión como cliente.
      -->
      <a href="Login_cliente.jsp" class="card">
        <img src="<%= (p.imagenUrl != null && !p.imagenUrl.isEmpty()) ? p.imagenUrl : "images/default-business.jpg" %>"
             alt="Imagen de <%= p.negocio %>">
        <div class="info">
          <!-- Nombre del producto -->
          <h3><%= p.titulo %></h3>
          <!-- Descripción del producto -->
          <p class="desc"><%= p.descripcion %></p>
          <!-- Nombre del negocio y emprendedor -->
          <div class="meta">
            <div><strong>Negocio:</strong> <%= p.negocio %></div>
            <div><strong>Emprendedor:</strong> <%= p.emprNombre %></div>
          </div>
        </div>
      </a>
      <%   }
         }
      %>
    </div>
  </main>

  <footer>
    &copy; 2025 Red de Apoyo a Emprendedores Locales
  </footer>

  <script>
    // Elementos del DOM
    const menuToggle = document.getElementById('menuToggle');
    const slideMenu = document.getElementById('slideMenu');
    const menuOverlay = document.getElementById('menuOverlay');

    // Función para abrir el menú
    function openMenu() {
      menuToggle.classList.add('active');
      slideMenu.classList.add('active');
      menuOverlay.classList.add('active');
      document.body.style.overflow = 'hidden'; // Prevenir scroll
    }

    // Función para cerrar el menú
    function closeMenu() {
      menuToggle.classList.remove('active');
      slideMenu.classList.remove('active');
      menuOverlay.classList.remove('active');
      document.body.style.overflow = 'auto'; // Restaurar scroll
    }

    // Event listeners
    menuToggle.addEventListener('click', function() {
      if (slideMenu.classList.contains('active')) {
        closeMenu();
      } else {
        openMenu();
      }
    });

    // Cerrar menú al hacer clic en el overlay
    menuOverlay.addEventListener('click', closeMenu);

    // Cerrar menú con la tecla Escape
    document.addEventListener('keydown', function(e) {
      if (e.key === 'Escape' && slideMenu.classList.contains('active')) {
        closeMenu();
      }
    });

    // Cerrar menú al hacer clic en un enlace (opcional)
    const menuLinks = document.querySelectorAll('.menu-nav a');
    menuLinks.forEach(link => {
      link.addEventListener('click', closeMenu);
    });
  </script>
</body>
</html>