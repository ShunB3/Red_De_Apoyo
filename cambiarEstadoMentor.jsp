<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    // ------------------------------------------------------
    // 1) Verificar sesión activa y rol de mentor
    // ------------------------------------------------------
    Integer mentorId = (Integer) session.getAttribute("userId");
    String rol       = (String) session.getAttribute("rol");
    if (mentorId == null || !"mentor".equals(rol)) {
        response.sendRedirect("Login_mentor.jsp");
        return;
    }

    // ------------------------------------------------------
    // 2) Obtener el parámetro que envía el formulario
    // ------------------------------------------------------
    String nuevoEstado = request.getParameter("nuevoEstado");

    // Si no llega nada en el parámetro, retroceder al perfil
    if (nuevoEstado == null) {
        response.sendRedirect("perfil_mentor.jsp");
        return;
    }

    // ------------------------------------------------------
    // 3) Validar que el valor esté dentro de las opciones permitidas
    // ------------------------------------------------------
    if (!nuevoEstado.equals("en_linea") &&
        !nuevoEstado.equals("ausente") &&
        !nuevoEstado.equals("no_molestar") &&
        !nuevoEstado.equals("invisible")) {
        // Valor inválido, no hacemos nada y volvemos al perfil
        response.sendRedirect("perfil_mentor.jsp");
        return;
    }

    // ------------------------------------------------------
    // 4) Actualizar el campo "estado" en la base de datos
    // ------------------------------------------------------
    Connection conn = null;
    PreparedStatement ps = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/red_de_apoyo", "root", ""
        );
        String sql = "UPDATE mentores SET estado = ? WHERE id = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, nuevoEstado);
        ps.setInt(2, mentorId);
        int filas = ps.executeUpdate();

        // Para depurar en los logs de Tomcat:
        getServletContext().log("DEBUG: filas actualizadas = " + filas + ", nuevoEstado = " + nuevoEstado);
    } catch (Exception e) {
        // Si hay error, lo mostramos en pantalla:
        out.println("Error al actualizar estado: " + e.getMessage());
        e.printStackTrace(new java.io.PrintWriter(out));
    } finally {
        try { if (ps != null) ps.close(); } catch(Exception ex) { ex.printStackTrace(new java.io.PrintWriter(out)); }
        try { if (conn != null) conn.close(); } catch(Exception ex) { ex.printStackTrace(new java.io.PrintWriter(out)); }
    }

    // ------------------------------------------------------
    // 5) Después de actualizar, redirigir de nuevo a perfil
    // ------------------------------------------------------
    response.sendRedirect("perfil_mentor.jsp");
%>
