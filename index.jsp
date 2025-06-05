<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>RED_DE_APOYO – Red de Apoyo a Emprendedores Locales</title>
  <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
  <style>
    /* Reset y tema oscuro */
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Segoe UI', Arial, sans-serif;
      background-color: #121212;
      color: #e0e0e0;
      display: flex;
      flex-direction: column;
      min-height: 100vh;
    }

    /* Header */
    header {
      background-color: #1e1e1e;
      padding: 1.2rem;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
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

    /* Main */
    main {
      flex: 1;
      padding: 2rem;
    }

    main section {
      max-width: 900px;
      margin: 0 auto;
      background-color: #1a1a1a;
      border-radius: 8px;
      padding: 2rem;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
    }

    main h2 {
      font-size: 1.8rem;
      margin-bottom: 1.5rem;
      text-align: center;
      color: #fff;
      position: relative;
      padding-bottom: 0.8rem;
    }

    main h2::after {
      content: '';
      position: absolute;
      bottom: 0;
      left: 50%;
      transform: translateX(-50%);
      width: 80px;
      height: 3px;
      background-color: #008891;
    }

    main ul {
      margin: 1.5rem 0 1.5rem 1.5rem;
      list-style: none;
    }

    main li {
      margin-bottom: 1rem;
      position: relative;
      padding-left: 1.5rem;
    }

    main li::before {
      content: '•';
      color: #008891;
      position: absolute;
      left: 0;
      font-weight: bold;
      font-size: 1.2rem;
    }

    main p {
      margin-bottom: 1rem;
    }

    strong {
      color: #fff;
    }

    /* Footer */
    footer {
      background-color: #1e1e1e;
      text-align: center;
      padding: 1rem;
      margin-top: auto;
      color: #888;
      box-shadow: 0 -2px 8px rgba(0, 0, 0, 0.3);
    }

    /* Botón Admin */
    #adminAccessBtn {
      position: fixed;
      bottom: 15px;
      right: 15px;
      background-color: #008891;
      color: #fff;
      padding: 8px 14px;
      font-size: 0.85rem;
      font-weight: bold;
      border-radius: 4px;
      text-decoration: none;
      opacity: 0.1;
      transition: opacity 0.3s ease;
      z-index: 999;
    }

    #adminAccessBtn:hover {
      opacity: 1;
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
          <a href="index.jsp" class="active">
            <svg class="menu-icon" fill="currentColor" viewBox="0 0 20 20">
              <path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z"/>
            </svg>
            Inicio
          </a>
        </li>
        <li>
          <a href="emprendimientos.jsp">
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
    <section>
      <h2>¿En qué se basa nuestro proyecto?</h2>
      <p>La Red de Apoyo a Emprendedores Locales (<strong>RED_DE_APOYO</strong>) es una plataforma diseñada para:</p>
      <ul>
        <li>Conectar emprendedores con clientes interesados en sus productos o servicios.</li>
        <li>Ofrecer una sección de capacitaciones y conferencias para el crecimiento profesional.</li>
        <li>Facilitar la interacción: comentar, dar "me gusta" y compartir publicaciones.</li>
        <li>Permitir a los clientes guardar sus emprendimientos favoritos.</li>
      </ul>
      <p>Únete y forma parte de una comunidad que impulsa el emprendimiento local.</p>
    </section>
  </main>

  <footer>
    &copy; 2025 Red de Apoyo a Emprendedores Locales
  </footer>

  <!-- Botón oculto para admin -->
  <a href="Login_admin.jsp" id="adminAccessBtn" title="Acceso administrador">Admin</a>

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