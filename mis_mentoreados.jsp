<!--mis_mentoreados.jsp-->
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

    // ——— 2) Conexión a la base de datos ———
    String dbUrl  = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser = "root";
    String dbPass = "";

    // ——— 3) Clase interna para almacenar datos de cada mentoreado "aceptado" ———
    class Menteado {
        int    id;
        String nombre;
        String email;
        String telefono;
        String negocio;
        String descripcion;
        int    totalPublicaciones;
    }
    java.util.List<Menteado> listaMenteados = new java.util.ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass)) {
            /*
             * Seleccionamos únicamente los emprendedores que este mentor
             * haya ACEPTADO (estado = 'aceptado') en contacto_mentor.
             */
            String sql = 
              "SELECT DISTINCT e.id, e.nombre, e.email, e.telefono, e.negocio, e.descripcion, " +
              "  (SELECT COUNT(*) FROM publicaciones p WHERE p.emprendedor_id = e.id) AS total_publicaciones " +
              "FROM contacto_mentor cm " +
              "JOIN emprendedores e ON cm.emprendedor_id = e.id " +
              "WHERE cm.mentor_id = ? AND cm.estado = 'aceptado' " +
              "ORDER BY e.nombre ASC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, mentorId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Menteado m = new Menteado();
                        m.id = rs.getInt("id");
                        m.nombre = rs.getString("nombre");
                        m.email = rs.getString("email");
                        m.telefono = rs.getString("telefono");
                        m.negocio = rs.getString("negocio");
                        m.descripcion = rs.getString("descripcion");
                        m.totalPublicaciones = rs.getInt("total_publicaciones");
                        listaMenteados.add(m);
                    }
                }
            }
        }
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error al cargar mentoreados: " + e.getMessage() + "</p>");
        e.printStackTrace(new java.io.PrintWriter(out));
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Mis Mentoreados</title>
  <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background: #121212;
      color: #e0e0e0;
      font-family: 'Segoe UI', Tahoma, Verdana, sans-serif;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
    }
    header {
      background: #1e1e1e;
      padding: 1rem 2rem;
      box-shadow: 0 2px 10px rgba(0,0,0,0.5);
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
    header h1 {
      font-size: 1.8rem;
    }
    header .nav-actions a {
      background: #008891;
      color: #fff;
      padding: 0.5rem 1rem;
      margin-left: 0.5rem;
      border-radius: 6px;
      text-decoration: none;
      font-size: 0.9rem;
      transition: background 0.3s;
    }
    header .nav-actions a:hover {
      background: #00a5a5;
    }
    main {
      flex: 1;
      padding: 2rem 1.5rem;
      max-width: 1200px;
      margin: 0 auto;
    }
    h2 {
      text-align: center;
      margin-bottom: 1.5rem;
      font-size: 1.6rem;
      color: #00a5a5;
    }
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 1.5rem;
    }
    .card {
      background: #1f1f1f;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.5);
      overflow: hidden;
      transition: transform 0.3s, box-shadow 0.3s;
      display: flex;
      flex-direction: column;
      height: 100%;
    }
    .card:hover {
      transform: translateY(-5px);
      box-shadow: 0 8px 16px rgba(0,0,0,0.7);
    }
    .card .info {
      padding: 1rem;
      flex: 1;
      display: flex;
      flex-direction: column;
    }
    .card h3 {
      margin-bottom: 0.5rem;
      font-size: 1.25rem;
      color: #00c1c1;
    }
    .field {
      font-size: 0.9rem;
      margin-bottom: 0.5rem;
      line-height: 1.4;
    }
    .field strong {
      color: #00a5a5;
    }
    .btn-view-publicaciones,
    .btn-whatsapp {
      margin-top: auto;
      background: #00a5a5;
      color: #fff;
      padding: 0.6rem;
      text-align: center;
      border: none;
      border-radius: 6px;
      cursor: pointer;
      text-decoration: none;
      font-size: 0.9rem;
      transition: background 0.3s;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 6px;
    }
    .btn-view-publicaciones:hover {
      background: #008080;
    }
    .btn-whatsapp {
      background: #25d366;
      margin-top: 0.5rem;
    }
    .btn-whatsapp:hover {
      background: #1ebe4f;
    }
    .empty-state {
      grid-column: 1 / -1;
      text-align: center;
      padding: 2rem;
      background: #1f1f1f;
      border-radius: 8px;
      color: #aaa;
      font-size: 1.1rem;
    }
    footer {
      background: #1e1e1e;
      color: #777;
      text-align: center;
      padding: 1rem;
      margin-top: auto;
    }
    @media (max-width: 768px) {
      .grid {
        grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
      }
    }
    
