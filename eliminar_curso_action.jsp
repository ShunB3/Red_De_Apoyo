<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    Integer adminId = (Integer) session.getAttribute("adminId");
    if (adminId == null) {
        response.sendRedirect("Login_admin.jsp");
        return;
    }

    String id = request.getParameter("id");

    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/red_de_apoyo", "root", "");
         PreparedStatement ps = conn.prepareStatement("DELETE FROM cursos_capacitacion WHERE id = ?")) {
        ps.setString(1, id);
        ps.executeUpdate();
        response.sendRedirect("capacitaciones_ad.jsp");
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    }
%>