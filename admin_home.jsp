<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    Integer adminId = (Integer) session.getAttribute("adminId");
    String adminName = (String) session.getAttribute("adminName");
    if (adminId == null) {
        response.sendRedirect("Login_admin.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Admin – RED_DE_APOYO</title>
    <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

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
    }
    .header-container {
      max-width: 1200px;
      margin: 0 auto;
      display: flex;
      flex-wrap: wrap;
      justify-content: space-between;
      align-items: center;
      gap: 1rem;
    }
    header h1 {
      font-size: 1.8rem;
      color: #fff;
    }

    /* Navegación */
    nav ul {
      list-style: none;
      display: flex;
      gap: 1.5rem;
      padding: 0;
      margin-top: 1rem;
    }
    nav a {
      color: #e0e0e0;
      text-decoration: none;
      font-weight: bold;
      padding: 0.5rem 1rem;
      border-radius: 4px;
      transition: background-color 0.3s ease;
    }
    nav a:hover,
    nav a.active {
      background-color: #008891;
      color: #fff;
    }

    /* Botón */
    .btn {
      background-color: #008891;
      color: #fff;
      padding: 0.8rem 1.2rem;
      border: none;
      border-radius: 8px;
      cursor: pointer;
      font-weight: bold;
      transition: all 0.3s ease;
      margin-top: 1rem;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 0.5rem;
      font-size: 1.1rem;
      box-shadow: 0 2px 4px rgba(0,0,0,0.2);
    }
    .btn:hover {
      background-color: #006f78;
      transform: translateY(-2px);
      box-shadow: 0 4px 8px rgba(0,0,0,0.3);
    }
    .btn i {
      font-size: 1.2rem;
    }
    .btn:hover {
      background-color: #006f78;
    }

    /* Main */
    .main-container {
      flex: 1;
      max-width: 900px;
      margin: 2rem auto;
      padding: 1rem;
    }
    .welcome {
      background-color: #1a1a1a;
      border-radius: 8px;
      padding: 2rem;
      box-shadow: 0 4px 12px rgba(0,0,0,0.2);
      text-align: center;
    }
    .welcome h2 {
      margin-bottom: 1rem;
      font-size: 1.6rem;
    }
    .welcome p {
      margin-bottom: 1.5rem;
      color: #ccc;
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

    /* Responsive */
    @media (max-width: 768px) {
      .header-container { flex-direction: column; align-items: flex-start; }
      nav ul { flex-wrap: wrap; }
    }
  </style>
</head>
<body>
  <header>
    <div class="header-container">
      <h1>Panel de Administrador</h1>
      <nav>
        <ul>
    
        </ul>
      </nav>
      <button class="btn" onclick="location.href='Logout.jsp'">Cerrar sesión</button>
    </div>
  </header>

  <div class="main-container">
    <div class="welcome">
      <h2>Bienvenido, <%= adminName %>!</h2>
      <p>Desde aquí puedes gestionar la plataforma, revisar usuarios, publicaciones y eventos.</p>
      <div style="display: flex; flex-direction: column; gap: 1.2rem; max-width: 350px; margin: 0 auto;">
        <button class="btn" onclick="location.href='calendario_admin.jsp'">
          <i class="fas fa-calendar-alt"></i>
          Ver Calendario de Eventos
        </button>
        <button class="btn" onclick="location.href='capacitaciones_ad.jsp'">
          <i class="fas fa-graduation-cap"></i>
          Gestionar Capacitaciones
        </button>
        <button class="btn" onclick="location.href='descargar_emprendedores.jsp'">
          <i class="fas fa-download"></i>
          Descargar Lista de Emprendedores
        </button>
      </div>
    </div>
  </div>

  <footer>
    &copy; 2025 Red de Apoyo a Emprendedores Locales
  </footer>
</body>
</html>
