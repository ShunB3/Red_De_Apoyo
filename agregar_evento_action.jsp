<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    Integer adminId = (Integer) session.getAttribute("adminId");
    if (adminId == null) {
        response.sendRedirect("Login_admin.jsp");
        return;
    }

    String titulo      = request.getParameter("title");
    String descripcion = request.getParameter("description");
    String inicio      = request.getParameter("start");
    String fin         = request.getParameter("end");

    String dbUrl  = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser = "root", dbPass = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
             PreparedStatement ps = conn.prepareStatement(
               "INSERT INTO eventos (titulo, descripcion, inicio, fin, creado_por) VALUES (?, ?, ?, ?, ?)"
             )) {
            ps.setString(1, titulo);
            ps.setString(2, descripcion);
            ps.setString(3, inicio);
            if (fin == null || fin.isEmpty()) ps.setNull(4, Types.TIMESTAMP);
            else ps.setString(4, fin);
            ps.setInt(5, adminId);
            ps.executeUpdate();
        }
        response.sendRedirect("calendario_admin.jsp");
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p style='color:red;text-align:center;'>Error: "+e.getMessage()+"</p>");
        out.println("<p style='text-align:center;'><a href='calendario_admin.jsp'>← Volver</a></p>");
    }
%>