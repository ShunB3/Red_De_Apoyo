<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    // 1) Validar sesión de mentor
    Integer mentorId = (Integer) session.getAttribute("userId");
    String rol = (String) session.getAttribute("rol");
    if (mentorId == null || !"mentor".equals(rol)) {
        response.sendRedirect("Login_mentor.jsp");
        return;
    }

    // 2) Leer parámetros
    String sEmprId = request.getParameter("emprendedor_id");
    String accion  = request.getParameter("accion"); // "aceptar" o "rechazar"
    if (sEmprId == null || accion == null) {
        response.sendRedirect("mentor_home.jsp");
        return;
    }
    int emprendedorId = Integer.parseInt(sEmprId);
    String nuevoEstado;
    if ("aceptar".equalsIgnoreCase(accion)) {
        nuevoEstado = "aceptado";
    } else if ("rechazar".equalsIgnoreCase(accion)) {
        nuevoEstado = "rechazado";
    } else {
        response.sendRedirect("mentor_home.jsp");
        return;
    }

    // 3) Actualizar estado en la base de datos
    String dbUrl  = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser = "root";
    String dbPass = "";
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass)) {
            String sql = 
                "UPDATE contacto_mentor " +
                "SET estado = ? " +
                "WHERE mentor_id = ? AND emprendedor_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, nuevoEstado);
                ps.setInt(2, mentorId);
                ps.setInt(3, emprendedorId);
                ps.executeUpdate();
            }
        }
    } catch (Exception e) {
        e.printStackTrace(new java.io.PrintWriter(out));
    }

    // 4) Redirigir de vuelta a mentor_home.jsp
    response.sendRedirect("mentor_home.jsp");
%>
