<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // Aseguramos que sólo entren mentores
    Integer mentorId = (Integer) session.getAttribute("userId");
    String rol       = (String)  session.getAttribute("rol");
    if (mentorId == null || !"mentor".equals(rol)) {
        response.sendRedirect("Login_mentor.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Ayuda – Mentores</title>
  <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background: #121212; color: #e0e0e0;
      font-family: 'Segoe UI', sans-serif;
      min-height: 100vh; display: flex; flex-direction: column;
    }
    header {
      background: #1e1e1e; padding: 1rem 2rem;
      display: flex; justify-content: space-between; align-items: center;
      box-shadow: 0 2px 10px rgba(0,0,0,0.5); position: sticky; top: 0; z-index: 100;
    }
    header h1 { font-size: 1.8rem; }
    .menu-toggle {
      background: none; border: 1px solid rgba(0,128,128,0.3);
      color: #e0e0e0; padding: 0.5rem 1rem; border-radius: 6px;
      cursor: pointer; transition: background 0.3s;
    }
    .menu-toggle:hover { background: rgba(0,128,128,0.1); }

    .menu-overlay {
      position: fixed; top: 0; left: 0; width: 100vw; height: 100vh;
      background: rgba(0,0,0,0.7); visibility: hidden; opacity: 0;
      transition: opacity 0.4s; z-index: 90;
    }
    .menu-overlay.active { visibility: visible; opacity: 1; }
    .side-menu {
      position: fixed; top: 0; right: -350px; width: 350px; height: 100vh;
      background: #1e1e1e; box-shadow: -8px 0 32px rgba(0,0,0,0.8);
      transition: right 0.5s; z-index: 95;
    }
    .side-menu.active { right: 0; }
    .side-menu-header {
      padding: 1.5rem; background: #121212;
      display: flex; justify-content: space-between; align-items: center;
    }
    .side-menu-title { color: #00a5a5; font-size: 1.3rem; }
    .close-menu {
      background: none; border: none; color: #ccc; font-size: 1.5rem;
      cursor: pointer;
    }
    .side-menu-content { padding: 1rem; }
    .menu-section { margin-bottom: 1.5rem; }
    .menu-section-title {
      color: #00a5a5; font-size: 0.8rem; font-weight: 600;
      text-transform: uppercase; margin-bottom: 0.5rem;
      border-bottom: 1px solid #444; padding-bottom: 0.3rem;
    }
    .menu-item {
      display: flex; align-items: center; gap: 0.5rem;
      padding: 0.75rem; color: #ccc;
      transition: background 0.3s, border-left-color 0.3s;
      border-left: 4px solid transparent;
      text-decoration: none;
    }
    .menu-item:hover, .menu-item.active {
      background: rgba(0,165,165,0.1);
      border-left-color: #00a5a5;
      color: #00a5a5;
    }

    main {
      flex: 1; padding: 2rem; max-width: 800px; margin: 0 auto;
      line-height: 1.6;
    }
    h2 { color: #00c1c1; font-size: 1.6rem; margin-bottom: 1rem; }
    .section { margin-bottom: 1.5rem; }
    .section-title { font-weight: 600; margin-bottom: 0.5rem; }
    ul { margin-left: 1.2rem; list-style: disc; }
    footer {
      background: #1e1e1e; text-align: center; padding: 1rem;
      font-size: 0.9rem; color: #777;
    }
  </style>
</head>
<body>
  <header>
    <h1>Ayuda – Mentores</h1>
    <button class="menu-toggle" onclick="toggleMenu()">☰ Menú</button>
  </header>

  <div class="menu-overlay" onclick="closeMenu()"></div>
  <div class="side-menu" id="sideMenu">
    <div class="side-menu-header">
      <div class="side-menu-title">Menú</div>
      <button class="close-menu" onclick="closeMenu()">&times;</button>
    </div>
    <div class="side-menu-content">
      <div class="menu-section">
        <div class="menu-section-title">Mentores</div>
        <a href="mentor_home.jsp" class="menu-item"><span>🏠</span> Panel Principal</a>
        <a href="perfil_mentor.jsp" class="menu-item"><span>💬</span> Mi Perfil</a>
        <a href="mis_mentoreados.jsp" class="menu-item"><span>👥</span> Mis Mentoreados</a>
        <a href="ayuda.jsp" class="menu-item active"><span>❓</span> Ayuda</a>
      </div>
      <div class="menu-section">
        <div class="menu-section-title">Cuenta</div>
        <a href="Logout.jsp" class="menu-item"><span>🚪</span> Cerrar Sesión</a>
      </div>
    </div>
  </div>

  <main>
    <h2>Guía rápida para Mentores</h2>

    <div class="section">
      <div class="section-title">1. Panel Principal</div>
      Aquí ves tu resumen: cuántos mentoreados tienes y cuántas consultas te han hecho.  
      Usa el botón de estado (puntito de color) para mostrar si estás en línea, ausente o no molestar.
    </div>

    <div class="section">
      <div class="section-title">2. Mi Perfil</div>
      Completa o edita tu información personal (nombre, email, especialidad, experiencia y tarifa)  
      desde la opción “✏️ Editar Perfil”.
    </div>

    <div class="section">
      <div class="section-title">3. Solicitudes Pendientes</div>
      Cuando un emprendedor te contacte, lo verás listados aquí.  
      - ✅ Aceptar: pasa a tu lista de mentoreados.  
      - ❌ Rechazar: cancela la solicitud.  
      - 📄 Ver Descripción: lee el mensaje completo.
    </div>

    <div class="section">
      <div class="section-title">4. Mis Mentoreados</div>
      Revisa a los emprendedores que ya aceptaste:
      <ul>
        <li>📄 “Ver Publicaciones” para checar sus posts.</li>
        <li>📲 “WhatsApp” para chatear rápido si dejaron número.</li>
      </ul>
    </div>

    <div class="section">
      <div class="section-title">5. Navegación</div>
      Usa el menú lateral para moverte entre Panel, Perfil, Mentoreados y Ayuda sin perderte.
    </div>

    <div class="section">
      <div class="section-title">6. Cerrar Sesión</div>
      Al terminar, haz clic en “Cerrar Sesión” para mantener tu cuenta segura.
    </div>
  </main>

  <footer>
    &copy; 2025 Red de Apoyo a Emprendedores Locales
  </footer>

  <script>
    function toggleMenu() {
      document.getElementById('sideMenu').classList.toggle('active');
      document.querySelector('.menu-overlay').classList.toggle('active');
    }
    function closeMenu() {
      document.getElementById('sideMenu').classList.remove('active');
      document.querySelector('.menu-overlay').classList.remove('active');
    }
  </script>
</body>
</html>
