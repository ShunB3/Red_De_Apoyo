<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    // 1) Verificar que exista sesión activa y sea un mentor
    Integer mentorId = (Integer) session.getAttribute("userId");
    String rol       = (String) session.getAttribute("rol");
    if (mentorId == null || !"mentor".equals(rol)) {
        response.sendRedirect("Login_mentor.jsp");
        return;
    }

    // 2) Recuperar parámetros del formulario
    String nuevoNombre       = request.getParameter("nombre");
    String nuevoEmail        = request.getParameter("email");
    String nuevaEspecialidad = request.getParameter("especialidad");
    String nuevaExperiencia  = request.getParameter("experiencia");
    String nuevaTarifa       = request.getParameter("tarifa");

    if (nuevoNombre == null || nuevoEmail == null 
        || nuevaEspecialidad == null || nuevaTarifa == null
        || nuevoNombre.trim().isEmpty() 
        || nuevoEmail.trim().isEmpty() 
        || nuevaEspecialidad.trim().isEmpty() 
        || nuevaTarifa.trim().isEmpty()) {
        // Si faltan campos obligatorios, regresar al formulario
        response.sendRedirect("editar_perfil.jsp");
        return;
    }

    // 3) Actualizar en la base de datos
    String dbUrl  = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser = "root";
    String dbPass = "";
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
             PreparedStatement ps = conn.prepareStatement(
                 "UPDATE mentores SET nombre = ?, email = ?, especialidad = ?, experiencia = ?, tarifa = ? " +
                 "WHERE id = ?"
             )) {
            ps.setString(1, nuevoNombre.trim());
            ps.setString(2, nuevoEmail.trim());
            ps.setString(3, nuevaEspecialidad.trim());
            ps.setString(4, nuevaExperiencia != null ? nuevaExperiencia.trim() : "");
            ps.setString(5, nuevaTarifa.trim());
            ps.setInt(6, mentorId);
            ps.executeUpdate();
        }
    } catch (Exception e) {
        out.println("Error al guardar cambios: " + e.getMessage());
        e.printStackTrace(new java.io.PrintWriter(out));
        return;
    }

    // 4) Redirigir de nuevo al perfil para ver los cambios
    response.sendRedirect("perfil_mentor.jsp");
%>
