<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    Integer adminId = (Integer) session.getAttribute("adminId");
    if (adminId == null) {
        response.sendRedirect("Login_admin.jsp");
        return;
    }

    request.setCharacterEncoding("UTF-8");
    String id = request.getParameter("id");
    String titulo = request.getParameter("titulo");
    String url = request.getParameter("url");

    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/red_de_apoyo", "root", "");
         PreparedStatement ps = conn.prepareStatement("UPDATE cursos_capacitacion SET titulo = ?, url = ? WHERE id = ?")) {
        ps.setString(1, titulo);
        ps.setString(2, url);
        ps.setString(3, id);
        ps.executeUpdate();
        response.sendRedirect("capacitaciones_ad.jsp");
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    }
%>