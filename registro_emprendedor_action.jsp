<%@ page import="java.sql.*" %>
<%
    String nombre     = request.getParameter("nombre");
    String email      = request.getParameter("email");
    String password   = request.getParameter("password");
    String negocio    = request.getParameter("negocio");
    String telefono   = request.getParameter("telefono");
    String descripcion= request.getParameter("descripcion");

    String url  = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String usr  = "root";
    String pwd  = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(url, usr, pwd);
             PreparedStatement ps = conn.prepareStatement(
                 "INSERT INTO emprendedores (nombre, email, password, negocio, telefono, descripcion) VALUES (?, ?, ?, ?, ?)"
             )) {
            ps.setString(1, nombre);
            ps.setString(2, email);
            ps.setString(3, password);
            ps.setString(4, negocio);
            ps.setString(5, telefono);
            ps.setString(6, descripcion);
            ps.executeUpdate();
        }
        response.sendRedirect("Login_emprendedor.jsp");
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p style='color:red;'>Error al registrar emprendedor: " + e.getMessage() + "</p>");
    }
%>
