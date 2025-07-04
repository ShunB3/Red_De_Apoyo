<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>RED_DE_APOYO – Calendario</title>
  <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
  <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.css" rel="stylesheet">

  <style>
    /* ===== Reset & tema oscuro ===== */
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    body {
      font-family: 'Segoe UI', sans-serif;
      background: #121212;
      color: #e0e0e0;
      display: flex;
      flex-direction: column;
      min-height: 100vh;
    }

    /* ===== HEADER ===== */
    header {
      background-color: #1a1a1a;
      padding: 20px 0;
      box-shadow: 0 2px 10px rgba(0,0,0,0.5);

      /* Para centrar el <h1> */
      display: flex;
      justify-content: center;
      align-items: center;

      /* Necesario para posicionar absolutamente el botón dentro de él */
      position: relative;
    }

    header h1 {
      font-size: 2.2rem;
      color: #fff;
      position: relative;
      text-align: center;
    }

    header h1::after {
      content: '';
      position: absolute;
      bottom: -8px;
      left: 50%;
      transform: translateX(-50%);
      width: 80px;
      height: 3px;
      background: #00a5a5;
    }

    /* ===== BOTÓN “Menú” ===== */
    .menu-button {
      position: absolute;
      right: 20px;
      top: 50%;
      transform: translateY(-50%);

      background-color: #00a5a5;
      color: #fff;
      border: none;
      padding: 10px 20px;
      border-radius: 4px;
      cursor: pointer;
      font-weight: bold;
      font-size: 16px;
      transition: background-color 0.3s;
      z-index: 2;
    }
    .menu-button:hover {
      background-color: #008080;
    }

    /* ===== DROPDOWN MENU ===== */
    .dropdown {
      position: relative;
      display: inline-block;
    }

    .dropdown-content {
      display: none;
      position: fixed; /* Para que quede siempre visible al hacer scroll */
      background-color: #1f1f1f;
      min-width: 200px;
      box-shadow: 0 8px 16px rgba(0,0,0,0.5);
      border-radius: 4px;
      z-index: 1000;
      right: 20px;  /* Igual que el right del botón */
      top: 80px;    /* Un poco debajo del header */
      border: 1px solid #333;
      animation: slideInRight 0.3s ease-out;
    }

    @keyframes slideInRight {
      from {
        transform: translateX(100%);
        opacity: 0;
      }
      to {
        transform: translateX(0);
        opacity: 1;
      }
    }

    .dropdown-content a {
      color: #fff;
      padding: 12px 16px;
      text-decoration: none;
      display: block;
      transition: background-color 0.3s;
    }
    .dropdown-content a:hover {
      background-color: #00a5a5;
    }
    .dropdown-content a:first-child {
      border-top-left-radius: 4px;
      border-top-right-radius: 4px;
    }
    .dropdown-content a:last-child {
      border-bottom-left-radius: 4px;
      border-bottom-right-radius: 4px;
      border-bottom: none;
    }

    /* Cuando el dropdown está activo */
    .dropdown.active .dropdown-content {
      display: block;
    }

    /* ===== MAIN & CALENDARIO ===== */
    main {
      flex: 1;
      padding: 2rem 1rem;
      max-width: 960px;
      margin: 0 auto;
    }
    h2 {
      text-align: center;
      margin-bottom: 1.5rem;
      font-size: 1.8rem;
      position: relative;
      color: #fff;
    }
    h2::after {
      content: '';
      position: absolute;
      bottom: -6px;
      left: 50%;
      transform: translateX(-50%);
      width: 80px;
      height: 3px;
      background: #008891;
    }
    #calendar {
      background: #1f1f1f;
      border-radius: 8px;
      padding: 1rem;
    }

    /* ===== MODAL de solo lectura ===== */
    .modal {
      display: none;
      position: fixed;
      inset: 0;
      background: rgba(0,0,0,0.6);
      justify-content: center;
      align-items: center;
      z-index: 1000;
    }
    .modal-content {
      background: #1e1e1e;
      color: #e0e0e0;
      padding: 1.5rem;
      border-radius: 8px;
      width: 90%;
      max-width: 400px;
      position: relative;
      box-shadow: 0 4px 12px rgba(0,0,0,0.5);
    }
    .modal-content h3 {
      margin-bottom: 1rem;
      font-size: 1.3rem;
    }
    .modal-content .field {
      margin-top: 1rem;
    }
    .modal-content label {
      font-weight: 500;
      display: block;
      margin-bottom: 0.3rem;
    }
    .modal-content span {
      display: block;
      padding: 0.5rem;
      background: #2a2a2a;
      border-radius: 4px;
    }
    .close {
      position: absolute;
      top: 0.5rem;
      right: 0.75rem;
      font-size: 1.2rem;
      cursor: pointer;
      color: #888;
    }
    .close:hover {
      color: #fff;
    }

    /* ===== FOOTER ===== */
    footer {
      background: #1e1e1e;
      text-align: center;
      padding: 1rem;
      margin-top: auto;
      color: #888;
    }
  </style>
</head>

<body>
  <!-- HEADER -->
  <header>
    <!-- Título centrado -->
    <h1>Calendario</h1>

    <!-- Botón Menú posicionado a la derecha -->
    <button class="menu-button" onclick="toggleDropdown()">Menú</button>

    <!-- Dropdown que aparece desde la derecha -->
    <div class="dropdown">
      <div class="dropdown-content" id="dropdown-menu">
        <a href="cliente_perfil.jsp">Perfil</a>
        <a href="calendario_cl.jsp">Calendario</a>
        <a href="cliente_home.jsp">Emprendimientos</a>
        <a href="Logout.jsp" style="color:#ff4d4d;font-weight:bold;">Cerrar sesión</a>
      </div>
    </div>
  </header>

  <!-- MAIN Y CALENDARIO -->
  <main>
    <h2>Calendario de Eventos</h2>
    <div id="calendar"></div>
  </main>

  <!-- MODAL de solo lectura -->
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
    function toggleDropdown() {
      const dropdown = document.querySelector('.dropdown');
      dropdown.classList.toggle('active');
    }
    // Cerrar dropdown al hacer clic fuera de él
    window.onclick = function(event) {
      if (!event.target.matches('.menu-button')) {
        const dropdown = document.querySelector('.dropdown');
        if (dropdown.classList.contains('active')) {
          dropdown.classList.remove('active');
        }
      }
    };

    document.addEventListener('DOMContentLoaded', () => {
      const modal    = document.getElementById('viewModal');
      const closeBtn = modal.querySelector('.close');
      const startEl  = document.getElementById('view-start');
      const endEl    = document.getElementById('view-end');
      const titleEl  = document.getElementById('view-title');
      const descEl   = document.getElementById('view-desc');

      closeBtn.onclick = () => modal.style.display = 'none';

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
