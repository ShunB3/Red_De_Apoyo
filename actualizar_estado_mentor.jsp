<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    // 1) Verificamos sesión de mentor
    Integer mentorId = (Integer) session.getAttribute("userId");
    String rol = (String) session.getAttribute("rol");
    if (!"mentor".equals(rol) || mentorId == null) {
        response.sendRedirect("Login_mentor.jsp");
        return;
    }

    // 2) Recuperamos parámetros del formulario
    String nuevoEstado = request.getParameter("estado");
    if (nuevoEstado == null || (!"Libre".equals(nuevoEstado) && !"Ocupado".equals(nuevoEstado))) {
        // Valor inválido. Redirigir de nuevo al perfil.
        response.sendRedirect("perfil_mentor.jsp");
        return;
    }

    // 3) Conexión a BD y actualización
    String dbUrl  = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser = "root";
    String dbPass = "";
    Connection conn = null;
    PreparedStatement ps = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        String sql = "UPDATE mentores SET estado = ? WHERE id = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, nuevoEstado);
        ps.setInt(2, mentorId);
        ps.executeUpdate();
    } catch (Exception e) {
        e.printStackTrace(new java.io.PrintWriter(out));
    } finally {
        try { if (ps != null) ps.close(); } catch(Exception ex) { ex.printStackTrace(new java.io.PrintWriter(out)); }
        try { if (conn != null) conn.close(); } catch(Exception ex) { ex.printStackTrace(new java.io.PrintWriter(out)); }
    }

    // 4) Redirigir de nuevo a perfil para ver el cambio
    response.sendRedirect("perfil_mentor.jsp");
%>
