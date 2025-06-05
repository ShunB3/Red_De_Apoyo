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

    // 2) Leer parámetro id (emprendedorId) y redirect opcional
    String strEmprId = request.getParameter("id");
    String redirectTo = request.getParameter("redirect");
    int emprendedorId = 0;
    try {
        emprendedorId = Integer.parseInt(strEmprId);
    } catch (Exception ex) {
        emprendedorId = 0;
    }
    if (emprendedorId == 0) {
        response.sendRedirect("panel_mentor.jsp");
        return;
    }

    // 3) Conexión BD
    String dbUrl  = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser = "root";
    String dbPass = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass)) {
            // a) Calcular total_contactos
            String cuentaSql = 
              "SELECT COUNT(*) AS cnt " +
              "FROM contacto_mentor " +
              "WHERE mentor_id = ? AND emprendedor_id = ?";
            int totalContactos = 0;
            try (PreparedStatement ps1 = conn.prepareStatement(cuentaSql)) {
                ps1.setInt(1, mentorId);
                ps1.setInt(2, emprendedorId);
                try (ResultSet rs1 = ps1.executeQuery()) {
                    if (rs1.next()) {
                        totalContactos = rs1.getInt("cnt");
                    }
                }
            }

            // b) Actualizar contactos_reseteados en tabla emprendedores
            String updateSql = 
              "UPDATE emprendedores SET contactos_reseteados = ? WHERE id = ?";
            try (PreparedStatement ps2 = conn.prepareStatement(updateSql)) {
                ps2.setInt(1, totalContactos);
                ps2.setInt(2, emprendedorId);
                ps2.executeUpdate();
            }
        }
    } catch (Exception e) {
        e.printStackTrace(new java.io.PrintWriter(out));
    }

    // 4) Redirigir a la JSP de ver publicaciones
    if (redirectTo != null && !redirectTo.trim().isEmpty()) {
        String sep = redirectTo.contains("?") ? "&" : "?";
        response.sendRedirect(redirectTo + sep + "id=" + emprendedorId);
    } else {
        response.sendRedirect("panel_mentor.jsp");
    }
%>
