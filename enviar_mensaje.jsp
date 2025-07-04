<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    // 1) Solo validar que exista sesión de **algún** usuario (cliente o emprendedor)
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("seleccionar_rol.jsp");
        return;
    }

    // 2) Recoger parámetros
    String cliParam    = request.getParameter("cliente_id");
    String empNombre   = request.getParameter("emprendedor_nombre");
    String negocio     = request.getParameter("negocio");
    String texto       = request.getParameter("mensaje");
    String emisor      = request.getParameter("emisor"); // "cliente" o "emprendedor"

    if (cliParam==null || empNombre==null || negocio==null
        || texto==null || emisor==null) {
        out.println("Faltan parámetros para enviar el mensaje.");
        return;
    }
    int clienteId = Integer.parseInt(cliParam);

    // 3) Insertar en la tabla
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection conn = DriverManager.getConnection(
             "jdbc:mysql://localhost:3306/red_de_apoyo","root",""
         );
         PreparedStatement ps = conn.prepareStatement(
           "INSERT INTO mensajes_chat " +
           "(cliente_id, emprendedor_nombre, negocio, mensaje, emisor) VALUES (?,?,?,?,?)"
         )) {
        ps.setInt(1, clienteId);
        ps.setString(2, empNombre);
        ps.setString(3, negocio);
        ps.setString(4, texto);
        ps.setString(5, emisor);
        ps.executeUpdate();
    }

    // 4) Redirigir de vuelta al chat apropiado según emisor
    String url;
    if ("emprendedor".equals(emisor)) {
        // Volver al JSP de emprendedor
        url = String.format(
          "chat_directo_emprendedor.jsp?" +
          "cliente_id=%d&emprendedor_nombre=%s&negocio=%s",
          clienteId,
          java.net.URLEncoder.encode(empNombre,"UTF-8"),
          java.net.URLEncoder.encode(negocio,"UTF-8")
        );
    } else {
        // Volver al JSP de cliente
        url = String.format(
          "chat_directo.jsp?" +
          "emprendedor_nombre=%s&negocio=%s",
          java.net.URLEncoder.encode(empNombre,"UTF-8"),
          java.net.URLEncoder.encode(negocio,"UTF-8")
        );
    }
    response.sendRedirect(url);
%>
