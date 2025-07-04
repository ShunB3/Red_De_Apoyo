<%@ page contentType="text/html; charset=UTF-8" language="java" %>
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
  <title>Admin – Calendario</title>
  <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
  <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.css" rel="stylesheet">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Segoe UI', Arial, sans-serif;
      background-color: #121212;
      color: #e0e0e0;
      display: flex;
      flex-direction: column;
      min-height: 100vh;
    }
    header {
      background-color: #1e1e1e;
      padding: 1.2rem;
      box-shadow: 0 2px 8px rgba(0,0,0,0.3);
    }
    .header-container {
      max-width: 1200px;
      margin: 0 auto;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    header h1 { font-size: 1.8rem; }
    nav ul {
      list-style: none;
      display: flex;
      gap: 1.5rem;
    }
    nav a {
      color: #e0e0e0;
      text-decoration: none;
      padding: 0.5rem 1rem;
      border-radius: 4px;
      font-weight: bold;
      transition: background 0.3s;
    }
    nav a:hover, nav a.active {
      background: #008891;
      color: #fff;
    }
    .btn {
      background: #008891;
      color: #fff;
      padding: 0.5rem 1rem;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-weight: bold;
      transition: background 0.3s;
    }
    .btn:hover { background: #006f78; }

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
    footer {
      background: #1e1e1e;
      text-align: center;
      padding: 1rem;
      margin-top: auto;
      color: #888;
    }
    /* Modal */
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
      padding: 2rem;
      border-radius: 8px;
      max-width: 400px;
      width: 90%;
      position: relative;
      box-shadow: 0 4px 12px rgba(0,0,0,0.5);
    }
    .modal-content label {
      margin-top: 1rem;
      display: block;
      font-weight: 500;
    }
    .modal-content input,
    .modal-content textarea {
      width: 100%;
      padding: .5rem;
      margin-top: .3rem;
      background: #2a2a2a;
      border: 1px solid #444;
      border-radius: 4px;
      color: #e0e0e0;
      font-size: 1rem;
    }
    .modal-content button {
      margin-top: 1.5rem;
      width: 100%;
      padding: .75rem;
      background: #008891;
      color: #fff;
      border: none;
      border-radius: 4px;
      font-weight: bold;
      cursor: pointer;
      font-size: 1rem;
    }
    .modal-content button:hover {
      background: #006f78;
    }
    .close {
      position: absolute;
      top: .5rem;
      right: .75rem;
      font-size: 1.2rem;
      cursor: pointer;
      color: #888;
    }
    .close:hover { color: #fff; }
  </style>
</head>
<body>

<header>
  <div class="header-container">
    <h1>Admin – Calendario</h1>
    <nav>
      <ul>
        <li><a href="admin_home.jsp">Panel</a></li>
      </ul>
    </nav>
  </div>
</header>

<main>
  <h2>Gestionar Eventos</h2>
  <div id="calendar"></div>
</main>

<!-- Modal Agregar/Editar Evento -->
<div id="eventModal" class="modal">
  <div class="modal-content">
    <span class="close">&times;</span>
    <h3 id="modal-title">Nuevo Evento</h3>
    <form id="eventForm" method="post">
      <input type="hidden" name="id" id="evt-id">
      
      <label for="evt-start">Fecha y hora inicio:</label>
      <input type="datetime-local" id="evt-start" name="start" required>

      <label for="evt-end">Fecha y hora fin (opcional):</label>
      <input type="datetime-local" id="evt-end" name="end">

      <label for="evt-title">Título:</label>
      <input type="text" id="evt-title" name="title" required>

      <label for="evt-desc">Descripción:</label>
      <textarea id="evt-desc" name="description" rows="3"></textarea>

      <button type="submit" id="evt-submit">Guardar Evento</button>
    </form>
  </div>
</div>

<footer>
  &copy; 2025 Red de Apoyo a Emprendedores Locales
</footer>

<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@fullcalendar/interaction@6.1.8/index.global.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@fullcalendar/daygrid@6.1.8/index.global.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
  const modal      = document.getElementById('eventModal');
  const closeBtn   = modal.querySelector('.close');
  const form       = document.getElementById('eventForm');
  const modalTitle = document.getElementById('modal-title');
  const submitBtn  = document.getElementById('evt-submit');

  const idInput    = document.getElementById('evt-id');
  const startInput = document.getElementById('evt-start');
  const endInput   = document.getElementById('evt-end');
  const titleInput = document.getElementById('evt-title');
  const descInput  = document.getElementById('evt-desc');

  closeBtn.onclick = () => modal.style.display = 'none';
  window.onclick    = e => { if (e.target === modal) modal.style.display = 'none'; };

  const calendar = new FullCalendar.Calendar(
    document.getElementById('calendar'),
    {
      initialView: 'dayGridMonth',
      headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: 'dayGridMonth,timeGridWeek,timeGridDay,listWeek'
      },
      selectable: true,
      select: info => {
        // Modo Nuevo
        modalTitle.textContent = 'Nuevo Evento';
        submitBtn.textContent = 'Guardar Evento';
        form.action = 'agregar_evento_action.jsp';

        idInput.value = '';
        // Prellena inicio: fecha seleccionada + hora actual
        const d = new Date(info.start);
        const pad = n => ('0' + n).slice(-2);
        const iso = d.getFullYear()
                  + '-' + pad(d.getMonth()+1)
                  + '-' + pad(d.getDate())
                  + 'T' + pad(d.getHours())
                  + ':' + pad(d.getMinutes());
        startInput.value = iso;

        endInput.value   = '';
        titleInput.value = '';
        descInput.value  = '';

        modal.style.display = 'flex';
      },
      eventClick: info => {
        const ev = info.event;
        // Modo Editar
        modalTitle.textContent = 'Editar Evento';
        submitBtn.textContent = 'Actualizar Evento';
        form.action = 'editar_evento_action.jsp';

        idInput.value    = ev.extendedProps.id;
        startInput.value = ev.startStr.substring(0,16);
        endInput.value   = ev.endStr ? ev.endStr.substring(0,16) : '';
        titleInput.value = ev.title;
        descInput.value  = ev.extendedProps.description || '';

        modal.style.display = 'flex';
      },
      events: function(fetchInfo, successCallback) {
        fetch('cargar_eventos.jsp')
          .then(r => r.json())
          .then(arr => {
            const formatted = arr.map(e => ({
              id: e.id,
              title: e.title,
              start: e.start,
              end: e.end || null,
              extendedProps: { description: e.description, id: e.id }
            }));
            successCallback(formatted);
          });
      }
    }
  );

  calendar.render();
});
</script>
</body>
</html>