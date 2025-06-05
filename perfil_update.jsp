<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.io.*" %>
<%
    // Verifica si el usuario está autenticado y tiene el rol correcto
    Integer userId = (Integer) session.getAttribute("userId");
    String rol = (String) session.getAttribute("rol");
    if (userId == null || !"cliente".equals(rol)) {
        response.sendRedirect("Login_cliente.jsp");
        return;
    }

    // Define la carpeta donde se guardarán las imágenes dentro del proyecto web
    String uploadDir = application.getRealPath("/") + File.separator + "perfil";
    File dir = new File(uploadDir);
    if (!dir.exists()) dir.mkdirs(); // Crea la carpeta si no existe

    // Obtiene el archivo subido desde el formulario
    Part filePart = request.getPart("foto"); // El input del formulario debe llamarse "foto"
    String submitted = filePart.getSubmittedFileName();
    
    // Genera un nombre único para el archivo: userId_timestamp.extensión
    String ext = submitted.substring(submitted.lastIndexOf('.'));
    String filename = "u" + userId + "_" + new java.util.Date().getTime() + ext;
    String fullPath = uploadDir + File.separator + filename;
    filePart.write(fullPath); // Guarda el archivo en el servidor

    // Define la ruta relativa para guardar en la base de datos
    String relativePath = "perfil/" + filename;

    // Conexión y actualización en la base de datos
    String dbUrl = "jdbc:mysql://localhost:3306/red_de_apoyo";
    String dbUser = "root";
    String dbPass = "";
    try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
         PreparedStatement ps = conn.prepareStatement(
           "UPDATE clientes SET foto_url = ? WHERE id = ?"
         )) {
        ps.setString(1, relativePath);
        ps.setInt(2, userId);
        ps.executeUpdate();
    } catch (Exception e) {
        e.printStackTrace(new PrintWriter(out)); // Muestra errores en la página si ocurren
    }

    // Redirige al perfil del cliente tras completar la actualización
    response.sendRedirect("perfil_cliente.jsp");
%>