<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    // ------------------------------------------------------
    // 1) Verificar que exista sesión activa y sea un mentor
    // ------------------------------------------------------
    Integer mentorId = (Integer) session.getAttribute("userId");
    String rol       = (String) session.getAttribute("rol");
    if (mentorId == null || !"mentor".equals(rol)) {
        response.sendRedirect("Login_mentor.jsp");
        return;
    }

    // ------------------------------------------------------
    // 2) Variables para almacenar datos del mentor
    // ------------------------------------------------------
    String dbUrl           = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser          = "root";
    String dbPass          = "";
    String nombre          = "";
    String email           = "";
    String especialidad    = "";
    String experiencia     = "";
    String tarifa          = "";
    String estado          = "en_linea";  // <-- Nuevo campo
    int totalMentoreados   = 0;
    int totalConsultas     = 0;

    // ------------------------------------------------------
    // 3) Recursos JDBC
    // ------------------------------------------------------
    Connection conn       = null;
    PreparedStatement ps1 = null;
    PreparedStatement ps2 = null;
    PreparedStatement ps3 = null;
    ResultSet rs1         = null;
    ResultSet rs2         = null;
    ResultSet rs3         = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // --------------------------------------------------
        // 3a) Obtener datos básicos del mentor, incluido "estado"
        // --------------------------------------------------
        String sql =
          "SELECT nombre, email, especialidad, experiencia, tarifa, estado " +
          "FROM mentores WHERE id = ?";
        ps1 = conn.prepareStatement(sql);
        ps1.setInt(1, mentorId);
        rs1 = ps1.executeQuery();
        if (rs1.next()) {
            nombre       = rs1.getString("nombre")       != null ? rs1.getString("nombre")       : "";
            email        = rs1.getString("email")        != null ? rs1.getString("email")        : "";
            especialidad = rs1.getString("especialidad") != null ? rs1.getString("especialidad") : "";
            experiencia  = rs1.getString("experiencia")  != null ? rs1.getString("experiencia")  : "";
            tarifa       = rs1.getString("tarifa")       != null ? rs1.getString("tarifa")       : "";
            estado       = rs1.getString("estado")       != null ? rs1.getString("estado")       : "en_linea";
        } else {
            // Si no se encuentra al mentor en la BD, regresar al home
            response.sendRedirect("mentor_home.jsp");
            return;
        }

        // --------------------------------------------------
        // 3b) Contar cuántos mentoreados distintos ha tenido
        // --------------------------------------------------
        String sqlStats =
          "SELECT COUNT(DISTINCT emprendedor_id) AS total_mentoreados " +
          "FROM contacto_mentor WHERE mentor_id = ?";
        ps2 = conn.prepareStatement(sqlStats);
        ps2.setInt(1, mentorId);
        rs2 = ps2.executeQuery();
        if (rs2.next()) {
            totalMentoreados = rs2.getInt("total_mentoreados");
        }

        // --------------------------------------------------
        // 3c) Contar cuántas consultas totales ha tenido
        // --------------------------------------------------
        String sqlConsultas =
          "SELECT COUNT(*) AS total_consultas FROM contacto_mentor WHERE mentor_id = ?";
        ps3 = conn.prepareStatement(sqlConsultas);
        ps3.setInt(1, mentorId);
        rs3 = ps3.executeQuery();
        if (rs3.next()) {
            totalConsultas = rs3.getInt("total_consultas");
        }

    } catch (Exception e) {
        out.println("Error al cargar perfil: " + e.getMessage());
        e.printStackTrace(new java.io.PrintWriter(out));
    } finally {
        // --------------------------------------------------
        // 3d) Cerrar recursos JDBC
        // --------------------------------------------------
        try { if (rs3 != null) rs3.close(); } catch(Exception ex) { ex.printStackTrace(new java.io.PrintWriter(out)); }
        try { if (ps3 != null) ps3.close(); } catch(Exception ex) { ex.printStackTrace(new java.io.PrintWriter(out)); }
        try { if (rs2 != null) rs2.close(); } catch(Exception ex) { ex.printStackTrace(new java.io.PrintWriter(out)); }
        try { if (ps2 != null) ps2.close(); } catch(Exception ex) { ex.printStackTrace(new java.io.PrintWriter(out)); }
        try { if (rs1 != null) rs1.close(); } catch(Exception ex) { ex.printStackTrace(new java.io.PrintWriter(out)); }
        try { if (ps1 != null) ps1.close(); } catch(Exception ex) { ex.printStackTrace(new java.io.PrintWriter(out)); }
        try { if (conn != null) conn.close(); } catch(Exception ex) { ex.printStackTrace(new java.io.PrintWriter(out)); }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi Perfil - Mentor</title>
    <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">

    <style>
        /* ============ RESET y variables globales ============ */
        * {
            margin: 0; padding: 0;
            box-sizing: border-box;
        }
        body {
            background: linear-gradient(135deg, #0f0f0f 0%, #1a1a1a 100%);
            color: #e0e0e0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
            padding: 20px;
        }

        /* ============ HEADER con navegación (mantendremos compacto, pero no lo usamos) ============ */
        .header {
            background: rgba(30, 30, 30, 0.95);
            backdrop-filter: blur(10px);
            padding: 1rem 2rem;
            border-radius: 15px;
            margin-bottom: 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 20px rgba(0,0,0,0.3);
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

        /* ============ CONTENEDOR PRINCIPAL ============ */
        .main-container {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 1fr 2fr;
            gap: 2rem;
        }

        /* ============ TARJETA DE PERFIL ============ */
        .profile-card {
            background: rgba(31, 31, 31, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 2rem;
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
            border: 1px solid rgba(255,255,255,0.1);
            height: fit-content;
            position: sticky;
            top: 20px;
        }
        .profile-header {
            text-align: center;
            margin-bottom: 2rem;
            position: relative; /* Para posicionar el dropdown de estado */
        }
        .profile-avatar {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background: linear-gradient(135deg, #008891, #00a5a5);
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1rem;
            font-size: 3rem;
            color: white;
            font-weight: bold;
            box-shadow: 0 8px 24px rgba(0, 168, 165, 0.3);
        }
        .profile-name {
            font-size: 1.8rem;
            font-weight: 600;
            color: #00c1c1;
            margin-bottom: 0.5rem;
        }
        .profile-specialty {
            color: #888;
            font-size: 1rem;
            margin-bottom: 1rem;
        }

        /* ============ SELECTOR DE ESTADO ============ */
        .status-button {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            background: rgba(255,255,255,0.1);
            color: #e0e0e0;
            border: 1px solid rgba(255,255,255,0.2);
            padding: 0.4rem 0.8rem;
            border-radius: 20px;
            font-size: 0.9rem;
            cursor: pointer;
            position: relative;
            transition: all 0.3s;
            margin-top: 0.5rem;
        }
        .status-button:hover {
            background: rgba(255,255,255,0.15);
            transform: translateY(-1px);
        }
        .status-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            display: inline-block;
        }
        .dot-en_linea    { background-color: #2ecc71; }  /* verde */
        .dot-ausente     { background-color: #f1c40f; }  /* amarillo */
        .dot-no_molestar { background-color: #e74c3c; }  /* rojo */

        .status-dropdown {
            position: absolute;
            top: 100%;
            left: 50%;
            transform: translateX(-50%);
            background: rgba(31, 31, 31, 0.95);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 8px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
            margin-top: 0.5rem;
            z-index: 100;
            display: none; /* Se muestra al hacer clic en el botón */
        }
        .status-dropdown ul {
            list-style: none;
        }
        .status-dropdown li {
            padding: 0.75rem 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            cursor: pointer;
            transition: background 0.2s;
            color: #e0e0e0;
        }
        .status-dropdown li:hover {
            background: rgba(255,255,255,0.1);
        }
        .status-dropdown li .status-dot {
            width: 12px;
            height: 12px;
        }

        /* ============ ESTADÍSTICAS ============ */
        .stats-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            margin-top: 2rem;
        }
        .stat-card {
            background: rgba(0, 168, 165, 0.1);
            border: 1px solid rgba(0, 168, 165, 0.3);
            border-radius: 12px;
            padding: 1rem;
            text-align: center;
        }
        .stat-number {
            font-size: 2rem;
            font-weight: bold;
            color: #00a5a5;
            display: block;
        }
        .stat-label {
            font-size: 0.9rem;
            color: #888;
            margin-top: 0.5rem;
        }

        /* ============ BOTONES DE ACCIÓN RÁPIDA ============ */
        .action-buttons {
            display: flex;
            gap: 1rem;
            margin-top: 2rem;
        }
        .btn {
            flex: 1;
            padding: 1rem 1.5rem;
            border: none;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            text-align: center;
            transition: all 0.3s;
            position: relative;
            overflow: hidden;
        }
        .btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
            transition: left 0.5s;
        }
        .btn:hover::before {
            left: 100%;
        }
        .btn-primary {
            background: linear-gradient(135deg, #008891, #00a5a5);
            color: white;
        }
        .btn-primary:hover {
            background: linear-gradient(135deg, #00a5a5, #00c1c1);
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(0, 168, 165, 0.3);
        }
        .btn-secondary {
            background: rgba(255,255,255,0.1);
            color: #e0e0e0;
            border: 1px solid rgba(255,255,255,0.2);
        }
        .btn-secondary:hover {
            background: rgba(255,255,255,0.2);
            transform: translateY(-2px);
        }

        /* ============ INFORMACIÓN DETALLADA ============ */
        .info-section {
            background: rgba(31, 31, 31, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 2rem;
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
            border: 1px solid rgba(255,255,255,0.1);
        }
        .section-title {
            font-size: 1.5rem;
            color: #00a5a5;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .info-grid {
            display: grid;
            gap: 1.5rem;
        }
        .info-item {
            background: rgba(40, 40, 40, 0.5);
            border-radius: 12px;
            padding: 1.5rem;
            border-left: 4px solid #00a5a5;
            transition: all 0.3s;
        }
        .info-item:hover {
            background: rgba(40, 40, 40, 0.8);
            transform: translateX(5px);
        }
        .info-label {
            font-weight: 600;
            color: #00c1c1;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .info-value {
            color: #e0e0e0;
            font-size: 1rem;
            line-height: 1.5;
            word-wrap: break-word;
        }
        .info-value.empty {
            color: #666;
            font-style: italic;
        }

        /* ============ RESPONSIVE ============ */
        @media (max-width: 768px) {
            .main-container {
                grid-template-columns: 1fr;
                gap: 1rem;
            }
            .header {
                flex-direction: column;
                gap: 1rem;
                text-align: center;
            }
            .header h1 {
                font-size: 1.5rem;
            }
            .stats-grid {
                grid-template-columns: 1fr;
            }
            .action-buttons {
                flex-direction: column;
            }
            .profile-card {
                position: static;
            }
        }

        /* ============ ANIMACIONES ============ */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        .profile-card, .info-section {
            animation: fadeInUp 0.6s ease-out;
        }
        .info-section {
            animation-delay: 0.2s;
        }

        /* ============ ICONOS ============ */
        .icon {
            width: 20px;
            height: 20px;
            display: inline-block;
        }

        /* ================= MENU LATERAL (copiado de mentor_home.jsp) ================= */
        /* ===== HEADER CON MENÚ LATERAL ===== */
        header.main-header {
            background: #1e1e1e;
            padding: 1rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 1000;
            box-shadow: 0 2px 15px rgba(0, 128, 128, 0.12);
            border-bottom: 1px solid rgba(0, 128, 128, 0.2);
        }
        header.main-header h1 {
            margin: 0;
            font-size: 1.8rem;
            color: #008080;
            font-weight: 600;
            letter-spacing: 0.5px;
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
        .side-menu {
            position: fixed;
            top: 0;
            right: -350px;
            width: 350px;
            height: 100vh;
            background: #1e1e1e;
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
            color: #008080;
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
            background: rgba(0, 128, 128, 0.15);
            color: #008080;
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
            color: #008080;
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
            background: rgba(0, 128, 128, 0.1);
            border-left-color: #008080;
            color: #008080;
        }
        .menu-item-icon {
            font-size: 1.1rem;
            width: 20px;
            text-align: center;
        }
        .user-info {
            background: #333;
            margin: 1rem;
            padding: 1.2rem;
            border-radius: 8px;
            border-left: 3px solid #008080;
        }
        .user-info h4 {
            margin: 0 0 0.5rem;
            color: #008080;
            font-size: 1.1rem;
            font-weight: 600;
        }
        .user-info p {
            margin: 0.3rem 0;
            color: #ccc;
            font-size: 0.9rem;
        }
        @media (max-width: 768px) {
            .side-menu {
                width: 100%;
                right: -100%;
            }
        }
        @media (max-width: 480px) {
            .side-menu {
                width: 100%;
                right: -100%;
            }
        }
        /* Agregar estas reglas CSS al archivo existente */

/* Efecto especial para el ítem de Ayuda 
.menu-item.help-item {
    background: rgba(231, 76, 60, 0.1) !important;
    border-left-color: #e74c3c !important;
    color: #e74c3c !important;
    position: relative;
    box-shadow: 0 2px 8px rgba(231, 76, 60, 0.2);
}

.menu-item.help-item:hover {
    background: rgba(231, 76, 60, 0.2) !important;
    border-left-color: #c0392b !important;
    color: #c0392b !important;
    transform: translateX(5px);
    box-shadow: 0 4px 12px rgba(231, 76, 60, 0.3);
}

/* Efecto de brillo sutil 
.menu-item.help-item::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: linear-gradient(90deg, transparent, rgba(231, 76, 60, 0.1), transparent);
    animation: shimmer 3s infinite;
    pointer-events: none;
}*/

@keyframes shimmer {
    0% { transform: translateX(-100%); }
    100% { transform: translateX(100%); }
}

/* Opcional: Agregar un pequeño badge de notificación */
.menu-item.help-item .menu-item-icon {
    color: #e74c3c;
    filter: drop-shadow(0 0 4px rgba(231, 76, 60, 0.5));
}

/* Variante más intensa del efecto rojo */
.menu-item.help-item.intense {
    background: rgba(231, 76, 60, 0.15) !important;
    border-left-width: 4px;
    animation: pulse-red 2s infinite;
}

@keyframes pulse-red {
    0%, 100% { 
        background: rgba(231, 76, 60, 0.15);
        box-shadow: 0 2px 8px rgba(231, 76, 60, 0.2);
    }
    50% { 
        background: rgba(231, 76, 60, 0.25);
        box-shadow: 0 4px 16px rgba(231, 76, 60, 0.4);
    }
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
    }===== */
    </style>
</head>
<body>
    <!-- ================== HEADER PRINCIPAL con HAMBURGUESA ================== -->
    <header class="main-header">
        <h1>Mi Perfil de Mentor</h1>
        <button class="menu-toggle" onclick="toggleMenu()">☰ Menú</button>
    </header>

    <!-- Overlay para cerrar menú -->
    <div class="menu-overlay" onclick="closeMenu()"></div>

    <!-- Menú lateral (idéntico al de mentor_home.jsp) -->
    <div class="side-menu" id="sideMenu">
        <div class="side-menu-header">
            <h3 class="side-menu-title">Navegación</h3>
            <button class="close-menu" onclick="closeMenu()">&times;</button>
        </div>
        <div class="side-menu-content">
            <!-- Información del mentor (puedes añadir más datos si gustas) -->
            <div class="user-info">
                <h4>¡Hola, <%= nombre %>!</h4>
                <p><strong>Email:</strong> <%= email %></p>
                <p><strong>Especialidad:</strong> <%= especialidad %></p>
            </div>

            <!-- Sección de navegación -->
            <div class="menu-section">
                <div class="menu-section-title">Navegación</div>
                <a href="mentor_home.jsp" class="menu-item">
                    <span class="menu-item-icon">🏠</span> Panel Principal
                </a>

                 <a href="historial_conversaciones.jsp" class="menu-item">
                    <span class="menu-item-icon">💬</span> Mi Perfil
                </a>
                
                <a href="mis_mentoreados.jsp" class="menu-item">
                    <span class="menu-item-icon">👥</span> Mis Mentoreados
                </a>
               
               
            

                <a href="ayuda.jsp" class="menu-item help-item">
                <span class="menu-item-icon">❓</span> Ayuda
                </a>
            </div>

            <!-- Sección de cuenta -->
            <div class="menu-section">
                <div class="menu-section-title">Cuenta</div>
                <a href="Logout.jsp" class="menu-item red-highlight" style="border-top: 2px solid #333; margin-top: auto;">
                    <span class="menu-item-icon">🚪</span> Cerrar Sesión
                </a>
            </div>
        </div>
    </div>
    <!-- ======================================================================= -->

    <!-- Dejamos un pequeño margen superior para que el contenido no se oculte detrás del header fijo -->
    <div style="height: 64px;"></div>

    <!-- ============ TARJETA DE PERFIL ============ -->
    <div class="main-container">
        <div class="profile-card">
            <div class="profile-header">
                <!-- Avatar con la inicial del nombre -->
                <div class="profile-avatar">
                    <%= nombre.length() > 0 ? nombre.substring(0,1).toUpperCase() : "M" %>
                </div>
                <!-- Nombre y especialidad -->
                <div class="profile-name"><%= nombre.isEmpty() ? "Nombre no especificado" : nombre %></div>
                <div class="profile-specialty">
                    🎯 <%= especialidad.isEmpty() ? "Especialidad no especificada" : especialidad %>
                </div>

                <!-- ============ Selector de Estado ============ -->
                <form id="form-estado" action="cambiarEstadoMentor.jsp" method="post" style="display: inline;">
                    <!-- Campo oculto para enviar el nuevo estado -->
                    <input type="hidden" name="nuevoEstado" id="input-nuevo-estado" value="<%= estado %>">
                    <button type="button" class="status-button" id="btn-estado">
                        <!-- Punto de color según el estado -->
                        <span class="status-dot dot-<%= estado %>"></span>
                        <!-- Texto legible del estado -->
                        <%
                            String etiqueta = "";
                            switch(estado) {
                                case "en_linea":    etiqueta = "En línea";      break;
                                case "ausente":     etiqueta = "Ausente";       break;
                                case "no_molestar": etiqueta = "No Molestar";   break;
                                default:            etiqueta = "En línea";      break;
                            }
                        %>
                        <span id="label-estado-actual"><%= etiqueta %></span>
                    </button>

                    <!-- Dropdown con las opciones de estado -->
                    <div class="status-dropdown" id="dropdown-estado">
                        <ul>
                            <li data-valor="en_linea">
                                <span class="status-dot dot-en_linea"></span> En línea
                            </li>
                            <li data-valor="ausente">
                                <span class="status-dot dot-ausente"></span> Ausente
                            </li>
                            <li data-valor="no_molestar">
                                <span class="status-dot dot-no_molestar"></span> No molestar
                            </li>
                        </ul>
                    </div>
                </form>
                <!-- =============================================== -->
            </div>

            <!-- ============ ESTADÍSTICAS ============ -->
            <div class="stats-grid">
                <div class="stat-card">
                    <span class="stat-number"><%= totalMentoreados %></span>
                    <div class="stat-label">Mentoreados</div>
                </div>
                <div class="stat-card">
                    <span class="stat-number"><%= totalConsultas %></span>
                    <div class="stat-label">Consultas</div>
                </div>
            </div>

            <!-- ============ BOTÓN DE EDITAR PERFIL ============ -->
            <div class="action-buttons">
                <a href="editar_perfil.jsp" class="btn btn-secondary">✏️ Editar Perfil</a>
            </div>
        </div>

        <!-- ============ INFORMACIÓN DETALLADA ============ -->
        <div class="info-section">
            <h2 class="section-title">📋 Información Personal</h2>
            <div class="info-grid">
                <!-- Nombre completo -->
                <div class="info-item">
                    <div class="info-label">
                        <span class="icon">👤</span>
                        Nombre Completo
                    </div>
                    <div class="info-value <%= nombre.isEmpty() ? "empty" : "" %>">
                        <%= nombre.isEmpty() ? "No especificado" : nombre %>
                    </div>
                </div>
                <!-- Correo electrónico -->
                <div class="info-item">
                    <div class="info-label">
                        <span class="icon">📧</span>
                        Correo Electrónico
                    </div>
                    <div class="info-value <%= email.isEmpty() ? "empty" : "" %>">
                        <%= email.isEmpty() ? "No especificado" : email %>
                    </div>
                </div>
                <!-- Especialidad -->
                <div class="info-item">
                    <div class="info-label">
                        <span class="icon">🎯</span>
                        Especialidad
                    </div>
                    <div class="info-value <%= especialidad.isEmpty() ? "empty" : "" %>">
                        <%= especialidad.isEmpty() ? "No especificada" : especialidad %>
                    </div>
                </div>
                <!-- Experiencia -->
                <div class="info-item">
                    <div class="info-label">
                        <span class="icon">⭐</span>
                        Experiencia
                    </div>
                    <div class="info-value <%= experiencia.isEmpty() ? "empty" : "" %>">
                        <%= experiencia.isEmpty() ? "No especificada" : experiencia %>
                    </div>
                </div>
                <!-- Tarifa -->
                <div class="info-item">
                    <div class="info-label">
                        <span class="icon">💰</span>
                        Tarifa
                    </div>
                    <div class="info-value <%= tarifa.isEmpty() ? "empty" : "" %>">
                        <%= tarifa.isEmpty() ? "No especificada" : tarifa %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- ============ JavaScript para manejar el selector de estado ============ -->
    <script>
        // Referencias a elementos HTML
        const btnEstado        = document.getElementById('btn-estado');
        const dropdownEstado   = document.getElementById('dropdown-estado');
        const inputNuevoEstado = document.getElementById('input-nuevo-estado');
        const labelActual      = document.getElementById('label-estado-actual');

        // Mostrar/ocultar dropdown al hacer clic en el botón
        btnEstado.addEventListener('click', function(e) {
            e.stopPropagation(); // Evita que el clic cierre inmediatamente el dropdown
            dropdownEstado.style.display = dropdownEstado.style.display === 'block' ? 'none' : 'block';
        });

        // Cerrar el dropdown si el usuario hace clic fuera de él
        document.addEventListener('click', function() {
            dropdownEstado.style.display = 'none';
        });

        // Cada vez que el usuario hace clic en una opción del dropdown:
        dropdownEstado.querySelectorAll('li').forEach(function(li) {
            li.addEventListener('click', function(e) {
                e.stopPropagation();
                // 1) Obtener el nuevo valor de estado
                const nuevoValor = this.getAttribute('data-valor');

                // 2) Actualizar el color del punto en el botón
                btnEstado.querySelector('.status-dot').className = 'status-dot dot-' + nuevoValor;

                // 3) Actualizar el texto visible del estado
                let texto = '';
                switch(nuevoValor) {
                    case 'en_linea':    texto = 'En línea';    break;
                    case 'ausente':     texto = 'Ausente';     break;
                    case 'no_molestar': texto = 'No molestar'; break;
                }
                labelActual.textContent = texto;

                // 4) Poner el valor en el campo oculto y enviar el formulario
                inputNuevoEstado.value = nuevoValor;
                document.getElementById('form-estado').submit();
            });
        });

        // ================== JavaScript para el menú lateral ==================
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
