<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    // 1) Verificar sesión activa de mentor
    Integer mentorId = (Integer) session.getAttribute("userId");
    String rol       = (String) session.getAttribute("rol");
    if (mentorId == null || !"mentor".equals(rol)) {
        response.sendRedirect("Login_mentor.jsp");
        return;
    }

    // 2) Variables para almacenar datos actuales
    String dbUrl        = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser       = "root";
    String dbPass       = "";
    String nombre       = "";
    String email        = "";
    String especialidad = "";
    String experiencia  = "";
    String tarifa       = "";

    // 3) Cargar datos actuales desde BD
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
             PreparedStatement ps = conn.prepareStatement(
                "SELECT nombre, email, especialidad, experiencia, tarifa " +
                "FROM mentores WHERE id = ?"
             )) {
            ps.setInt(1, mentorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    nombre       = rs.getString("nombre")       != null ? rs.getString("nombre")       : "";
                    email        = rs.getString("email")        != null ? rs.getString("email")        : "";
                    especialidad = rs.getString("especialidad") != null ? rs.getString("especialidad") : "";
                    experiencia  = rs.getString("experiencia")  != null ? rs.getString("experiencia")  : "";
                    tarifa       = rs.getString("tarifa")       != null ? rs.getString("tarifa")       : "";
                } else {
                    // Si no existe el mentor, redirigirlo al home
                    response.sendRedirect("mentor_home.jsp");
                    return;
                }
            }
        }
    } catch (Exception e) {
        out.println("Error al cargar datos para editar: " + e.getMessage());
        e.printStackTrace(new java.io.PrintWriter(out));
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Editar Perfil - Mentor</title>
    <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
    <style>
        * {
            margin: 0; padding: 0;
            box-sizing: border-box;
        }
        body {
            background: #121212;
            color: #e0e0e0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 600px;
            margin: 2rem auto;
            background: rgba(31,31,31,0.95);
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.5);
            border: 1px solid rgba(255,255,255,0.1);
        }
        h2 {
            text-align: center;
            margin-bottom: 1.5rem;
            color: #00a5a5;
        }
        form {
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }
        label {
            font-size: 0.9rem;
            color: #ccc;
        }
        input[type="text"],
        input[type="email"],
        textarea {
            width: 100%;
            padding: 0.75rem;
            background: #1e1e1e;
            border: 1px solid #333;
            border-radius: 4px;
            color: #e0e0e0;
            font-size: 1rem;
            outline: none;
            transition: border-color 0.2s;
        }
        input[type="text"]:focus,
        input[type="email"]:focus,
        textarea:focus {
            border-color: #00a5a5;
        }
        textarea {
            resize: vertical;
            min-height: 100px;
        }
        .btn-submit {
            background: #008891;
            color: white;
            padding: 0.75rem;
            border: none;
            border-radius: 6px;
            font-size: 1rem;
            cursor: pointer;
            transition: background 0.3s ease;
        }
        .btn-submit:hover {
            background: #00a5a5;
        }

        /* --------------------------------------------------
           Estilos del botón Cancelar (ahora se ve como un botón)
           -------------------------------------------------- */
        .btn-cancel {
          display: inline-block;
          background: #e74c3c;
          color: #ffffff;
          padding: 0.75rem 1.2rem;
          border: none;
          border-radius: 6px;
          font-size: 1rem;
          text-decoration: none;
          text-align: center;
          cursor: pointer;
          transition: background 0.3s ease;
          margin-top: 1rem;
        }
        .btn-cancel:hover {
          background: #c0392b;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Editar Perfil</h2>
        <form action="editar_perfil_action.jsp" method="post">
            <!-- Enviamos el mentor_id oculto -->
            <input type="hidden" name="mentor_id" value="<%= mentorId %>">

            <div>
                <label for="nombre">Nombre Completo</label>
                <input type="text" id="nombre" name="nombre" maxlength="100"
                       value="<%= nombre %>" required>
            </div>

            <div>
                <label for="email">Correo Electrónico</label>
                <input type="email" id="email" name="email" maxlength="100"
                       value="<%= email %>" required>
            </div>

            <div>
                <label for="especialidad">Especialidad</label>
                <input type="text" id="especialidad" name="especialidad" maxlength="100"
                       value="<%= especialidad %>" required>
            </div>

            <div>
                <label for="experiencia">Experiencia</label>
                <textarea id="experiencia" name="experiencia" maxlength="500"><%= experiencia %></textarea>
            </div>

            <div>
                <label for="tarifa">Tarifa (p.ej. 50.00)</label>
                <input type="text" id="tarifa" name="tarifa" maxlength="20"
                       value="<%= tarifa %>" pattern="^\d+(\.\d{1,2})?$"
                       title="Formato numérico, opcionalmente con 2 decimales" required>
            </div>

            <button type="submit" class="btn-submit">Guardar Cambios</button>
        </form>

        <!-- Botón Cancelar con nuevo estilo -->
        <a href="perfil_mentor.jsp" class="btn-cancel">&larr; Cancelar</a>
    </div>
</body>
</html>
