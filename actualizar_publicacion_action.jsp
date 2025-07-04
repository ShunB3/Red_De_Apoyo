<%@ page import="java.io.*, java.sql.*, java.util.*, org.apache.commons.fileupload.*, org.apache.commons.fileupload.disk.*, org.apache.commons.fileupload.servlet.*" %>
<%
request.setCharacterEncoding("UTF-8");
String dbUrl = "jdbc:mysql://localhost:3306/red_de_apoyo";
String dbUser = "root", dbPass = "";
String titulo = null, descripcion = null, imagenUrl = null;
int postId = 0, emprendedorId = 0;
String nuevoArchivoUrl = null;

boolean isMultipart = ServletFileUpload.isMultipartContent(request);
if (isMultipart) {
    DiskFileItemFactory factory = new DiskFileItemFactory();
    ServletFileUpload upload = new ServletFileUpload(factory);
    List<FileItem> items = upload.parseRequest(request);
    for (FileItem item : items) {
        if (item.isFormField()) {
            String name = item.getFieldName();
            String value = item.getString("UTF-8");
            if ("id".equals(name)) postId = Integer.parseInt(value);
            else if ("emprendedor_id".equals(name)) emprendedorId = Integer.parseInt(value);
            else if ("titulo".equals(name)) titulo = value;
            else if ("descripcion".equals(name)) descripcion = value;
            else if ("imagen_url".equals(name)) imagenUrl = value;
        } else if ("archivo".equals(item.getFieldName()) && item.getSize() > 0) {
            String fileName = new File(item.getName()).getName();
            String ext = fileName.substring(fileName.lastIndexOf('.')+1).toLowerCase();
            String carpeta = null;
            if (ext.matches("jpg|jpeg|png|gif|bmp|webp")) carpeta = "Img";
            else if (ext.matches("mp4|avi|mov|wmv|webm|mkv")) carpeta = "Mp4";
            if (carpeta != null) {
                String basePath = application.getRealPath("/") + carpeta + File.separator;
                String finalFileName = fileName;
                File uploadedFile = new File(basePath + finalFileName);
                // Si el archivo existe, añade sufijo de timestamp
                if (uploadedFile.exists()) {
                    String name = fileName;
                    String ext2 = "";
                    int dot = fileName.lastIndexOf('.');
                    if (dot > 0) {
                        name = fileName.substring(0, dot);
                        ext2 = fileName.substring(dot);
                    }
                    finalFileName = name + "_" + (new java.util.Date().getTime()) + ext2;
                    uploadedFile = new File(basePath + finalFileName);
                }
                item.write(uploadedFile);
                nuevoArchivoUrl = carpeta + "/" + finalFileName;
            }
        }
    }
}
if (nuevoArchivoUrl != null) imagenUrl = nuevoArchivoUrl;

try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass)) {
    String sql = "UPDATE publicaciones SET titulo=?, descripcion=?, imagen_url=? WHERE id=? AND emprendedor_id=?";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, titulo);
        ps.setString(2, descripcion);
        ps.setString(3, imagenUrl);
        ps.setInt(4, postId);
        ps.setInt(5, emprendedorId);
        ps.executeUpdate();
    }
}
response.sendRedirect("emprendedor_home.jsp");
%>