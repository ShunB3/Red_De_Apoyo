<%@ page contentType="application/json; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, java.util.*" %>
<%
    response.setCharacterEncoding("UTF-8");
    String dbUrl  = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser = "root", dbPass = "";

    SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
    List<String> eventos = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
             PreparedStatement ps = conn.prepareStatement(
               "SELECT titulo, descripcion, inicio, fin FROM eventos"
             );
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String title = rs.getString("titulo").replace("\"","\\\"");
                String desc  = rs.getString("descripcion");
                desc = (desc == null ? "" : desc.replace("\"","\\\""));

                Timestamp tsStart = rs.getTimestamp("inicio");
                Timestamp tsEnd   = rs.getTimestamp("fin");

                String start = fmt.format(tsStart);
                String end   = (tsEnd != null) ? fmt.format(tsEnd) : "";

                StringBuilder ev = new StringBuilder();
                ev.append("{");
                ev.append("\"title\":\"").append(title).append("\",");
                ev.append("\"start\":\"").append(start).append("\"");
                if (!end.isEmpty()) {
                    ev.append(",\"end\":\"").append(end).append("\"");
                }
                ev.append(",\"description\":\"").append(desc).append("\"");
                ev.append("}");
                eventos.add(ev.toString());
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    out.print("[" + String.join(",", eventos) + "]");
%>