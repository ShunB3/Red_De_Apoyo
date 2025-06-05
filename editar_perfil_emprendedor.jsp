<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    // 1) Validar sesión
    String rol     = (String) session.getAttribute("rol");
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null || !"emprendedor".equals(rol)) {
        response.sendRedirect("Login_emprendedor.jsp");
        return;
    }

    // 2) Obtener datos actuales del emprendedor
    String nombre      = "";
    String email       = "";
    String telefono    = "";
    String negocio     = "";
    String descripcion = "";

    String dbUrl  = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser = "root";
    String dbPass = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
             PreparedStatement ps = conn.prepareStatement(
               "SELECT nombre, email, telefono, negocio, descripcion FROM emprendedores WHERE id = ?"
             )) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    nombre      = rs.getString("nombre");
                    email       = rs.getString("email");
                    telefono    = rs.getString("telefono");
                    negocio     = rs.getString("negocio");
                    descripcion = rs.getString("descripcion");
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
  <title>Editar Perfil – Emprendedor</title>
  <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
  <style>
    body {
      margin: 0;
      padding: 0;
      background: #121212;
      color: #e0e0e0;
      font-family: 'Segoe UI', sans-serif;
      display: flex;
      flex-direction: column;
      min-height: 100vh;
    }
    header {
      background: #1e1e1e;
      padding: 1rem;
      text-align: center;
    }
    header h1 {
      margin: 0;
      font-size: 1.8rem;
    }
    main {
      flex: 1;
      display: flex;
      justify-content: center;
      align-items: flex-start;
      padding: 2rem;
    }
    form {
      background: #1f1f1f;
      padding: 2rem;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.5);
      width: 100%;
      max-width: 500px;
      box-sizing: border-box;
    }
    form label {
      display: block;
      margin-top: 1rem;
      font-size: 0.95rem;
    }
    form input[type="text"],
    form textarea {
      width: 100%;
      padding: 0.5rem;
      margin-top: 0.25rem;
      border: 1px solid #333;
      border-radius: 4px;
      background: #2a2a2a;
      color: #e0e0e0;
      box-sizing: border-box;
    }
    form textarea { resize: vertical; min-height: 100px; }
    .btn-primary {
      margin-top: 1.5rem;
      display: inline-block;
      background: #00a5a5;
      color: #fff;
      padding: 0.75rem 1.25rem;
      border: none;
      border-radius: 4px;
      font-weight: bold;
      cursor: pointer;
      text-decoration: none;
    }
    .btn-primary:hover { background: #008080; }
    .btn-secondary {
      margin-left: 1rem;
      background: transparent;
      border: 1px solid #00a5a5;
      color: #00a5a5;
      padding: 0.75rem 1.25rem;
      border-radius: 4px;
      text-decoration: none;
    }
    .btn-secondary:hover {
      background: #00a5a5;
      color: #121212;
    }
    footer {
      background: #1e1e1e;
      text-align: center;
      padding: 1rem;
      color: #888;
    }
  </style>
</head>
<body>
<header>
  <h1>Editar Perfil – Emprendedor</h1>
</header>

<main>
  <form action="actualizar_perfil_emprendedor.jsp" method="post">
    <input type="hidden" name="id" value="<%= userId %>">

    <label for="nombre">Nombre Completo:</label>
    <input type="text" id="nombre" name="nombre" value="<%= nombre %>" required>

    <label for="email">Email:</label>
    <input type="text" id="email" name="email" value="<%= email %>" required>

    <label for="telefono">Teléfono:</label>
    <input type="text" id="telefono" name="telefono" value="<%= telefono %>">

    <label for="negocio">Negocio:</label>
    <input type="text" id="negocio" name="negocio" value="<%= negocio %>" required>

    <label for="descripcion">Descripción:</label>
    <textarea id="descripcion" name="descripcion" rows="4"><%= descripcion %></textarea>

    <button type="submit" class="btn-primary">Guardar Cambios</button>
    <a href="emprendedor_home.jsp" class="btn-secondary">Cancelar</a>
  </form>
</main>

<footer>
  &copy; 2025 Red de Apoyo a Emprendedores Locales
</footer>
</body>
</html>