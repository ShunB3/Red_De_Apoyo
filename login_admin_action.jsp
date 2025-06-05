<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    String email    = request.getParameter("email");
    String password = request.getParameter("password");

    String dbUrl      = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser     = "root";
    String dbPassword = "";

    boolean authenticated = false;
    int adminId = 0;
    String adminName = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT id, nombre FROM admin WHERE email = ? AND password = ?"
             )) {

            ps.setString(1, email);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    authenticated = true;
                    adminId = rs.getInt("id");
                    adminName = rs.getString("nombre");
                }
            }
        }

        if (authenticated) {
            // Crear sesión y redirigir al panel de admin
            session.setAttribute("adminId", adminId);
            session.setAttribute("adminName", adminName);
            response.sendRedirect("admin_home.jsp");
        } else {
            // Si las credenciales son incorrectas, redirigir con parámetro de error
            response.sendRedirect("Login_admin.jsp?error=true");
        }
    } catch (SQLException e) {
        out.println("<p style='color:red; text-align:center;'>Error de base de datos: " 
            + e.getMessage() + "</p>");
    } catch (ClassNotFoundException e) {
        e.printStackTrace();
        out.println("<p style='color:red; text-align:center;'>Error interno del servidor.</p>");
    }
%>
