<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.sql.Types" %>
<%
    // 1) Validar sesión de admin
    Integer adminId = (Integer) session.getAttribute("adminId");
    if (adminId == null) {
        response.sendRedirect("Login_admin.jsp");
        return;
    }

    // 2) Leer y validar parámetro id
    String idParam = request.getParameter("id");
    if (idParam == null || idParam.trim().isEmpty() || "undefined".equals(idParam)) {
        out.println("<p style='color:red;text-align:center;'>Error: Parámetro \"id\" inválido o ausente.</p>");
        out.println("<p style='text-align:center;'><a href='calendario_admin.jsp'>← Volver al calendario</a></p>");
        return;
    }
    int id;
    try {
        id = Integer.parseInt(idParam);
    } catch (NumberFormatException nfe) {
        out.println("<p style='color:red;text-align:center;'>Error: El ID debe ser un número válido.</p>");
        out.println("<p style='text-align:center;'><a href='calendario_admin.jsp'>← Volver al calendario</a></p>");
        return;
    }

    // 3) Leer resto de parámetros
    String titulo      = request.getParameter("title");
    String descripcion = request.getParameter("description");
    String inicio      = request.getParameter("start");
    String fin         = request.getParameter("end");

    // 4) Conexión a la BD
    String dbUrl  = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser = "root";
    String dbPass = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
             PreparedStatement ps = conn.prepareStatement(
               "UPDATE eventos SET titulo=?, descripcion=?, inicio=?, fin=? WHERE id=?"
             )) {
            ps.setString(1, titulo);
            ps.setString(2, descripcion);
            ps.setString(3, inicio);

            if (fin == null || fin.trim().isEmpty()) {
                ps.setNull(4, Types.TIMESTAMP);
            } else {
                ps.setString(4, fin);
            }

            ps.setInt(5, id);
            int rows = ps.executeUpdate();
            if (rows == 0) {
                out.println("<p style='color:red;text-align:center;'>Error: No se encontró ningún evento con ID=" + id + ".</p>");
                out.println("<p style='text-align:center;'><a href='calendario_admin.jsp'>← Volver al calendario</a></p>");
                return;
            }
        }
        // 5) Redirigir de vuelta al calendario
        response.sendRedirect("calendario_admin.jsp");
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p style='color:red;text-align:center;'>Error al actualizar evento: " + e.getMessage() + "</p>");
        out.println("<p style='text-align:center;'><a href='calendario_admin.jsp'>← Volver al calendario</a></p>");
    }
%>
