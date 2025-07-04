<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Emprendedor</title>
      <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">

    <style>
        /* Estilos base del sitio */
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            background-color: #121212;
            margin: 0;
            padding: 0;
            color: #ffffff;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        header {
            background-color: #1a1a1a;
            padding: 20px 0;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.5);
        }

        header h1 {
            font-size: 2.2rem;
            color: #ffffff;
            margin: 0;
            padding: 0 20px;
        }

        main {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 2rem 1rem;
        }

        h2 {
            font-size: 1.8rem;
            margin-bottom: 1.5rem;
            color: #e0e0e0;
            text-align: center;
            position: relative;
            padding-bottom: 10px;
        }

        h2:after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 60px;
            height: 3px;
            background-color: #00a5a5;
        }

        form {
            background-color: #1f1f1f;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.5);
            width: 100%;
            max-width: 400px;
            display: flex;
            flex-direction: column;
        }

        label {
            margin-bottom: 0.5rem;
            color: #e0e0e0;
            font-weight: 500;
        }

        input {
            padding: 12px;
            margin-bottom: 1.5rem;
            border: none;
            border-radius: 4px;
            background-color: #333;
            color: #fff;
            font-size: 1rem;
            transition: background-color 0.3s;
        }

        input:focus {
            outline: none;
            background-color: #444;
            box-shadow: 0 0 0 2px rgba(0, 165, 165, 0.5);
        }

        .btn {
            display: inline-block;
            padding: 12px 25px;
            background-color: #00a5a5;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            font-weight: 500;
            transition: background-color 0.3s;
            border: none;
            cursor: pointer;
            font-size: 16px;
            text-align: center;
            margin-bottom: 1rem;
        }

        .btn:hover {
            background-color: #008080;
        }

        a {
            color: #00a5a5;
            text-decoration: none;
            margin: 0.5rem 0;
            text-align: center;
            transition: color 0.2s;
        }

        a:hover {
            color: #00e6e6;
            text-decoration: underline;
        }

        footer {
            text-align: center;
            padding: 20px;
            background-color: #1a1a1a;
            box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.3);
        }

        footer p {
            margin: 0;
            color: #888;
        }

        /* Estilo para los enlaces de navegación */
        .links-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            margin-top: 0.5rem;
        }

        /* Modal de Error */
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
            background-color: #00a5a5;
            color: white;
            border: none;
            padding: 0.5rem 1.5rem;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1rem;
            transition: background-color 0.3s;
        }

        .modal button:hover {
            background-color: #008080;
        }

        /* Responsive */
        @media (max-width: 500px) {
            form {
                padding: 1.5rem;
            }

            header h1 {
                font-size: 1.8rem;
            }

            h2 {
                font-size: 1.5rem;
            }
        }
    </style>
</head>
<body>
    <header>
        <h1>Red de Apoyo a Emprendedores Locales</h1>
    </header>

    <main>
        <h2>Iniciar Sesión como Emprendedor</h2>
        <form action="login_emprendedor_action.jsp" method="post" id="loginForm">
            <label for="usuario">Correo electrónico</label>
            <input type="email" id="usuario" name="usuario" required placeholder="ejemplo@correo.com">
            
            <label for="contrasena">Contraseña</label>
            <input type="password" id="contrasena" name="contrasena" required placeholder="Tu contraseña">
            
            <button type="submit" class="btn">Continuar</button>
            
            <div class="links-container">
                <a href="seleccionar_rol.jsp">Volver a selección de rol</a>
                <a href="Registro_emprendedor.jsp">¿No tienes cuenta? Regístrate</a>
            </div>
        </form>
    </main>

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

    <footer>
        <p>&copy; 2025 Red de Apoyo a Emprendedores</p>
    </footer>
</body>
</html>