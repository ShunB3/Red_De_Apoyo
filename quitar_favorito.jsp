<%@ page import="java.sql.*" %>
<%
  String favIdParam = request.getParameter("favorito_id");
  if (favIdParam != null) {
    int favId = Integer.parseInt(favIdParam);
    // Lógica para borrar el favorito de la BD...
    try (Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/red_de_apoyo", "root", "" );
         PreparedStatement ps = conn.prepareStatement(
            "DELETE FROM favoritos WHERE id = ?" )
    ) {
      ps.setInt(1, favId);
      ps.executeUpdate();
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  // Al terminar, rediriges de nuevo a cliente_perfil.jsp
  response.sendRedirect("cliente_perfil.jsp");
%>
