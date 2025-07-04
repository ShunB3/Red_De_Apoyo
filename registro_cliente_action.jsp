<%@ page import="java.sql.*" %>
<%
    String nombre   = request.getParameter("nombre");
    String email    = request.getParameter("email");
    String password = request.getParameter("password");

    // Validación servidor de la contraseña
    boolean okLen  = password != null && password.length() >= 8;
    boolean okUC   = password != null && password.matches(".*[A-Z].*");
    boolean okSpec= password != null && password.matches(".*[^A-Za-z0-9].*");
    if (!okLen || !okUC || !okSpec) {
        out.println("<p style='color:red;'>La contraseña debe tener al menos 8 caracteres, incluir una mayúscula y un carácter especial.</p>");
        return;
    }

    String url = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String user = "root";
    String pass = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(url, user, pass)) {
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO clientes (nombre, email, password) VALUES (?, ?, ?)"
            );
            ps.setString(1, nombre);
            ps.setString(2, email);
            // idealmente aquí hachearías la contraseña con bcrypt antes de guardarla
            ps.setString(3, password);
            ps.executeUpdate();
        }
        response.sendRedirect("Login_cliente.jsp");
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error al registrar cliente: " + e.getMessage() + "</p>");
    }
%>
