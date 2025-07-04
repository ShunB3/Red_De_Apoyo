<%@ page import="java.sql.*" %>
<%
String nombre = request.getParameter("nombre");
String email = request.getParameter("email");
String password = request.getParameter("password");
String especialidad = request.getParameter("especialidad");
String experiencia = request.getParameter("experiencia");
String tarifa = request.getParameter("tarifa"); // Si tienes un campo para tarifa en el formulario

Connection conn = null;
PreparedStatement ps = null;
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/red_de_apoyo", "root", "");
    String sql = "INSERT INTO mentores (nombre, email, password, especialidad, experiencia, tarifa) VALUES (?, ?, ?, ?, ?, ?)";
    ps = conn.prepareStatement(sql);
    ps.setString(1, nombre);
    ps.setString(2, email);
    ps.setString(3, password);
    ps.setString(4, especialidad);
    ps.setString(5, experiencia);
    ps.setString(6, tarifa); // Si no usas tarifa, elimina esta línea y el campo
    ps.executeUpdate();
    response.sendRedirect("Login_mentor.jsp");
} catch(Exception e) {
    out.println("Error: " + e.getMessage());
} finally {
    if(ps != null) try { ps.close(); } catch(Exception e) {}
    if(conn != null) try { conn.close(); } catch(Exception e) {}
}
%>
