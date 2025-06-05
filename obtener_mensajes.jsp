<%@ page contentType="application/json; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*" %>
<%
    String dbUrl = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser = "root", dbPass = "";

    int clienteId = Integer.parseInt(request.getParameter("cliente_id"));
    int emprendedorId = Integer.parseInt(request.getParameter("emprendedor_id"));

    response.setCharacterEncoding("UTF-8");
    out.print("[");
    boolean first = true;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT remitente_id, mensaje FROM mensajes_chat WHERE cliente_id=? AND emprendedor_id=? ORDER BY fecha ASC"
             )) {
            ps.setInt(1, clienteId);
            ps.setInt(2, emprendedorId);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                if (!first) out.print(",");
                first = false;
                out.print("{\"remitente_id\":" + rs.getInt("remitente_id") + ",");
                out.print("\"mensaje\":\"" + rs.getString("mensaje").replace("\"", "\\\"") + "\"}");
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    out.print("]");
%>
