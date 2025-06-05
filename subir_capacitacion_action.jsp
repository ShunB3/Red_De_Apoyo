<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    Integer adminId = (Integer) session.getAttribute("adminId");
    if (adminId == null) {
        response.sendRedirect("Login_admin.jsp");
        return;
    }
    String tipo = request.getParameter("tipo");
    String titulo = request.getParameter("titulo");
    String descripcion = request.getParameter("descripcion");
    String url = request.getParameter("url");

    String dbUrl = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser = "root", dbPass = "";

    String sql = "";
    if ("video".equals(tipo)) {
        sql = "INSERT INTO videos_capacitacion (titulo, descripcion, url, fecha_creacion) VALUES (?, ?, ?, NOW())";
    } else if ("curso".equals(tipo)) {
        sql = "INSERT INTO cursos_capacitacion (titulo, url, fecha_creacion) VALUES (?, ?, NOW())";
    } else if ("conferencia".equals(tipo)) {
        sql = "INSERT INTO conferencias_capacitacion (titulo, descripcion, url, fecha_creacion) VALUES (?, ?, ?, NOW())";
    }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, titulo);
            if ("video".equals(tipo) || "conferencia".equals(tipo)) {
                ps.setString(2, descripcion);
                ps.setString(3, url);
            } else if ("curso".equals(tipo)) {
                ps.setString(2, url);
            }
            ps.executeUpdate();
        }
        response.sendRedirect("capacitaciones_ad.jsp");
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p style='color:red;text-align:center;'>Error: "+e.getMessage()+"</p>");
    }
%>