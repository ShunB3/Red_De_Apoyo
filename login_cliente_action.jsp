<%@ page import="java.sql.*" %>
<%
    String email    = request.getParameter("usuario");
    String password = request.getParameter("contrasena");

    String url = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String user = "root";
    String pass = "";

    boolean autenticado = false;
    int clienteId = 0;
    String nombre = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(url, user, pass);

        PreparedStatement ps = conn.prepareStatement(
            "SELECT id, nombre FROM clientes WHERE email = ? AND password = ?"
        );
        ps.setString(1, email);
        ps.setString(2, password);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            autenticado = true;
            clienteId = rs.getInt("id");
            nombre = rs.getString("nombre");
        }

        rs.close();
        ps.close();
        conn.close();
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    }

    if (autenticado) {
        session.setAttribute("userId", clienteId);
        session.setAttribute("usuario", nombre);
        session.setAttribute("rol", "cliente");
        response.sendRedirect("cliente_home.jsp");
    } else {
        // Si las credenciales son incorrectas, redirigir con parámetro de error
        response.sendRedirect("Login_cliente.jsp?error=true");
    }
%>
