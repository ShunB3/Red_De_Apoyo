<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Seleccionar Rol</title>
      <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">

    <style>
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

        .header-title {
            font-size: 2.2rem;
            color: #ffffff;
            margin: 0;
            padding: 0 20px;
        }

        .nav-container {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-top: 20px;
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
        }

        .btn:hover {
            background-color: #008080;
        }

        .content {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
            max-width: 1200px;
            margin: 0 auto;
            width: 100%;
        }

        .section {
            margin: 30px 0;
            text-align: center;
            width: 100%;
        }

        h2 {
            font-size: 2rem;
            margin-bottom: 25px;
            color: #ffffff;
        }

        .role-selection {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 15px;
            margin: 30px 0;
        }

        .role-btn {
            width: 250px;
            padding: 14px;
            background-color: #00a5a5;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 500;
            text-decoration: none;
            text-align: center;
            transition: background-color 0.3s;
        }

        .role-btn:hover {
            background-color: #008080;
        }

        .btn-secondary {
            background-color: transparent;
            border: 1px solid #00a5a5;
            color: #00a5a5;
        }

        .btn-secondary:hover {
            background-color: rgba(0, 165, 165, 0.2);
        }

        @media (max-width: 768px) {
            .header-title {
                font-size: 1.8rem;
            }
            
            h2 {
                font-size: 1.6rem;
            }
            
            .role-btn {
                width: 220px;
            }
        }
    </style>
</head>
<body>
    <header>
        <h1 class="header-title">Red de Apoyo a Emprendedores Locales</h1>
        <div class="nav-container">
            <a href="index.jsp" class="role-btn btn-secondary">Volver al inicio</a>
        </div>
    </header>

    <div class="content">
        <div class="section">
            <h2>Selecciona tu tipo de usuario</h2>
            <div class="role-selection">
                <a href="Login_cliente.jsp" class="role-btn">Ingresar como Cliente</a>
                <a href="Login_emprendedor.jsp" class="role-btn">Ingresar como Emprendedor</a>
                <a href="Login_mentor.jsp" class="role-btn">Ingresar como Mentor</a>
            </div>
        </div>
    </div>
</body>
</html>