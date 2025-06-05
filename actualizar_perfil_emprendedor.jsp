<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    // 1) Validar sesión de emprendedor
    String rol     = (String) session.getAttribute("rol");
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null || !"emprendedor".equals(rol)) {
        response.sendRedirect("Login_emprendedor.jsp");
        return;
    }

    // 2) Leer parámetros enviados
    String idParam     = request.getParameter("id");
    String nuevoNombre = request.getParameter("nombre");
    String nuevoEmail  = request.getParameter("email");
    String nuevoTel    = request.getParameter("telefono");
    String nuevoNeg    = request.getParameter("negocio");
    String nuevaDesc   = request.getParameter("descripcion");

    if (idParam == null || idParam.trim().isEmpty()) {
        out.println("<p style='color:red;'>Error: ID inválido.</p>");
        out.println("<a href='emprendedor_home.jsp'>Volver</a>");
        return;
    }
    int empId = Integer.parseInt(idParam);

    String dbUrl  = "jdbc:mysql://localhost:3306/red_de_apoyo?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
    String dbUser = "root";
    String dbPass = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass)) {
            String sql = "UPDATE emprendedores " +
                         "SET nombre = ?, email = ?, telefono = ?, negocio = ?, descripcion = ? " +
                         "WHERE id = ?";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, nuevoNombre);
                ps.setString(2, nuevoEmail);
                ps.setString(3, (nuevoTel != null && !nuevoTel.trim().isEmpty()) ? nuevoTel : null);
                ps.setString(4, nuevoNeg);
                ps.setString(5, (nuevaDesc != null && !nuevaDesc.trim().isEmpty()) ? nuevaDesc : null);
                ps.setInt(6, empId);

                int filas = ps.executeUpdate();
                if (filas > 0) {
                    // Redirigir a panel de emprendedor
                    response.sendRedirect("emprendedor_home.jsp");
                    return;
                } else {
                    out.println("<p style='color:red;'>No se pudo actualizar el perfil. Intenta nuevamente.</p>");
                    out.println("<a href='emprendedor_home.jsp'>Volver</a>");
                    return;
                }
            }
        }
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error al actualizar: " + e.getMessage() + "</p>");
        out.println("<a href='emprendedor_home.jsp'>Volver</a>");
    }
%>
