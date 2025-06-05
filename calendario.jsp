<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>RED_DE_APOYO – Calendario</title>
  <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
  <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.css" rel="stylesheet">
  <style>
    /* Reset & tema oscuro */
    * { box-sizing:border-box; margin:0; padding:0; }
    body {
      font-family:'Segoe UI',sans-serif;
      background:#121212; color:#e0e0e0;
      display:flex; flex-direction:column; min-height:100vh;
    }
    header {
      background:#1e1e1e; padding:1.2rem;
      box-shadow:0 2px 8px rgba(0,0,0,0.3);
    }
    .header-container {
      max-width:1200px; margin:0 auto;
      display:flex; align-items:center;
      justify-content:space-between;
    }
    header h1 { font-size:1.8rem; }
    
    /* Botón de menú hamburguesa */
    .menu-btn {
      background:#008891; 
      color:#fff;
      padding:0.8rem;
      border:none;
      border-radius:6px; 
      cursor:pointer;
      font-size:1.2rem;
      transition:all 0.3s ease;
      display:flex;
      align-items:center;
      gap:0.5rem;
      font-weight:bold;
    }
    .menu-btn:hover { 
      background:#006f78; 
      transform:translateY(-1px);
    }
    
    /* Icono hamburguesa */
    .hamburger {
      width:20px;
      height:16px;
      position:relative;
      display:flex;
      flex-direction:column;
      justify-content:space-between;
    }
    .hamburger span {
      width:100%;
      height:2px;
      background:#fff;
      transition:all 0.3s ease;
      border-radius:1px;
    }
    .hamburger.active span:nth-child(1) {
      transform:rotate(45deg) translate(5px, 5px);
    }
    .hamburger.active span:nth-child(2) {
      opacity:0;
    }
    .hamburger.active span:nth-child(3) {
      transform:rotate(-45deg) translate(7px, -6px);
    }

    /* Overlay del menú */
    .menu-overlay {
      position:fixed;
      top:0; right:0;
      width:100%;
      height:100vh;
      background:rgba(0,0,0,0.6);
      z-index:998;
      opacity:0;
      visibility:hidden;
      transition:all 0.3s ease;
    }
    .menu-overlay.active {
      opacity:1;
      visibility:visible;
    }

    /* Menú lateral desplegable */
    .side-menu {
      position:fixed;
      top:0; right:-350px;
      width:350px;
      height:100vh;
      background:linear-gradient(135deg, #1e1e1e 0%, #2a2a2a 100%);
      z-index:999;
      transition:right 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
      box-shadow:-5px 0 25px rgba(0,0,0,0.3);
      display:flex;
      flex-direction:column;
    }
    .side-menu.active {
      right:0;
    }

    /* Header del menú lateral */
    .menu-header {
      padding:2rem 1.5rem 1rem;
      border-bottom:1px solid #333;
      background:linear-gradient(135deg, #008891 0%, #006f78 100%);
    }
    .menu-header h2 {
      color:#fff;
      font-size:1.4rem;
      margin-bottom:0.5rem;
    }
    .menu-header p {
      color:#b3e5fc;
      font-size:0.9rem;
      opacity:0.9;
    }

    /* Lista de navegación */
    .menu-nav {
      flex:1;
      padding:1rem 0;
    }
    .menu-nav ul {
      list-style:none;
    }
    .menu-nav li {
      margin:0.5rem 0;
    }
    .menu-nav a {
      display:flex;
      align-items:center;
      color:#e0e0e0;
      text-decoration:none;
      padding:1.2rem 1.5rem;
      transition:all 0.3s ease;
      font-weight:400;
      font-size:1rem;
      border-left:3px solid transparent;
    }
    .menu-nav a:hover {
      background:rgba(0, 136, 145, 0.15);
      border-left-color:#008891;
      color:#fff;
    }
    .menu-nav a.active {
      background:rgba(0, 136, 145, 0.25);
      border-left-color:#008891;
      color:#fff;
    }
    .menu-nav a .icon {
      margin-right:1rem;
      font-size:1.1rem;
      opacity:0.7;
      transition:all 0.3s ease;
      width:20px;
      display:inline-block;
      text-align:center;
    }
    .menu-nav a:hover .icon,
    .menu-nav a.active .icon {
      opacity:1;
    }

    /* Botón de login en el menú */
    .menu-login {
      padding:1.5rem;
      border-top:1px solid #333;
    }
    .menu-login .btn {
      width:100%;
      background:linear-gradient(135deg, #008891 0%, #006f78 100%);
      color:#fff;
      padding:1rem;
      border:none;
      border-radius:8px;
      cursor:pointer;
      font-weight:bold;
      font-size:1rem;
      transition:all 0.3s ease;
      box-shadow:0 4px 15px rgba(0, 136, 145, 0.3);
    }
    .menu-login .btn:hover {
      transform:translateY(-2px);
      box-shadow:0 6px 20px rgba(0, 136, 145, 0.4);
    }

    /* Botón de cerrar */
    .close-menu {
      position:absolute;
      top:1rem; right:1rem;
      background:rgba(255,255,255,0.1);
      border:none;
      color:#fff;
      width:40px; height:40px;
      border-radius:50%;
      cursor:pointer;
      font-size:1.2rem;
      transition:all 0.3s ease;
    }
    .close-menu:hover {
      background:rgba(255,255,255,0.2);
      transform:rotate(90deg);
    }

    main {
      flex:1; padding:2rem 1rem;
      max-width:960px; margin:0 auto;
    }
    h2 {
      text-align:center; margin-bottom:1.5rem;
      font-size:1.8rem; position:relative; color:#fff;
    }
    h2::after {
      content:''; position:absolute;
      bottom:-6px; left:50%;
      transform:translateX(-50%);
      width:80px; height:3px;
      background:#008891;
    }
    #calendar {
      background:#1f1f1f; border-radius:8px;
      padding:1rem;
    }
    footer {
      background:#1e1e1e; text-align:center;
      padding:1rem; margin-top:auto; color:#888;
    }

    /* Modal sólo lectura */
    .modal {
      display:none; position:fixed; inset:0;
      background:rgba(0,0,0,0.6);
      justify-content:center; align-items:center;
      z-index:1000;
    }
    .modal-content {
      background:#1e1e1e; color:#e0e0e0;
      padding:1.5rem; border-radius:8px;
      width:90%; max-width:400px;
      position:relative;
      box-shadow:0 4px 12px rgba(0,0,0,0.5);
    }
    .modal-content h3 {
      margin-bottom:1rem; font-size:1.3rem;
    }
    .modal-content .field {
      margin-top:1rem;
    }
    .modal-content label {
      font-weight:500;
      display:block;
      margin-bottom:.3rem;
    }
    .modal-content span {
      display:block;
      padding:.5rem;
      background:#2a2a2a;
      border-radius:4px;
    }
    .close {
      position:absolute; top:.5rem; right:.75rem;
      font-size:1.2rem; cursor:pointer; color:#888;
    }
    .close:hover { color:#fff; }

    /* Responsive */
    @media (max-width: 768px) {
      .side-menu {
        width:280px;
        right:-280px;
      }
      .menu-header {
        padding:1.5rem 1rem;
      }
      .menu-nav a {
        padding:0.8rem 1rem;
      }
    }
  </style>
</head>
<body>

<header>
  <div class="header-container">
    <h1>RED_DE_APOYO</h1>
    <button class="menu-btn" id="menuBtn">
      <div class="hamburger">
        <span></span>
        <span></span>
        <span></span>
      </div>
      
    </button>
  </div>
</header>

<!-- Overlay del menú -->
<div class="menu-overlay" id="menuOverlay"></div>

<!-- Menú lateral -->
<div class="side-menu" id="sideMenu">
  <button class="close-menu" id="closeMenu">×</button>
  
  <div class="menu-header">
    <h2>Navegación</h2>
    <p>Explora todas las secciones</p>
  </div>
  
  <nav class="menu-nav">
    <ul>
      <li><a href="index.jsp"><span class="icon">⌂</span>Inicio</a></li>
      <li><a href="emprendimientos.jsp"><span class="icon">👤</span>Emprendimientos</a></li>
      <li><a href="calendario.jsp" class="active"><span class="icon">📋</span>Calendario</a></li>
    </ul>
  </nav>
  
  <div class="menu-login">
    <button class="btn" onclick="location.href='seleccionar_rol.jsp'">Iniciar Sesión</button>
  </div>
</div>

<main>
  <h2>Calendario de Eventos</h2>
  <div id="calendar"></div>
</main>

<!-- Modal de sólo lectura -->
<div id="viewModal" class="modal">
  <div class="modal-content">
    <span class="close">&times;</span>
    <h3>Detalles del Evento</h3>
    <div class="field">
      <label>Fecha y hora inicio:</label>
      <span id="view-start"></span>
    </div>
    <div class="field">
      <label>Fecha y hora fin:</label>
      <span id="view-end"></span>
    </div>
    <div class="field">
      <label>Título:</label>
      <span id="view-title"></span>
    </div>
    <div class="field">
      <label>Descripción:</label>
      <span id="view-desc"></span>
    </div>
  </div>
</div>

<footer>
  &copy; 2025 Red de Apoyo a Emprendedores Locales
</footer>

<!-- FullCalendar JS -->
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@fullcalendar/interaction@6.1.8/index.global.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@fullcalendar/daygrid@6.1.8/index.global.min.js"></script>

<script>
document.addEventListener('DOMContentLoaded', () => {
  // Elementos del menú lateral
  const menuBtn = document.getElementById('menuBtn');
  const sideMenu = document.getElementById('sideMenu');
  const menuOverlay = document.getElementById('menuOverlay');
  const closeMenu = document.getElementById('closeMenu');
  const hamburger = menuBtn.querySelector('.hamburger');

  // Función para abrir menú
  function openMenu() {
    sideMenu.classList.add('active');
    menuOverlay.classList.add('active');
    hamburger.classList.add('active');
    document.body.style.overflow = 'hidden'; // Prevenir scroll
  }

  // Función para cerrar menú
  function closeMenuFunc() {
    sideMenu.classList.remove('active');
    menuOverlay.classList.remove('active');
    hamburger.classList.remove('active');
    document.body.style.overflow = 'auto';
  }

  // Event listeners del menú
  menuBtn.addEventListener('click', openMenu);
  closeMenu.addEventListener('click', closeMenuFunc);
  menuOverlay.addEventListener('click', closeMenuFunc);

  // Cerrar con tecla Escape
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && sideMenu.classList.contains('active')) {
      closeMenuFunc();
    }
  });

  // Funcionalidad del modal y calendario (código original)
  const modal    = document.getElementById('viewModal');
  const closeBtn = modal.querySelector('.close');
  const startEl  = document.getElementById('view-start');
  const endEl    = document.getElementById('view-end');
  const titleEl  = document.getElementById('view-title');
  const descEl   = document.getElementById('view-desc');

  closeBtn.onclick = () => modal.style.display = 'none';
  window.onclick    = e => { 
    if (e.target === modal) modal.style.display = 'none'; 
  };

  const calendar = new FullCalendar.Calendar(
    document.getElementById('calendar'),
    {
      initialView: 'dayGridMonth',
      headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: 'dayGridMonth,timeGridWeek,timeGridDay,listWeek'
      },
      editable: false,
      selectable: true,
      events: 'cargar_eventos.jsp',

      // Si haces clic en un día
      dateClick: info => {
        // buscamos eventos de ese día
        const events = calendar.getEvents().filter(e =>
          e.start.toISOString().slice(0,10) === info.dateStr
        );

        if (events.length === 0) {
          // No hay ninguno
          startEl.textContent = info.dateStr;
          endEl.textContent   = '—';
          titleEl.textContent = 'Sin evento agendado';
          descEl.textContent  = '—';
          modal.style.display = 'flex';
        }
      },

      // Si haces clic en un evento
      eventClick: info => {
        const ev = info.event;
        startEl.textContent = ev.startStr.replace('T',' ');
        endEl.textContent   = ev.endStr ? ev.endStr.replace('T',' ') : '—';
        titleEl.textContent = ev.title;
        descEl.textContent  = ev.extendedProps.description || '—';
        modal.style.display = 'flex';
      }
    }
  );

  calendar.render();
});
</script>
</body>
</html>