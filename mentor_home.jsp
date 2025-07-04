<!--mentor_home.jsp-->
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    // ——— 1) Validar sesión de mentor ———
    Integer mentorId = (Integer) session.getAttribute("userId");
    String rol       = (String)  session.getAttribute("rol");
    if (mentorId == null || !"mentor".equals(rol)) {
        response.sendRedirect("Login_mentor.jsp");
        return;
    }

    // ——— 2) Parámetros de conexión ———
    String dbUrl  = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser = "root";
    String dbPass = "";

    // ——— 3) Modelo interno para cada emprendedor "pendiente" ———
    class Emprendedor {
        int id;
        String nombre, email, telefono, negocio, descripcion;
        int totalPublicaciones;
    }
    java.util.List<Emprendedor> lista = new java.util.ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass)) {
            /*
             * Seleccionamos únicamente los emprendedores que:
             *  - hayan contactado a este mentor (JOIN con contacto_mentor)
             *  - cuyo estado en contacto_mentor sea 'pendiente'
             *  - ordenamos por fecha de contacto más reciente
             */
            String sql =
                "SELECT " +
                "  e.id, " +
                "  e.nombre, e.email, e.telefono, e.negocio, e.descripcion, " +
                "  (SELECT COUNT(*) FROM publicaciones p WHERE p.emprendedor_id = e.id) AS total_publicaciones " +
                "FROM emprendedores e " +
                "JOIN contacto_mentor cm ON e.id = cm.emprendedor_id " +
                "WHERE cm.mentor_id = ? AND cm.estado = 'pendiente' " +
                "GROUP BY e.id, e.nombre, e.email, e.telefono, e.negocio, e.descripcion " +
                "ORDER BY MAX(cm.fecha) DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, mentorId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Emprendedor em = new Emprendedor();
                        em.id = rs.getInt("id");
                        em.nombre = rs.getString("nombre");
                        em.email = rs.getString("email");
                        em.telefono = rs.getString("telefono");
                        em.negocio = rs.getString("negocio");
                        em.descripcion = rs.getString("descripcion");
                        em.totalPublicaciones = rs.getInt("total_publicaciones");
                        lista.add(em);
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
  <title>Panel de Mentor – Solicitudes Pendientes</title>
  <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
  <style>
    /* ===== Reset & tema general ===== */
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    body {
      background: #121212;
      color: #e0e0e0;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      min-height: 100vh;
      overflow-x: hidden;
    }

    /* ===== HEADER con navegación estilo perfil_mentor.jsp ===== */
    .header {
      background: rgba(30, 30, 30, 0.95);
      backdrop-filter: blur(10px);
      padding: 1rem 2rem;
      display: flex;
      justify-content: space-between;
      align-items: center;
      box-shadow: 0 4px 20px rgba(0,0,0,0.3);
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      z-index: 1000;
    }
    .header h1 {
      color: #00a5a5;
      font-size: 1.8rem;
      font-weight: 600;
    }
    .nav-btn {
      background: #008891;
      color: white;
      padding: 0.6rem 1.2rem;
      border: none;
      border-radius: 8px;
      text-decoration: none;
      cursor: pointer;
      transition: all 0.3s;
      font-size: 0.9rem;
      margin-left: 0.5rem;
    }
    .nav-btn:hover {
      background: #00a5a5;
      transform: translateY(-2px);
    }
    .nav-btn.danger {
      background: #e74c3c;
    }
    .nav-btn.danger:hover {
      background: #c0392b;
    }

    /* espacio para compensar header fijo */
    .spacer {
      height: 72px;
    }

    /* ===== menú hamburguesa ===== */
    .menu-toggle {
      background: none;
      border: 1px solid rgba(30, 168, 165, 0.3);
      color: #e0e0e0;
      font-size: 1rem;
      cursor: pointer;
      padding: 0.7rem 1.2rem;
      border-radius: 6px;
      transition: all 0.3s ease;
      display: flex;
      align-items: center;
      gap: 0.5rem;
      font-weight: 500;
    }
    .menu-toggle:hover {
      background: rgba(30, 168, 165, 0.1);
      border-color: #00a5a5;
    }

    /* Overlay para menú lateral */
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

    /* ===== Menú lateral ===== */
    .side-menu {
      position: fixed;
      top: 0;
      right: -350px;
      width: 350px;
      height: 100vh;
      background: #1f1f1f;
      box-shadow: -3px 0 20px rgba(0, 128, 128, 0.15);
      transition: right 0.4s cubic-bezier(0.4, 0, 0.2, 1);
      z-index: 1001;
      display: flex;
      flex-direction: column;
      border-left: 1px solid rgba(0, 128, 128, 0.2);
    }
    .side-menu.active {
      right: 0;
    }
    .side-menu-header {
      padding: 1.5rem;
      background: #121212;
      border-bottom: 1px solid rgba(0, 128, 128, 0.2);
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .side-menu-title {
      font-size: 1.3rem;
      font-weight: 600;
      color: #00a5a5;
      margin: 0;
    }
    .close-menu {
      background: none;
      border: none;
      color: #ccc;
      font-size: 1.5rem;
      cursor: pointer;
      padding: 0.5rem;
      border-radius: 50%;
      width: 36px;
      height: 36px;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: all 0.3s ease;
    }
    .close-menu:hover {
      background: rgba(30, 168, 165, 0.15);
      color: #00a5a5;
    }
    .side-menu-content {
      flex: 1;
      padding: 1rem 0;
      overflow-y: auto;
    }
    .menu-section {
      margin-bottom: 2rem;
    }
    .menu-section-title {
      color: #00a5a5;
      font-size: 0.85rem;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin: 0 1.5rem 1rem;
      padding-bottom: 0.5rem;
      border-bottom: 1px solid #444;
    }
    .menu-item {
      display: flex;
      align-items: center;
      gap: 1rem;
      color: #ccc;
      padding: 1rem 1.5rem;
      transition: all 0.3s ease;
      border-left: 3px solid transparent;
      font-weight: 500;
      text-decoration: none;
      position: relative;
    }
    .menu-item:hover,
    .menu-item.active {
      background: rgba(30, 168, 165, 0.1);
      border-left-color: #00a5a5;
      color: #00a5a5;
    }
    .menu-item-icon {
      font-size: 1.1rem;
      width: 20px;
      text-align: center;
    }

   /* ===== EFECTO ROJO RESALTADO
    .menu-item.red-highlight {
      background: rgba(231, 76, 60, 0.15);
      border-left-color: #e74c3c;
      color: #ff6b6b;
      position: relative;
    }
    .menu-item.red-highlight::before {
      content: '';
      position: absolute;
      left: 0;
      top: 0;
      bottom: 0;
      width: 4px;
      background: linear-gradient(to bottom, #e74c3c, #ff4757);
      box-shadow: 0 0 10px rgba(231, 76, 60, 0.6), 0 0 20px rgba(231, 76, 60, 0.4);
      animation: redGlow 2s ease-in-out infinite alternate;
    }
    .menu-item.red-highlight:hover {
      background: rgba(231, 76, 60, 0.25);
      color: #ff4757;
      box-shadow: inset 0 0 20px rgba(231, 76, 60, 0.1);
    }
    .menu-item.red-highlight .menu-item-icon {
      color: #e74c3c;
      text-shadow: 0 0 10px rgba(231, 76, 60, 0.5);
    } ===== */

    /* Animación de brillo rojo */
    @keyframes redGlow {
      0% {
        box-shadow: 0 0 5px rgba(231, 76, 60, 0.4), 0 0 10px rgba(231, 76, 60, 0.2);
      }
      100% {
        box-shadow: 0 0 15px rgba(231, 76, 60, 0.8), 0 0 25px rgba(231, 76, 60, 0.4);
      }
    }

    @media (max-width: 768px) {
      .side-menu {
        width: 100%;
        right: -100%;
      }
    }

    /* ===== Contenido de solicitudes pendientes ===== */
    .grid-container {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
      gap: 20px;
      padding: 1rem;
      margin-top: 1rem;
    }
    .emprendedor-card {
      background: #1e1e1e;
      border-radius: 8px;
      padding: 20px;
      position: relative;
      transition: transform 0.2s;
    }
    .emprendedor-card:hover {
      transform: translateY(-5px);
      box-shadow: 0 5px 15px rgba(0,0,0,0.3);
    }
    .info-section {
      background: #252525;
      border-radius: 4px;
      padding: 10px;
      margin: 15px 0;
    }
    .info-section p {
      margin: 8px 0;
      font-size: 0.95rem;
    }
    .descripcion {
      font-style: italic;
      color: #aaa;
      margin: 15px 0;
    }
    .card-actions {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      justify-content: flex-start;
    }
    .btn {
      background: #00a5a5;
      color: #fff;
      padding: 8px 15px;
      text-decoration: none;
      border-radius: 4px;
      font-size: 0.9rem;
      transition: background 0.3s;
      display: inline-block;
      text-align: center;
      cursor: pointer;
      border: none;
    }
    .btn:hover {
      background: #008080;
    }
    .btn-rechazar {
      background: #e74c3c;
    }
    .btn-rechazar:hover {
      background: #c0392b;
    }
  </style>
</head>
<body>
  <!-- ===== HEADER FIJO ===== -->
  <div class="header">
    <h1>Solicitudes Pendientes</h1>
    <button class="menu-toggle" onclick="toggleMenu()">☰ Menú</button>
  </div>
  <div class="spacer"></div>

  <!-- ===== Overlay para cerrar el menú ===== -->
  <div class="menu-overlay" onclick="closeMenu()"></div>

  <!-- ===== Menú lateral (igual al de perfil_mentor.jsp) ===== -->
  <div class="side-menu" id="sideMenu">
    <div class="side-menu-header">
      <h3 class="side-menu-title">Navegación</h3>
      <button class="close-menu" onclick="closeMenu()">&times;</button>
    </div>
    <div class="side-menu-content">
      <!-- Como no cargamos nombre/email/especialidad aquí, dejamos solo el saludo genérico -->
      <div class="menu-section">
        <div class="menu-section-title">Navegación</div>
        <a href="mentor_home.jsp" class="menu-item">
          <span class="menu-item-icon">🏠</span> Panel Principal
        </a>
        <a href="perfil_mentor.jsp" class="menu-item">
          <span class="menu-item-icon">💬</span> Mi perfil
        </a>
         <a href="mis_mentoreados.jsp" class="menu-item">
          <span class="menu-item-icon">👥</span> Mis Mentoreados
        </a>
        <a href="ayuda.jsp" class="menu-item red-highlight">
          <span class="menu-item-icon">❓</span> Ayuda
        </a>
      </div>
      <div class="menu-section">
        <div class="menu-section-title">Cuenta</div>
        <a href="Logout.jsp" class="menu-item red-highlight" style="border-top: 2px solid #333; margin-top: auto;">
          <span class="menu-item-icon">🚪</span> Cerrar Sesión
        </a>
      </div>
    </div>
  </div>

  <!-- ===== Contenedor de Solicitudes Pendientes ===== -->
  <div class="grid-container">
    <% if (lista.isEmpty()) { %>
      <p style="grid-column:1/-1; text-align:center; color:#888;">
        No hay solicitudes pendientes en este momento.
      </p>
    <% } else {
         for (Emprendedor em : lista) { %>
      <div class="emprendedor-card">
        <h3><%= em.nombre %></h3>
        <div class="info-section">
          <p><strong>Negocio:</strong> <%= em.negocio != null ? em.negocio : "No especificado" %></p>
          <p><strong>Email:</strong> <%= em.email %></p>
          <p><strong>Teléfono:</strong> <%= em.telefono != null ? em.telefono : "No especificado" %></p>
          <p><strong>Publicaciones:</strong> <%= em.totalPublicaciones %></p>
        </div>
        <p class="descripcion"><%= em.descripcion != null ? em.descripcion : "Sin descripción" %></p>
        <div class="card-actions">
          <!-- 1) Botón ACEPTAR -->
          <form action="procesar_solicitud.jsp" method="post" style="display:inline;">
            <input type="hidden" name="emprendedor_id" value="<%= em.id %>">
            <input type="hidden" name="accion" value="aceptar">
            <button type="submit" class="btn">Aceptar</button>
          </form>

          <!-- 2) Botón RECHAZAR -->
          <form action="procesar_solicitud.jsp" method="post" style="display:inline;">
            <input type="hidden" name="emprendedor_id" value="<%= em.id %>">
            <input type="hidden" name="accion" value="rechazar">
            <button type="submit" class="btn btn-rechazar">Rechazar</button>
          </form>

          <!-- 3) Botón VER PUBLICACIONES -->
          <a href="ver_publicaciones_emprendedor.jsp?emprendedor_id=<%= em.id %>" class="btn">
            Ver Publicaciones
          </a>
        </div>
      </div>
    <%   }
       } %>
  </div>

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
    document.addEventListener('keydown', function(e) {
      if (e.key === 'Escape') {
        closeMenu();
      }
    });
    document.querySelectorAll('.menu-item').forEach(item => {
      item.addEventListener('click', function() {
        closeMenu();
      });
    });
  </script>
</body>
</html>