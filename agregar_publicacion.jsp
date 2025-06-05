<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Crear Nueva Publicación</title>
  <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
  <style>
    body {
      font-family: Arial, sans-serif;
      background: #121212;
      color: #e0e0e0;
      margin: 0; padding: 0;
      display: flex; flex-direction: column; min-height: 100vh;
    }
    header {
      background: #1e1e1e; padding: 1rem; text-align: center;
    }
    header h1 { margin: 0; font-size: 1.8rem; }
    main {
      flex: 1; display: flex; justify-content: center; align-items: flex-start;
      padding: 2rem;
    }
    form {
      background: #1f1f1f; padding: 2rem; border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.5);
      width: 100%; max-width: 500px;
      box-sizing: border-box;
    }
    form label {
      display: block; margin-top: 1rem; font-size: 0.95rem;
    }
    form input, form textarea {
      width: 100%; padding: 0.5rem; margin-top: 0.25rem;
      border: 1px solid #333; border-radius: 4px;
      background: #2a2a2a; color: #e0e0e0;
      box-sizing: border-box;
    }
    form textarea { resize: vertical; min-height: 100px; }
    .btn-primary {
      margin-top: 1.5rem;
      display: inline-block;
      background: #00a5a5; color: #fff; padding: 0.75rem 1.25rem;
      border: none; border-radius: 4px; font-weight: bold;
      cursor: pointer; text-decoration: none;
    }
    .btn-primary:hover { background: #008080; }
    .btn-secondary {
      margin-left: 1rem; background: transparent;
      border: 1px solid #00a5a5; color: #00a5a5;
      padding: 0.75rem 1.25rem; border-radius: 4px;
      text-decoration: none;
    }
    .btn-secondary:hover {
      background: #00a5a5; color: #121212;
    }
    footer {
      background: #1e1e1e; text-align: center; padding: 1rem;
    }
  </style>
</head>
<body>
<header>
  <h1>Crear Nueva Publicación</h1>
</header>

<main>
  <form action="agregar_publicacion_action.jsp" method="post" enctype="multipart/form-data">
    <%-- pasa tu ID de emprendedor en un hidden --%>
    <input type="hidden" name="emprendedor_id" value="<%= session.getAttribute("userId") %>">

    <label for="titulo">Título:</label>
    <input type="text" id="titulo" name="titulo" required>

    <label for="descripcion">Descripción:</label>
    <textarea id="descripcion" name="descripcion" required></textarea>

    <label>Método para agregar imagen/video:</label>
    <input type="radio" id="op_url" name="media_option" value="url" checked onclick="toggleMediaOption()">
    <label for="op_url" style="display:inline">URL</label>
    <input type="radio" id="op_file" name="media_option" value="file" onclick="toggleMediaOption()">
    <label for="op_file" style="display:inline">Archivo local</label>

    <div id="url_section">
      <label for="imagen_url">URL de la imagen/video:</label>
      <input type="text" id="imagen_url" name="imagen_url">
    </div>
    <div id="file_section" style="display:none">
      <label for="media_file">Selecciona archivo local:</label>
      <input type="file" id="media_file" name="media_file" accept="image/*,video/*">
    </div>

    <button type="submit" class="btn-primary">Publicar</button>
    <a href="emprendedor_home.jsp" class="btn-secondary">Cancelar</a>
  </form>
</main>

<footer>
  &copy; 2025 Red de Apoyo a Emprendedores Locales
</footer>
</body>
</html>
<script>
function toggleMediaOption() {
  var urlSection = document.getElementById('url_section');
  var fileSection = document.getElementById('file_section');
  if(document.getElementById('op_url').checked) {
    urlSection.style.display = '';
    fileSection.style.display = 'none';
  } else {
    urlSection.style.display = 'none';
    fileSection.style.display = '';
  }
}
</script>
