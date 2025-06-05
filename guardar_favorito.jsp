<%@ page import="java.sql.*" %>
<%
    Integer clienteId     = Integer.parseInt(request.getParameter("cliente_id"));
    Integer publicacionId = Integer.parseInt(request.getParameter("publicacion_id"));

    String dbUrl      = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser     = "root";
    String dbPassword = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
             PreparedStatement ps = conn.prepareStatement(
                 "INSERT IGNORE INTO favoritos (cliente_id, publicacion_id) VALUES (?, ?)"
             )) {
            ps.setInt(1, clienteId);
            ps.setInt(2, publicacionId);
            ps.executeUpdate();
        }

        response.sendRedirect("cliente_home.jsp");
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p style='color:red;'>Error al guardar en favoritos: " + e.getMessage() + "</p>");
    }
%>
