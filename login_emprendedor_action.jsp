<%@ page import="java.sql.*" %>
<%
    String email    = request.getParameter("usuario");
    String password = request.getParameter("contrasena");

    String url  = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String usr  = "root";
    String pwd  = "";

    boolean auth = false;
    int empId    = 0;
    String nombre = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(url, usr, pwd);
             PreparedStatement ps = conn.prepareStatement(
               "SELECT id, nombre FROM emprendedores WHERE email=? AND password=?"
             )) {
            ps.setString(1, email);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    auth   = true;
                    empId  = rs.getInt("id");
                    nombre = rs.getString("nombre");
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    }

    if (auth) {
        session.setAttribute("userId", empId);
        session.setAttribute("usuario", nombre);
        session.setAttribute("rol", "emprendedor");
        response.sendRedirect("emprendedor_home.jsp");
    } else {
        // Si las credenciales son incorrectas, redirigir con parámetro de error
        response.sendRedirect("Login_emprendedor.jsp?error=true");
    }
%>