/* ===== Hamburger menu button - Más profesional ===== */
.menu-btn {
  background: linear-gradient(135deg, #008891, #00a5a5);
  border: none;
  color: #ffffff;
  font-size: 1.2rem;
  cursor: pointer;
  padding: 0.8rem;
  border-radius: 10px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  width: 45px;
  height: 45px;
  box-shadow: 0 4px 12px rgba(0, 136, 145, 0.3);
  position: relative;
  overflow: hidden;
}

.menu-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
  transition: left 0.5s;
}

.menu-btn:hover::before {
  left: 100%;
}

.menu-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 165, 165, 0.4);
  background: linear-gradient(135deg, #00a5a5, #00c1c1);
}

.menu-btn span {
  display: block;
  width: 22px;
  height: 2.5px;
  background: #ffffff;
  margin: 2.5px 0;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  border-radius: 2px;
}

.menu-btn.active {
  background: linear-gradient(135deg,rgb(38, 53, 220), #ef4444);
  box-shadow: 0 4px 12px rgba(15, 255, 111, 0.3);
}

.menu-btn.active span:nth-child(1) {
  transform: rotate(45deg) translate(5px, 5px);
}
.menu-btn.active span:nth-child(2) {
  opacity: 0;
  transform: scale(0);
}
.menu-btn.active span:nth-child(3) {
  transform: rotate(-45deg) translate(7px, -6px);
}

/* ===== Overlay mejorado ===== */
.menu-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(3px);
  opacity: 0;
  visibility: hidden;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  z-index: 150;
}
.menu-overlay.active {
  opacity: 1;
  visibility: visible;
}

/* ===== Side menu profesional ===== */
.side-menu {
  position: fixed;
  top: 0;
  right: -380px;
  width: 380px;
  height: 100vh;
  background: linear-gradient(180deg, #1a1a1a 0%, #1e1e1e 50%, #121212 100%);
  box-shadow: -8px 0 32px rgba(0, 0, 0, 0.8);
  transition: right 0.5s cubic-bezier(0.4, 0, 0.2, 1);
  z-index: 200;
  display: flex;
  flex-direction: column;
  border-left: 1px solid rgba(0, 165, 165, 0.2);
  backdrop-filter: blur(10px);
}

.side-menu.active {
  right: 0;
}

.side-menu-header {
  padding: 2rem 1.5rem 1.5rem;
  background: linear-gradient(135deg, #008891, #00a5a5);
  border-bottom: 1px solid rgba(0, 165, 165, 0.3);
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: relative;
  overflow: hidden;
}

.side-menu-header::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 20"><defs><radialGradient id="a" cx="50%" cy="0%" r="100%"><stop offset="0%" stop-color="rgba(255,255,255,0.1)"/><stop offset="100%" stop-color="rgba(255,255,255,0)"/></radialGradient></defs><rect width="100" height="20" fill="url(%23a)"/></svg>');
  opacity: 0.1;
}

.side-menu-title {
  font-size: 1.4rem;
  font-weight: 700;
  color: #ffffff;
  margin: 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
  position: relative;
  z-index: 1;
}

.close-menu {
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #ffffff;
  font-size: 1.3rem;
  cursor: pointer;
  padding: 0.6rem;
  border-radius: 8px;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  z-index: 1;
}

.close-menu:hover {
  background: rgba(220, 38, 38, 0.2);
  border-color: rgba(220, 38, 38, 0.4);
  transform: rotate(90deg);
  box-shadow: 0 4px 12px rgba(220, 38, 38, 0.3);
}

.side-menu-content {
  flex: 1;
  padding: 1.5rem 0;
  overflow-y: auto;
  scrollbar-width: thin;
  scrollbar-color: rgba(59, 130, 246, 0.5) transparent;
}

.side-menu-content::-webkit-scrollbar {
  width: 6px;
}

.side-menu-content::-webkit-scrollbar-track {
  background: transparent;
}

.side-menu-content::-webkit-scrollbar-thumb {
  background: rgba(0, 165, 165, 0.5);
  border-radius: 3px;
}

.user-info {
  padding: 0 1.5rem 1.5rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  margin-bottom: 1rem;
}

.user-info h4 {
  color: #ffffff;
  font-size: 1.1rem;
  font-weight: 600;
  margin: 0;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  border-left: 4px solid #00a5a5;
}

.menu-section {
  margin-bottom: 1.5rem;
}

.menu-section-title {
  color: #00a5a5;
  font-size: 0.8rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin: 0 1.5rem 1rem;
  padding: 0.5rem 0;
  border-bottom: 2px solid rgba(0, 165, 165, 0.2);
  position: relative;
}

.menu-section-title::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  width: 30px;
  height: 2px;
  background: linear-gradient(90deg, #008891, #00a5a5);
  border-radius: 1px;
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  color: #e2e8f0;
  padding: 1rem 1.5rem;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  border-left: 4px solid transparent;
  font-weight: 500;
  text-decoration: none;
  position: relative;
  overflow: hidden;
}

.menu-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(5, 255, 255, 0.1), transparent);
  transition: left 0.5s cubic-bezier(0.4, 0, 0.2, 1);
}

