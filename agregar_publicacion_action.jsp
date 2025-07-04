<%@ page import="java.io.*,java.util.*,javax.servlet.*,javax.servlet.http.*,javax.servlet.annotation.*,org.apache.commons.fileupload.*,org.apache.commons.fileupload.disk.*,org.apache.commons.fileupload.servlet.*,org.apache.commons.io.FilenameUtils,java.sql.*" %>
<%
request.setCharacterEncoding("UTF-8");
String titulo = null;
String descripcion = null;
String emprendedor_id = null;
String imagen_url = null;
String media_option = null;
String media_file_path = null;
boolean isMultipart = ServletFileUpload.isMultipartContent(request);

if(isMultipart){
    DiskFileItemFactory factory = new DiskFileItemFactory();
    ServletFileUpload upload = new ServletFileUpload(factory);
    List<FileItem> items = upload.parseRequest(request);
    FileItem fileItem = null;
    for(FileItem item : items){
        if(item.isFormField()){
            String fieldName = item.getFieldName();
            String value = item.getString("UTF-8");
            if("titulo".equals(fieldName)) titulo = value;
            else if("descripcion".equals(fieldName)) descripcion = value;
            else if("emprendedor_id".equals(fieldName)) emprendedor_id = value;
            else if("imagen_url".equals(fieldName)) imagen_url = value;
            else if("media_option".equals(fieldName)) media_option = value;
        }else if("media_file".equals(item.getFieldName()) && item.getSize() > 0){
            fileItem = item;
        }
    }
    if("file".equals(media_option) && fileItem != null){
        String fileName = FilenameUtils.getName(fileItem.getName());
        String ext = FilenameUtils.getExtension(fileName).toLowerCase();
        String folder = (ext.equals("mp4")) ? "Mp4" : "Img";
        String uploadPath = application.getRealPath("/" + folder);
        File uploadDir = new File(uploadPath);
        if(!uploadDir.exists()) uploadDir.mkdirs();
        File uploadedFile = new File(uploadDir, fileName);
        // Manejo de duplicados
        if(uploadedFile.exists()){
            String base = FilenameUtils.getBaseName(fileName);
            String newName = base + "_" + (new java.util.Date().getTime()) + "." + ext;
            uploadedFile = new File(uploadDir, newName);
            fileName = newName;
        }
        fileItem.write(uploadedFile);
        media_file_path = folder + "/" + fileName;
    } else if("url".equals(media_option) && imagen_url != null && !imagen_url.trim().isEmpty()){
        media_file_path = imagen_url.trim();
    }
    // Guardar la publicación en la base de datos
    Connection conn = null;
    PreparedStatement ps = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/red_de_apoyo?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC", "root", "");
        String sql = "INSERT INTO publicaciones (titulo, descripcion, imagen_url, emprendedor_id) VALUES (?, ?, ?, ?)";
        ps = conn.prepareStatement(sql);
        ps.setString(1, titulo);
        ps.setString(2, descripcion);
        ps.setString(3, media_file_path); // Aquí va la ruta o URL de la imagen/video
        ps.setString(4, emprendedor_id);
        ps.executeUpdate();
    } catch(Exception e) {
        out.println("<p style='color:red'>Error al guardar la publicación: " + e.getMessage() + "</p>");
        return;
    } finally {
        if(ps != null) try { ps.close(); } catch(Exception ex) {}
        if(conn != null) try { conn.close(); } catch(Exception ex) {}
    }
    response.sendRedirect("emprendedor_home.jsp");
} else {
    response.sendRedirect("agregar_publicacion.jsp?error=1");
}
%>
