<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    // 1) Validar sesión de mentor
    Integer mentorId = (Integer) session.getAttribute("userId");
    String rol       = (String)  session.getAttribute("rol");
    if (mentorId == null || !"mentor".equals(rol)) {
        response.sendRedirect("Login_mentor.jsp");
        return;
    }

    // 2) Recoger parámetros del formulario
    String emprIdStr = request.getParameter("emprendedor_id");
    String accion    = request.getParameter("accion"); // "aceptar" o "rechazar"
    int emprendedorId = 0;
    try {
        emprendedorId = Integer.parseInt(emprIdStr);
    } catch (Exception ex) {
        // ID inválido, redirigir de vuelta
        response.sendRedirect("mentor_home.jsp");
        return;
    }

    // 3) Actualizar en BD el estado solicitado
    String nuevoEstado = "pendiente";
    if ("aceptar".equalsIgnoreCase(accion)) {
        nuevoEstado = "aceptado";
    } else if ("rechazar".equalsIgnoreCase(accion)) {
        nuevoEstado = "rechazado";
    } else {
        // acción desconocida → regresar
        response.sendRedirect("mentor_home.jsp");
        return;
    }

    String dbUrl  = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser = "root";
    String dbPass = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass)) {
            // Actualizamos la fila en contacto_mentor (mentorId, emprendedorId)
            String sql = 
              "UPDATE contacto_mentor " +
              "   SET estado = ? " +
              " WHERE mentor_id = ? AND emprendedor_id = ? AND estado = 'pendiente'";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, nuevoEstado);
                ps.setInt(2, mentorId);
                ps.setInt(3, emprendedorId);
                ps.executeUpdate();
            }
        }
    } catch (Exception e) {
        // En caso de error, podrás registrar o mostrar un mensaje
        e.printStackTrace(new java.io.PrintWriter(out));
    }

    // 4) Al terminar, redirigimos nuevamente al listado de “pendientes”
    response.sendRedirect("mentor_home.jsp");
%>