.menu-item:hover::before {
  left: 100%;
}

.menu-item:hover,
.menu-item.active {
  background: linear-gradient(90deg, rgba(0, 165, 165, 0.15), rgba(0, 165, 165, 0.05));
  border-left-color: #00a5a5;
  color: #ffffff;
  transform: translateX(8px);
  box-shadow: inset 0 0 20px rgba(0, 165, 165, 0.1);
}

.menu-item-icon {
  font-size: 1.2rem;
  width: 24px;
  text-align: center;
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.menu-item:hover .menu-item-icon {
  transform: scale(1.2);
}


.menu-item:last-child:hover {
  background: linear-gradient(90deg, transparent, rgba(5, 255, 255, 0.1), transparent);
  border-left-color:rgba(0, 165, 165, 0.15);
  color: #ffffff;
}

.menu-item, .menu-item-icon {
  color: #ccc !important;
}
.menu-item:hover, .menu-item.active {
  color: #00a5a5 !important;
}

@media (max-width: 768px) {
  .side-menu {
    width: 100%;
    right: -100%;
  }
  
  .menu-btn {
    width: 40px;
    height: 40px;
  }
}

 .menu-toggle {
            background: none;
            border: 1px solid rgba(0, 128, 128, 0.3);
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
            background: rgba(0, 128, 128, 0.1);
            border-color: #008080;
        }
  </style>
</head>
<body>
  <header>
    <h1>Mis Mentoreados</h1>
            <button class="menu-toggle" onclick="toggleMenu()">☰ Menú</button>

  </header>
  <div class="menu-overlay" onclick="closeMenu()"></div>
  <div class="side-menu" id="sideMenu">
    <div class="side-menu-header">
      <h3 class="side-menu-title">Navegación</h3>
      <button class="close-menu" onclick="closeMenu()">&times;</button>
    </div>
    <div class="side-menu-content">
      <div class="user-info">
        <h4>¡Hola, Mentor!</h4>
        <!-- Puedes agregar más datos del mentor aquí si lo deseas -->
      </div>
      <div class="menu-section">
        <div class="menu-section-title">Navegación</div>
        <a href="mentor_home.jsp" class="menu-item"><span class="menu-item-icon">🏠</span> Panel Principal</a>
                <a href="perfil_mentor.jsp" class="menu-item"><span class="menu-item-icon">💬</span> Mi Perfil</a>
        <a href="mis_mentoreados.jsp" class="menu-item"><span class="menu-item-icon">👥</span> Mis Mentoreados</a>
        <a href="ayuda.jsp" class="menu-item"><span class="menu-item-icon">❓</span> Ayuda</a>
      </div>
      <div class="menu-section">
        <div class="menu-section-title">Cuenta</div>
        <a href="Logout.jsp" class="menu-item" style="border-top: 2px solid #333; margin-top: auto;"><span class="menu-item-icon">🚪</span> Cerrar Sesión</a>
      </div>
    </div>
  </div>

  <main>
    <h2>Emprendedores Aceptados</h2>
    <div class="grid">
      <% if (listaMenteados.isEmpty()) { %>
        <div class="empty-state">
          Aún no has aceptado a ningún emprendedor.
        </div>
      <% } else {
           for (Menteado m : listaMenteados) { %>
        <div class="card">
          <div class="info">
            <h3><%= m.nombre %></h3>
            <div class="field">
              <strong>Negocio:</strong> <%= m.negocio != null ? m.negocio : "No especificado" %>
            </div>
            <div class="field">
              <strong>Email:</strong> <%= m.email %>
            </div>
            <div class="field">
              <strong>Teléfono:</strong> <%= m.telefono != null ? m.telefono : "No especificado" %>
            </div>
            <div class="field">
              <strong>Publicaciones:</strong> <%= m.totalPublicaciones %>
            </div>
            <div class="field" style="font-style: italic; color: #ccc; flex-grow:1;">
              <%= m.descripcion != null && !m.descripcion.trim().isEmpty() 
                    ? m.descripcion 
                    : "Sin descripción disponible" %>
            </div>
            <!-- 1) Botón "Ver Publicaciones" -->
            <a href="ver_publicaciones_emprendedor.jsp?emprendedor_id=<%= m.id %>" 
               class="btn-view-publicaciones">
              📄 Ver Publicaciones
            </a>
            <!-- 2) Botón "Chatear WhatsApp" -->
            <a onclick="abrirWhatsapp('<%= m.telefono != null ? m.telefono : "" %>')" 
               class="btn-whatsapp">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor"
                   viewBox="0 0 16 16">
                <path d="M13.601 2.326A7.854 7.854 0 0 0 7.994 0C3.627 0 .068 3.558.064 7.926c0 1.399.366 2.76 1.057
                         3.965L0 16l4.204-1.102a7.933 7.933 0 0 0 3.79.965h.004c4.368 0 7.926-3.558 7.93-7.93
                         A7.898 7.898 0 0 0 13.6 2.326zM7.994 14.521a6.573 6.573 0 0 1-3.356-.92l-.24-.144-2.494.654
                         .666-2.433-.156-.251a6.56 6.56 0 0 1-1.007-3.505c0-3.626 2.957-6.584 6.591-6.584a6.56
                         6.56 0 0 1 4.66 1.931 6.557 6.557 0 0 1 1.928 4.66c-.004 3.639-2.961 6.592-6.592
                         6.592zm3.615-4.934c-.197-.099-1.17-.578-1.353-.646-.182-.065-.315-.099-.445.099-.133.197
                         -.513.646-.627.775-.114.133-.232.148-.43.05-.197-.1-.836-.308-1.592-.985-.59-.525
                         -.985-1.175-1.103-1.372-.114-.198-.011-.304.088-.403.087-.088.197-.232.296-.346.1
                         -.114.133-.198.198-.33.065-.134.034-.248-.015-.347-.05-.099-.445-1.076-.612-1.47
                         -.16-.389-.323-.335-.445-.34-.114-.007-.247-.007-.38-.007a.729.729 0 0 0-.529.247c
                         -.182.198-.691.677-.691 1.654 0 .977.71 1.916.81 2.049.098.133 1.394 2.132 3.383
                         2.992.47.205.84.326 1.129.418.475.152.904.129 1.246.08.38-.058 1.171-.48 1.338
                         -.943.164-.464.164-.86.114-.943-.049-.084-.182-.133-.38-.232z"/>
              </svg>
              📲 WhatsApp
            </a>
          </div>
        </div>
      <%   }
         } %>
    </div>
  </main>

  <footer>
    &copy; 2025 Red de Apoyo a Emprendedores Locales
  </footer>

  <script>
    function abrirWhatsapp(telefono) {
      if (telefono && telefono.length > 5) {
        var tel = telefono.replace(/[^\d]/g, '');
        window.open('https://wa.me/' + tel, '_blank');
      } else {
        alert('El emprendedor no tiene un número de teléfono válido registrado.');
      }
    }
  </script>
</body>
</html>

<script>
function toggleMenu() {
  const menu = document.getElementById('sideMenu');
  const overlay = document.querySelector('.menu-overlay');
  const menuBtn = document.querySelector('.menu-btn');
  
  menu.classList.toggle('active');
  overlay.classList.toggle('active');
  menuBtn.classList.toggle('active');
}

function closeMenu() {
  const menu = document.getElementById('sideMenu');
  const overlay = document.querySelector('.menu-overlay');
  const menuBtn = document.querySelector('.menu-btn');
  
  menu.classList.remove('active');
  overlay.classList.remove('active');
  menuBtn.classList.remove('active');
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