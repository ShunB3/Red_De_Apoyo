<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    String nombre   = request.getParameter("nombre");
    String email    = request.getParameter("email");
    String password = request.getParameter("password");

    String dbUrl      = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser     = "root";
    String dbPassword = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
             PreparedStatement ps = conn.prepareStatement(
                 "INSERT INTO admin (nombre, email, password) VALUES (?, ?, ?)"
             )) {

            ps.setString(1, nombre);
            ps.setString(2, email);
            ps.setString(3, password);
            ps.executeUpdate();
        }

        // Tras registrar, redirigir al login de admin
        response.sendRedirect("Login_admin.jsp");
    } catch (SQLException e) {
        // Mostrar error sencillo
        out.println("<p style='color:red; text-align:center;'>Error al registrar: " 
            + e.getMessage() + "</p>");
        out.println("<p style='text-align:center;'><a href='registro_admin.jsp' "
            + "style='color:#00d1d1;'>Volver al registro</a></p>");
    } catch (ClassNotFoundException e) {
        e.printStackTrace();
        out.println("<p style='color:red; text-align:center;'>Error interno del servidor.</p>");
    }
%>
