<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    // 1) Recuperar parámetros del formulario
    String nombre      = request.getParameter("nombre");
    String email       = request.getParameter("email");
    String password    = request.getParameter("password");
    String negocio     = request.getParameter("negocio");
    String categoria   = request.getParameter("categoria");
    String direccion   = request.getParameter("direccion");
    String ciudad      = request.getParameter("ciudad");
    String departamento= request.getParameter("departamento");
    String telefono    = request.getParameter("telefono");
    String descripcion = request.getParameter("descripcion");

    // 2) Verificar que todos los campos obligatorios existen
    if (   nombre == null       || nombre.trim().isEmpty()
        || email == null        || email.trim().isEmpty()
        || password == null     || password.trim().isEmpty()
        || negocio == null      || negocio.trim().isEmpty()
        || categoria == null    || categoria.trim().isEmpty()
        || direccion == null    || direccion.trim().isEmpty()
        || ciudad == null       || ciudad.trim().isEmpty()
        || departamento == null || departamento.trim().isEmpty()
        || telefono == null     || telefono.trim().isEmpty()
       ) {
        out.println("<p style='color:red; text-align:center;'>Error: Faltan campos obligatorios.</p>");
        out.println("<p style='text-align:center;'><a href='registro_emprendedor.jsp'>← Volver al formulario</a></p>");
        return;
    }

    // 3) VALIDAR contraseña en el servidor con la misma expresión regular:
    //    - Al menos un dígito           (?=.*\\d)
    //    - Al menos una minúscula       (?=.*[a-z])
    //    - Al menos una mayúscula       (?=.*[A-Z])
    //    - Al menos un carácter especial (?=.*[!@#$%^&*])
    //    - Mínimo 8 caracteres           .{8,}
    String pwdPattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*]).{8,}$";
    if (!password.matches(pwdPattern)) {
        out.println("<p style='color:red; text-align:center;'>"
                  + "La contraseña no cumple los requisitos mínimos:<br>"
                  + "8 o más caracteres, al menos una mayúscula, una minúscula, "
                  + "un dígito y un carácter especial (!@#$%^&*)."
                  + "</p>");
        out.println("<p style='text-align:center;'><a href='registro_emprendedor.jsp'>← Volver al formulario</a></p>");
        return;
    }

    // 4) Conexión a la base de datos
    String url  = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String usr  = "root";
    String pwd  = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(url, usr, pwd);
             PreparedStatement ps = conn.prepareStatement(
                 // INSERTAR con las columnas nuevas
                 "INSERT INTO emprendedores "
               + "(nombre, email, password, negocio, categoria, direccion, ciudad, departamento, telefono, descripcion) "
               + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
             )) {
            ps.setString(1, nombre);
            ps.setString(2, email);
            ps.setString(3, password);
            ps.setString(4, negocio);
            ps.setString(5, categoria);
            ps.setString(6, direccion);
            ps.setString(7, ciudad);
            ps.setString(8, departamento);
            ps.setString(9, telefono);
            ps.setString(10, descripcion);

            ps.executeUpdate();
        }

        // 5) Redirigir a Login u otra página de éxito
        response.sendRedirect("Login_emprendedor.jsp");
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p style='color:red; text-align:center;'>Error al registrar emprendedor: "
                    + e.getMessage() + "</p>");
        out.println("<p style='text-align:center;'><a href='registro_emprendedor.jsp'>← Volver</a></p>");
    }
%>
