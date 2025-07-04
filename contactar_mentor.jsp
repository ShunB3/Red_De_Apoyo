<%@ page import="java.sql.*" %>
<%
  Integer empId = (Integer) session.getAttribute("userId");
  String rol    = (String) session.getAttribute("rol");
  if (empId == null || !"emprendedor".equals(rol)) {
    response.sendRedirect("Login_emprendedor.jsp");
    return;
  }

  String mentId = request.getParameter("mentor_id");
  if (mentId != null) {
    try (Connection conn = DriverManager.getConnection(
             "jdbc:mysql://localhost:3306/red_de_apoyo","root",""
         );
         PreparedStatement ps = conn.prepareStatement(
           "INSERT INTO contacto_mentor(mentor_id, emprendedor_id) VALUES(?, ?)"
         )) {
      ps.setInt(1, Integer.parseInt(mentId));
      ps.setInt(2, empId);
      ps.executeUpdate();
    } catch(Exception e){
      // opcional: mensaje de error
    }
  }
  response.sendRedirect("mentores.jsp");
%>
