<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Login Admin</title>
             <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">

    <style>
        body {
            background-color: #121212;
            color: #e0e0e0;
            font-family: 'Segoe UI', sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }

        form {
            background-color: #1f1f1f;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 0 15px rgba(0,0,0,0.4);
            width: 100%;
            max-width: 400px;
        }

        h2 {
            text-align: center;
            margin-bottom: 1rem;
        }

        label {
            display: block;
            margin-top: 1rem;
        }

        input {
            width: 100%;
            padding: 0.5rem;
            margin-top: 0.3rem;
            background-color: #2a2a2a;
            border: 1px solid #444;
            border-radius: 4px;
            color: #e0e0e0;
        }

        .btn {
            margin-top: 1.5rem;
            width: 100%;
            padding: 0.75rem;
            background-color: #008891;
            border: none;
            border-radius: 4px;
            color: white;
            font-weight: bold;
            cursor: pointer;
        }

        .btn:hover {
            background-color: #006f78;
        }

        .link {
            text-align: center;
            margin-top: 1rem;
            display: block;
            color: #00d1d1;
            text-decoration: none;
        }

        .link:hover {
            text-decoration: underline;
        }

        /* Estilos para el Modal de Error */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }

        .modal-content {
            background-color: #1f1f1f;
            padding: 2rem;
            border-radius: 8px;
            text-align: center;
            max-width: 400px;
            width: 90%;
            position: relative;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
        }

        .modal h3 {
            color: #dc3545;
            margin-top: 0;
            margin-bottom: 1rem;
        }

        .modal p {
            color: #e0e0e0;
            margin-bottom: 1.5rem;
        }

        .modal button {
            background-color: #008891;
            color: white;
            border: none;
            padding: 0.5rem 1.5rem;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1rem;
            transition: background-color 0.3s;
        }

        .modal button:hover {
            background-color: #006f78;
        }
    </style>
</head>
<body>
    <form action="login_admin_action.jsp" method="post">
        <h2>Administrador - Iniciar Sesión</h2>
        <label for="email">Correo:</label>
        <input type="email" id="email" name="email" required>

        <label for="password">Contraseña:</label>
        <input type="password" id="password" name="password" required>

        <button class="btn" type="submit">Ingresar</button>
        <a href="registro_admin.jsp" class="link">¿No tienes cuenta? Regístrate</a>
    </form>

    <!-- Modal de Error -->
    <div id="errorModal" class="modal">
        <div class="modal-content">
            <h3>Error de Inicio de Sesión</h3>
            <p>El correo electrónico o la contraseña son incorrectos.</p>
            <button onclick="closeModal()">Aceptar</button>
        </div>
    </div>

    <script>
        // Verificar si hay un parámetro de error en la URL
        const urlParams = new URLSearchParams(window.location.search);
        const error = urlParams.get('error');
        
        if (error === 'true') {
            document.getElementById('errorModal').style.display = 'flex';
        }

        function closeModal() {
            document.getElementById('errorModal').style.display = 'none';
            // Limpiar el parámetro de error de la URL
            window.history.replaceState({}, document.title, window.location.pathname);
        }
    </script>
</body>
</html>
