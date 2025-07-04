<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    // ------------------------------------------------------
    // 1) Validar sesión de emprendedor
    // ------------------------------------------------------
    String rol = (String) session.getAttribute("rol");
    Integer userId = (Integer) session.getAttribute("userId");
    String nombreEmprendedor = "";
    String emailEmprendedor = "";
    String negocioEmprendedor = "";

    if (userId == null || !"emprendedor".equals(rol)) {
        response.sendRedirect("Login_emprendedor.jsp");
        return;
    }

    // ------------------------------------------------------
    // 2) Conexión y obtención de datos
    // ------------------------------------------------------
    String dbUrl = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser = "root";
    String dbPass = "";
    String especialidadFiltro = request.getParameter("especialidad");
    java.util.Set<String> especialidades = new java.util.HashSet<>();

    // Clase interna para almacenar mentores (se recomienda externalizar en un bean)
    class Mentor {
        int id;
        String nombre, email, especialidad, experiencia, tarifa, estado;
        String solicitudEstado; // vendrá de contacto_mentor.estado (puede ser null, "pendiente", "aceptado" o "rechazado")
    }
    java.util.List<Mentor> mentores = new java.util.ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass)) {

            // 2a) Obtener datos del emprendedor para el menú
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT nombre, email, negocio FROM emprendedores WHERE id = ?"
            )) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        nombreEmprendedor = rs.getString("nombre");
                        emailEmprendedor = rs.getString("email");
                        negocioEmprendedor = rs.getString("negocio");
                    }
                }
            }

            // 2b) Obtener todas las especialidades únicas
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT DISTINCT especialidad FROM mentores")) {
                while (rs.next()) {
                    String esp = rs.getString("especialidad");
                    if (esp != null && !esp.trim().isEmpty()) {
                        especialidades.add(esp);
                    }
                }
            }

            // 2c) Consultar mentores según filtro e incluir "solicitudEstado"
            //     Hacemos un LEFT JOIN con contacto_mentor filtrando por este emprendedor (userId)
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT ");
            sql.append("  m.id, m.nombre, m.email, m.especialidad, m.experiencia, m.tarifa, m.estado, ");
            sql.append("  cm.estado AS solicitud_estado ");
            sql.append("FROM mentores m ");
            sql.append("LEFT JOIN contacto_mentor cm ");
            sql.append("  ON cm.mentor_id = m.id AND cm.emprendedor_id = ? ");

            if (especialidadFiltro != null && !especialidadFiltro.isEmpty()) {
                sql.append("WHERE m.especialidad = ? ");
            }

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                // Siempre el primer parámetro es el userId para el JOIN
                ps.setInt(1, userId);
                if (especialidadFiltro != null && !especialidadFiltro.isEmpty()) {
                    ps.setString(2, especialidadFiltro);
                }

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Mentor m = new Mentor();
                        m.id                = rs.getInt("id");
                        m.nombre            = rs.getString("nombre");
                        m.email             = rs.getString("email");
                        m.especialidad      = rs.getString("especialidad");
                        m.experiencia       = rs.getString("experiencia");
                        m.tarifa            = rs.getString("tarifa");
                        String est          = rs.getString("estado");
                        m.estado            = (est != null && !est.trim().isEmpty()) ? est : "Libre";
                        m.solicitudEstado   = rs.getString("solicitud_estado"); 
                        // solicitud_estado vendrá null si nunca solicitó contacto, o "pendiente"/"aceptado"/"rechazado"
                        mentores.add(m);
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
    <title>Mentores Disponibles</title>
    <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
    <style>
        /* ===== RESET Y VARIABLES GLOBALES ===== */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            background: #121212;
            color: #e0e0e0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding-top: 80px;
            line-height: 1.6;
        }
        a {
            text-decoration: none;
        }

        /* ===== HEADER CON MENÚ LATERAL ===== */
        header {
            background: #1f1f1f;
            padding: 1rem 2rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 1000;
            box-shadow: 0 2px 15px rgba(0, 128, 128, 0.1);
            border-bottom: 1px solid rgba(0, 128, 128, 0.2);
        }
        header h1 {
            margin: 0;
            font-size: 1.8rem;
            color: #1abc9c;
            font-weight: 600;
            letter-spacing: 0.5px;
        }
        /* Botón hamburguesa */
        .menu-toggle {
            background: none;
            border: 1px solid rgba(26, 188, 156, 0.3);
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
            background: rgba(26, 188, 156, 0.1);
            border-color: #1abc9c;
        }

        /* Overlay para cerrar menú */
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

        /* Menú lateral */
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
            color: #1abc9c;
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
            background: rgba(26, 188, 156, 0.15);
            color: #1abc9c;
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
            color: #1abc9c;
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
        }
        .menu-item:hover,
        .menu-item.active {
            background: rgba(26, 188, 156, 0.1);
            border-left-color: #1abc9c;
            color: #1abc9c;
        }
        .menu-item-icon {
            font-size: 1.1rem;
            width: 20px;
            text-align: center;
        }
        .user-info {
            background: #2c2c2c;
            margin: 1rem;
            padding: 1.2rem;
            border-radius: 8px;
            border-left: 3px solid #1abc9c;
        }
        .user-info h4 {
            margin: 0 0 0.5rem;
            color: #1abc9c;
            font-size: 1.1rem;
            font-weight: 600;
        }
        .user-info p {
            margin: 0.3rem 0;
            color: #ccc;
            font-size: 0.9rem;
        }

        /* ===== CONTENIDO PRINCIPAL ===== */
        .container {
            max-width: 1100px;
            margin: 2rem auto;
            padding: 2rem;
            background: #1f1f1f;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 128, 128, 0.12);
            border: 1px solid rgba(0, 128, 128, 0.2);
        }
        h2 {
            text-align: center;
            color: #1abc9c;
            margin-bottom: 2.5rem;
            font-size: 2.2rem;
            font-weight: 600;
        }

        /* ===== FORMULARIO DE FILTRO ===== */
        .filtro-form {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 1.5rem;
            margin-bottom: 2.5rem;
            background: #2c2c2c;
            padding: 1.5rem 2rem;
            border-radius: 10px;
            border: 1px solid rgba(0, 128, 128, 0.2);
        }
        .filtro-form label {
            color: #1abc9c;
            font-weight: 600;
            font-size: 1rem;
            margin-right: 0.8rem;
        }
        .filtro-select {
            padding: 0.8rem 1.2rem;
            border-radius: 6px;
            border: 1px solid rgba(0, 128, 128, 0.3);
            background: #1a1a1a;
            color: #e0e0e0;
            font-size: 1rem;
            outline: none;
            transition: all 0.3s ease;
            min-width: 200px;
        }
        .filtro-select:focus {
            border-color: #1abc9c;
            box-shadow: 0 0 0 3px rgba(26, 188, 156, 0.15);
        }
        .filtro-btn {
            padding: 0.8rem 1.8rem;
            border-radius: 6px;
            border: none;
            background: #1abc9c;
            color: white;
            font-weight: 600;
            font-size: 1rem;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        .filtro-btn:hover {
            background: #16a085;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(26, 188, 156, 0.2);
        }

        /* ===== GRID DE TARJETAS DE MENTOR ===== */
        .mentores-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
        }
        .mentor-card {
            background: #2c2c2c;
            border-radius: 10px;
            padding: 1.8rem 1.5rem 2.5rem 1.5rem;
            box-shadow: 0 3px 15px rgba(0, 128, 128, 0.12);
            border: 1px solid rgba(0, 128, 128, 0.2);
            transition: all 0.3s ease;
            display: flex;
            flex-direction: column;
            position: relative;
        }
        .mentor-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 25px rgba(0, 128, 128, 0.2);
            border-color: rgba(0, 128, 128, 0.3);
        }
        .mentor-card h3 {
            margin: 0 0 1.2rem;
            color: #1abc9c;
            font-size: 1.5rem;
            font-weight: 600;
            text-align: center;
            padding-bottom: 0.6rem;
            border-bottom: 1px solid rgba(0, 128, 128, 0.1);
        }

        /* ===== CAMPOS DE INFORMACIÓN ===== */
        .field {
            margin-bottom: 1rem;
            display: flex;
            align-items: flex-start;
            gap: 0.8rem;
            padding: 0.3rem 0;
        }
        .mentor-card label {
            font-weight: 600;
            color: #1abc9c;
            min-width: 110px;
            font-size: 0.95rem;
        }
        .mentor-card .field span {
            color: #ccc;
            font-size: 0.95rem;
            line-height: 1.4;
        }
        .mentor-card .tarifa {
            color: #1abc9c;
            font-weight: 700;
            font-size: 1.2rem;
        }

        /* ===== ESTADO DE MENTOR DEBAJO DE TARIFA ===== */
        .estado-container {
            margin-top: 0.5rem;
            text-align: center;
        }
        .estado-badge {
            display: inline-block;
            padding: 6px 14px;
            border-radius: 12px;
            font-size: 0.85rem;
            font-weight: bold;
            color: #fff;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.3);
        }
        .estado-libre {
            background: linear-gradient(135deg, #27ae60, #2ecc71);
        }
        .estado-ocupado {
            background: linear-gradient(135deg, #c0392b, #e74c3c);
        }
        .estado-ocupado::after {
            content: " 🔴";
        }
        .estado-libre::after {
            content: " ✅";
        }

        /* ===== BOTONES Y MENSAJES DE SOLICITUD ===== */
        .btn-contactar {
            display: inline-block;
            margin-top: 1.8rem;
            background: #1abc9c;
            color: white;
            padding: 0.8rem 1.5rem;
            border-radius: 6px;
            font-weight: 600;
            font-size: 0.95rem;
            text-align: center;
            transition: all 0.3s ease;
            width: 100%;
        }
        .btn-contactar:hover {
            background: #16a085;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(26, 188, 156, 0.2);
        }
        .mensaje-pendiente {
            margin-top: 1.8rem;
            color: #f1c40f;
            font-weight: bold;
            text-align: center;
        }
        .mensaje-aceptado {
            margin-top: 1.8rem;
            color: #2ecc71;
            font-weight: bold;
            text-align: center;
        }
        .mensaje-rechazado {
            margin-top: 1.8rem;
            color: #e74c3c;
            font-weight: bold;
            text-align: center;
        }

        /* ===== MENSAJE SI NO HAY MENTORES ===== */
        .no-mentores {
            text-align: center;
            color: #777;
            font-size: 1.2rem;
            grid-column: 1 / -1;
            padding: 3rem;
            background: #2c2c2c;
            border-radius: 10px;
            border: 1px solid rgba(0, 128, 128, 0.2);
        }

        /* ===== RESPONSIVE ===== */
        @media (max-width: 768px) {
            .container {
                margin: 1rem;
                padding: 1.5rem;
            }
            .filtro-form {
                flex-direction: column;
                gap: 1rem;
                padding: 1.2rem;
            }
            .filtro-select {
                min-width: 100%;
            }
            h2 {
                font-size: 1.8rem;
            }
            .side-menu {
                width: 100%;
                right: -100%;
            }
            header h1 {
                font-size: 1.4rem;
            }
        }
        @media (max-width: 480px) {
            .mentores-grid {
                grid-template-columns: 1fr;
            }
            .mentor-card {
                padding: 1.2rem;
            }
            .container {
                padding: 1rem;
            }
        }
    </style>
</head>
<body>
<header>
    <h1>Mentores Disponibles</h1>
    <button class="menu-toggle" onclick="toggleMenu()">
        ☰ Menú
    </button>
</header>

<!-- Overlay para cerrar el menú -->
<div class="menu-overlay" onclick="closeMenu()"></div>

<!-- Menú lateral -->
<div class="side-menu" id="sideMenu">
    <div class="side-menu-header">
        <h3 class="side-menu-title">Navegación</h3>
        <button class="close-menu" onclick="closeMenu()">&times;</button>
    </div>

    <div class="side-menu-content">
        <!-- Información del usuario -->
        <div class="user-info">
            <h4>¡Hola, <%= nombreEmprendedor %>!</h4>
            <p><strong>Negocio:</strong> <%= negocioEmprendedor %></p>
            <p><strong>Email:</strong> <%= emailEmprendedor %></p>
        </div>

        <!-- Navegación principal -->
        <div class="menu-section">
            <div class="menu-section-title">Navegación</div>
            <a href="emprendedor_home.jsp" class="menu-item">
                <span class="menu-item-icon">🏠</span> Panel Principal
            </a>
            <a href="mentores.jsp" class="menu-item active">
                <span class="menu-item-icon">👨‍🏫</span> Ver Mentores
            </a>
            <a href="capacitaciones.jsp" class="menu-item">
                <span class="menu-item-icon">📚</span> Capacitaciones
            </a>
            <a href="agregar_publicacion.jsp" class="menu-item">
                <span class="menu-item-icon">➕</span> Nueva Publicación
            </a>
            <a href="editar_perfil_emprendedor.jsp" class="menu-item">
                <span class="menu-item-icon">👤</span> Editar Perfil
            </a>
        </div>

        <!-- Acciones -->
        <div class="menu-section">
            <div class="menu-section-title">Cuenta</div>
            <a href="Logout.jsp" class="menu-item">
                <span class="menu-item-icon">🚪</span> Cerrar Sesión
            </a>
        </div>
    </div>
</div>

<div class="container">
    <h2>Encuentra tu Mentor Ideal</h2>

    <!-- Formulario de filtro -->
    <form class="filtro-form" method="get" action="mentores.jsp">
        <label for="especialidad">Filtrar por especialidad:</label>
        <select name="especialidad" id="especialidad" class="filtro-select">
            <option value="">-- Todas las especialidades --</option>
            <% for (String esp : especialidades) { %>
                <option value="<%= esp %>" <%= esp.equals(especialidadFiltro) ? "selected" : "" %>>
                    <%= esp %>
                </option>
            <% } %>
        </select>
        <button type="submit" class="filtro-btn">Filtrar</button>
    </form>

    <!-- Grid de mentores -->
    <div class="mentores-grid">
        <% if (mentores.isEmpty()) { %>
            <div class="no-mentores">
                <div style="font-size: 3rem; margin-bottom: 1rem; color: #1abc9c;">🔍</div>
                No hay mentores registrados<% if (especialidadFiltro != null && !especialidadFiltro.isEmpty()) { %>
                    para esta especialidad
                <% } %>.
            </div>
        <% } else {
            for (Mentor m : mentores) {
                // Determinar clase CSS según estado (solo Libre vs Ocupado para este ejemplo)
                String claseEstado = m.estado.equalsIgnoreCase("Libre") ? "estado-libre" : "estado-ocupado";
        %>
            <div class="mentor-card">
                <h3><%= m.nombre %></h3>

                <div class="field">
                    <label>Email:</label>
                    <span><%= m.email %></span>
                </div>
                <div class="field">
                    <label>Especialidad:</label>
                    <span><%= m.especialidad %></span>
                </div>
                <div class="field">
                    <label>Experiencia:</label>
                    <span><%= m.experiencia %></span>
                </div>
                <div class="field">
                    <label>Tarifa:</label>
                    <span class="tarifa">$<%= m.tarifa %></span>
                </div>

                <!-- Estado debajo de la tarifa -->
                <div class="estado-container">
                    <span class="estado-badge <%= claseEstado %>">
                        <%= m.estado %>
                    </span>
                </div>

                <% 
                   // --------------------------------------------
                   //   3) Decide qué mostrar según "solicitudEstado"
                   // --------------------------------------------
                   String sol = m.solicitudEstado; // puede ser null, "pendiente", "aceptado" o "rechazado"
                   if (sol == null) {
                       // No existe ninguna solicitud previa: mostrar botón "Contactar Mentor"
                %>
                    <a href="contactar_mentor.jsp?mentor_id=<%= m.id %>" class="btn-contactar">
                        Contactar Mentor
                    </a>
                <% 
                   } else if ("pendiente".equalsIgnoreCase(sol)) {
                       // Ya existe solicitud enviada y está pendiente
                %>
                    <div class="mensaje-pendiente">
                        Solicitud enviada
                    </div>
                <% 
                   } else if ("aceptado".equalsIgnoreCase(sol)) {
                       // Mentor ya aceptó la solicitud
                %>
                    <div class="mensaje-aceptado">
                        Petición Aceptada, el mentor se contactará pronto
                    </div>
                <% 
                   } else if ("rechazado".equalsIgnoreCase(sol)) {
                       // Mentor rechazó la solicitud
                %>
                    <div class="mensaje-rechazado">
                        El mentor ha rechazado su petición
                    </div>
                <% 
                   }
                %>

            </div>
        <%  }
        } %>
    </div>
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
    // Cerrar menú con tecla Escape
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeMenu();
        }
    });
    // Cerrar menú al hacer clic en un enlace
    document.querySelectorAll('.menu-item').forEach(item => {
        item.addEventListener('click', function() {
            closeMenu();
        });
    });
</script>
</body>
</html>
