<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    // Validar sesión de emprendedor
    String rol = (String) session.getAttribute("rol");
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null || !"emprendedor".equals(rol)) {
        response.sendRedirect("Login_emprendedor.jsp");
        return;
    }

    // Obtener ID de publicación
    String idParam = request.getParameter("id");
    int postId = (idParam != null) ? Integer.parseInt(idParam) : 0;

    // Variables para rellenar
    String titulo = "", descripcion = "", imagenUrl = "";
    boolean hasUrl = true;

    // Cargar datos de la BD
    if (postId > 0) {
        String dbUrl = "jdbc:mysql://localhost:3306/red_de_apoyo";
        String dbUser = "root", dbPass = "";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            ps = conn.prepareStatement("SELECT titulo, descripcion, imagen_url FROM publicaciones WHERE id = ? AND emprendedor_id = ?");
            ps.setInt(1, postId);
            ps.setInt(2, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                titulo = rs.getString("titulo");
                descripcion = rs.getString("descripcion");
                imagenUrl = rs.getString("imagen_url");
                hasUrl = (imagenUrl != null && !imagenUrl.isEmpty());
            } else {
                response.sendRedirect("emprendedor_home.jsp");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace(new java.io.PrintWriter(out));
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception ex) {}
            if (ps != null) try { ps.close(); } catch (Exception ex) {}
            if (conn != null) try { conn.close(); } catch (Exception ex) {}
        }
    } else {
        response.sendRedirect("emprendedor_home.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Editar Publicación</title>
    <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
  
  <style>
    body {
      background: #181818;
      font-family: 'Segoe UI', Arial, sans-serif;
      margin: 0;
      padding: 0;
      min-height: 100vh;
    }
    form {
      max-width: 480px;
      margin: 2.5rem auto;
      background: #23272f;
      padding: 2rem 2.5rem 1.5rem 2.5rem;
      border-radius: 12px;
      box-shadow: 0 4px 24px rgba(0,0,0,0.18);
      color: #e0e0e0;
    }
    h1 {
      text-align: center;
      color: #00c3c3;
      margin-bottom: 2rem;
      letter-spacing: 1px;
    }
    label {
      display: block;
      margin-top: 1.2rem;
      margin-bottom: 0.3rem;
      font-weight: 500;
      color: #b2fefa;
    }
    input[type="text"], textarea {
      width: 100%;
      padding: 0.7rem;
      background: #2a2a2a;
      border: 1px solid #444;
      border-radius: 5px;
      color: #e0e0e0;
      font-size: 1rem;
      transition: border 0.2s;
      margin-bottom: 0.2rem;
    }
    input[type="text"]:focus, textarea:focus {
      border: 1.5px solid #00c3c3;
      outline: none;
    }
    textarea {
      min-height: 90px;
      resize: vertical;
    }
    .btn-primary, .btn-secondary {
      margin-top: 1.5rem;
      padding: 0.6rem 1.4rem;
      border: none;
      border-radius: 4px;
      font-weight: bold;
      cursor: pointer;
      text-decoration: none;
      font-size: 1rem;
      transition: background 0.2s, color 0.2s, border 0.2s;
      display: inline-block;
    }
    .btn-primary {
      background: linear-gradient(90deg, #00c3c3 0%, #00a5a5 100%);
      color: #fff;
      margin-right: 0.7rem;
      box-shadow: 0 2px 8px rgba(0,195,195,0.08);
    }
    .btn-primary:hover {
      background: linear-gradient(90deg, #00a5a5 0%, #00c3c3 100%);
    }
    .btn-secondary {
      background: transparent;
      color: #00c3c3;
      border: 1.5px solid #00c3c3;
    }
    .btn-secondary:hover {
      background: #00c3c3;
      color: #23272f;
    }
    @media (max-width: 600px) {
      form {
        padding: 1rem;
        max-width: 98vw;
      }
      h1 {
        font-size: 1.3rem;
      }
    }
  </style>
</head>
<body>
  <h1 style="text-align:center; color:#e0e0e0;">Editar Publicación</h1>
 <form action="${pageContext.request.contextPath}/actualizar_publicacion_action.jsp" method="post" enctype="multipart/form-data">
    <input type="hidden" name="id" value="<%= postId %>">
    <input type="hidden" name="emprendedor_id" value="<%= userId %>">

    <label for="titulo">Título:</label>
    <input type="text" id="titulo" name="titulo" value="<%= titulo %>" required>

    <label for="descripcion">Descripción:</label>
    <textarea id="descripcion" name="descripcion" rows="4" required><%= descripcion %></textarea>

    <label>¿Cómo deseas subir la imagen o video?</label>
    <div style="margin-bottom: 1rem;">
      <input type="radio" id="opcion_url" name="opcion" value="url" checked onclick="toggleInput()">
      <label for="opcion_url" style="display:inline;">Usar URL</label>
      <input type="radio" id="opcion_file" name="opcion" value="file" style="margin-left:1.5rem;" onclick="toggleInput()">
      <label for="opcion_file" style="display:inline;">Subir archivo local</label>
    </div>

    <div id="div_url">
      <label for="imagen_url">URL de la imagen:</label>
      <input type="text" id="imagen_url" name="imagen_url" value="<%= imagenUrl %>">
    </div>
    <div id="div_file" style="display:none;">
      <label for="archivo">Selecciona un archivo local (imagen o video):</label>
      <input type="file" id="archivo" name="archivo" accept="image/*,video/*">
    </div>

    <button type="submit" class="btn-primary">Guardar Cambios</button>
    <a href="emprendedor_home.jsp" class="btn-secondary">Cancelar</a>
  </form>
  <script>
    function toggleInput() {
      var urlRadio = document.getElementById('opcion_url');
      var divUrl = document.getElementById('div_url');
      var divFile = document.getElementById('div_file');
      if (urlRadio.checked) {
        divUrl.style.display = '';
        divFile.style.display = 'none';
        document.getElementById('imagen_url').disabled = false;
        document.getElementById('archivo').disabled = true;
      } else {
        divUrl.style.display = 'none';
        divFile.style.display = '';
        document.getElementById('imagen_url').disabled = true;
        document.getElementById('archivo').disabled = false;
      }
    }
    window.onload = function() {
      toggleInput();
    };
  </script>
</body>
</html>