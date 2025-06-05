<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Registro Emprendedor</title>
    <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">

    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background-color: #121212;
            color: #e0e0e0;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }
        header {
            background-color: #1e1e1e;
            padding: 1.2rem;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
        }
        header h1 {
            font-size: 2rem;
            margin: 0;
        }
        main {
            flex: 1;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 2rem;
        }
        form {
            background-color: #1f1f1f;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.5);
            width: 100%;
            max-width: 450px;
        }
        form label {
            display: block;
            margin-top: 1rem;
            font-weight: bold;
        }
        form input,
        form textarea {
            width: 100%;
            padding: 0.6rem;
            margin-top: 0.4rem;
            background-color: #2a2a2a;
            border: 1px solid #444;
            border-radius: 4px;
            color: #e0e0e0;
        }
        form textarea { resize: vertical; }
        .strength-meter {
            height: 6px;
            border-radius: 3px;
            background: #444;
            margin-top: 0.5rem;
            overflow: hidden;
        }
        .strength-meter-fill {
            height: 100%;
            width: 0;
            background: red;
            transition: width 0.3s ease, background 0.3s ease;
        }
        .strength-text {
            margin-top: 0.3rem;
            font-size: 0.85rem;
            color: #ccc;
        }
        .strength-text.weak   { color: #e74c3c; }
        .strength-text.medium { color: #f39c12; }
        .strength-text.strong { color: #2ecc71; }
        
        /* Estilos para los requisitos de contraseña */
        .pwd-requisitos {
            margin-top: 1rem;
            background-color: #2a2a2a;
            padding: 1.2rem;
            border-radius: 8px;
            border: 1px solid #333;
        }
        .pwd-requisitos ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        .pwd-requisitos li {
            margin: 0.7rem 0;
            display: flex;
            align-items: center;
            color: #e0e0e0;
            font-size: 0.95rem;
        }
        .req-icon {
            margin-right: 10px;
            color: #e74c3c;
            font-size: 1.1rem;
        }
        .no-metido .req-icon {
            color: #e74c3c;
        }
        .metido .req-icon {
            color: #2ecc71;
        }
        .pwd-requisitos strong {
            color: #00c1c1;
            margin: 0 4px;
        }
        .btn {
            background-color: #008891;
            color: #fff;
            padding: 0.75rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            width: 100%;
            margin-top: 1.5rem;
            font-size: 1rem;
            font-weight: bold;
            transition: background-color 0.3s ease;
        }
        .btn:hover { background-color: #006f78; }
        form a {
            display: block;
            margin-top: 1rem;
            text-align: center;
            color: #00c1c1;
            text-decoration: none;
        }
        form a:hover { text-decoration: underline; }

        /* Estilos para términos y condiciones */
        .terms {
            margin-top: 1.5rem;
            display: flex;
            align-items: center;
        }
        .terms input[type="checkbox"] {
            width: auto;
            margin-right: 8px;
        }
        .terms label {
            display: inline-flex;
            align-items: center;
            cursor: pointer;
            user-select: none;
            color: #e0e0e0;
        }
        .terms a {
            color: #00c1c1;
            text-decoration: none;
            margin-left: 0.25rem;
            display: inline;
        }
        .terms a:hover {
            text-decoration: underline;
        }

        /* Modal de Términos y Condiciones */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.85);
            z-index: 1000;
        }
        .modal-content {
            background: #1f1f1f;
            margin: 5% auto;
            padding: 2.5rem;
            width: 90%;
            max-width: 700px;
            max-height: 85vh;
            overflow-y: auto;
            border-radius: 12px;
            position: relative;
            color: #e0e0e0;
            box-shadow: 0 8px 24px rgba(0,0,0,0.5);
        }
        .modal-content::-webkit-scrollbar {
            width: 8px;
        }
        .modal-content::-webkit-scrollbar-track {
            background: #2a2a2a;
            border-radius: 4px;
        }
        .modal-content::-webkit-scrollbar-thumb {
            background: #444;
            border-radius: 4px;
        }
        .modal-content::-webkit-scrollbar-thumb:hover {
            background: #555;
        }
        .close-modal {
            position: absolute;
            right: 1.5rem;
            top: 1.5rem;
            color: #888;
            font-size: 1.75rem;
            cursor: pointer;
            transition: color 0.3s ease;
        }
        .close-modal:hover {
            color: #fff;
        }
        .modal-content h2 {
            color: #00c1c1;
            margin: 0 0 1.5rem 0;
            font-size: 1.8rem;
            padding-bottom: 1rem;
            border-bottom: 2px solid #2a2a2a;
        }
        .modal-content h3 {
            color: #00a5a5;
            margin: 1.5rem 0 1rem 0;
            font-size: 1.3rem;
        }
        .modal-content p {
            margin: 1rem 0;
            line-height: 1.7;
            color: #e0e0e0;
        }
        .modal-content ul {
            list-style-type: none;
            padding-left: 0;
        }
        .modal-content li {
            margin: 0.5rem 0;
            padding-left: 1.5rem;
            position: relative;
        }
        .modal-content li:before {
            content: "•";
            color: #00c1c1;
            position: absolute;
            left: 0;
        }
        .modal-section {
            margin-bottom: 2rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid #2a2a2a;
        }
        .modal-section:last-child {
            border-bottom: none;
        }
    }
    .close-modal:hover {
        color: #fff;
    }
    .modal-content h2 {
        color: #00c1c1;
        margin: 0;
    }
    .modal-content p {
        margin: 1rem 0;
        line-height: 1.6;
    }
    footer {
        background-color: #1e1e1e;
        text-align: center;
        padding: 1rem;
        color: #888;
    }
</style>
</head>
<body>

<header>
    <h1>Registro de Emprendedor</h1>
</header>

<main>
    <form action="registro_emprendedor_action.jsp" method="post" id="regForm">
        <label for="nombre">Nombre:</label>
        <input type="text" name="nombre" id="nombre" required>

        <label for="email">Correo electrónico:</label>
        <input type="email" name="email" id="email" required>

        <label for="password">Contraseña:</label>
        <input type="password" name="password" id="password" required>
        <!-- medidor de fuerza -->
        <div class="strength-meter" id="strengthMeter">
          <div class="strength-meter-fill" id="strengthFill"></div>
        </div>
        <div class="strength-text" id="strengthText">Introduce una contraseña</div>

            <div class="pwd-requisitos">
                <ul>
                    <li id="req-length" class="no-metido"><span class="req-icon">✖</span> Al menos <strong>8 caracteres</strong></li>
                    <li id="req-upper" class="no-metido"><span class="req-icon">✖</span> Contener <strong>una letra mayúscula</strong></li>
                    <li id="req-special" class="no-metido"><span class="req-icon">✖</span> Contener <strong>un carácter especial</strong> (p. ej. !@#$%)</li>
                </ul>
            </div>
        <label for="negocio">Nombre del negocio:</label>
        <input type="text" name="negocio" id="negocio" required>

        <label for="telefono">Teléfono:</label>
        <input type="text" name="telefono" id="telefono" required>

        <label for="descripcion">Descripción:</label>
        <textarea name="descripcion" id="descripcion" rows="3" required></textarea>

        <div class="terms">
            <label>
                <input type="checkbox" id="acceptTerms" required>
                Acepto los <a href="#" id="showTerms">términos y condiciones</a>
            </label>
        </div>

        <button type="submit" class="btn" id="submitBtn" disabled>Registrarse</button>
        <a href="Login_emprendedor.jsp">¿Ya tienes cuenta? Inicia sesión</a>
    </form>
</main>

<footer>
    <p>&copy; 2025 Red de Apoyo a Emprendedores</p>
</footer>

<!-- Modal de Términos y Condiciones -->
<div id="termsModal" class="modal">
    <div class="modal-content">
        <span class="close-modal" id="closeModal">&times;</span>
        <h2>Términos y Condiciones</h2>
        
        <div class="modal-section">
            <h3>1. Aceptación de los Términos</h3>
            <p>Al registrarte en Red de Apoyo a Emprendedores, aceptas estos términos y condiciones en su totalidad. Este acuerdo establece las bases de nuestra relación profesional.</p>
        </div>

        <div class="modal-section">
            <h3>2. Uso del Servicio</h3>
            <p>Nuestro servicio está diseñado para conectar emprendedores con mentores y clientes. Como usuario, te comprometes a:</p>
            <ul>
                <li>Utilizar el servicio de manera ética y profesional</li>
                <li>Mantener interacciones respetuosas con otros usuarios</li>
                <li>No utilizar la plataforma para actividades ilegales</li>
                <li>Respetar la propiedad intelectual de otros usuarios</li>
            </ul>
        </div>

        <div class="modal-section">
            <h3>3. Registro y Cuenta</h3>
            <ul>
                <li>Debes proporcionar información precisa y completa durante el registro</li>
                <li>Eres responsable de mantener la seguridad de tu cuenta</li>
                <li>No debes compartir tu cuenta con terceros</li>
                <li>Debes mantener tu información actualizada</li>
            </ul>
        </div>

        <div class="modal-section">
            <h3>4. Privacidad y Datos</h3>
            <p>Protegemos tu información personal según nuestra política de privacidad. Al registrarte:</p>
            <ul>
                <li>Aceptas nuestras prácticas de manejo de datos</li>
                <li>Autorizas el almacenamiento seguro de tu información</li>
                <li>Entiendes tus derechos sobre tus datos personales</li>
            </ul>
        </div>

        <div class="modal-section">
            <h3>5. Contenido y Conducta</h3>
            <ul>
                <li>No debes publicar contenido ilegal, ofensivo o fraudulento</li>
                <li>Respetamos y protegemos los derechos de propiedad intelectual</li>
                <li>Nos reservamos el derecho de eliminar contenido inapropiado</li>
                <li>Eres responsable del contenido que publicas</li>
            </ul>
        </div>

        <div class="modal-section">
            <h3>6. Limitación de Responsabilidad</h3>
            <p>Red de Apoyo a Emprendedores no se hace responsable por:</p>
            <ul>
                <li>Pérdidas o daños derivados del uso del servicio</li>
                <li>Interrupciones o fallos técnicos del servicio</li>
                <li>Contenido generado por usuarios</li>
                <li>Disputas entre usuarios de la plataforma</li>
            </ul>
        </div>
    </div>
</div>

    <script>
    const pwd = document.getElementById('password');
    const meterFill = document.getElementById('strengthFill');
    const meterText = document.getElementById('strengthText');
    const submitBtn = document.getElementById('submitBtn');
    const acceptTerms = document.getElementById('acceptTerms');
    const modal = document.getElementById('termsModal');
    const showTerms = document.getElementById('showTerms');
    const closeModal = document.getElementById('closeModal');

    // Modal functionality
    showTerms.onclick = function(e) {
        e.preventDefault();
        modal.style.display = "block";
    }

    closeModal.onclick = function() {
        modal.style.display = "none";
    }

    window.onclick = function(e) {
        if (e.target == modal) {
            modal.style.display = "none";
        }
    }

    // Password strength and form validation
    pwd.addEventListener('input', updateStrength);
    acceptTerms.addEventListener('change', validateForm);

    function updateStrength() {
        const val = pwd.value;
        let score = 0;
        if (val.length >= 8) score++;
        if (/[A-Z]/.test(val)) score++;
        if (/[^A-Za-z0-9]/.test(val)) score++;

        switch (score) {
            case 0:
                meterFill.style.width = '0%';   
                meterFill.style.background = 'red';
                meterText.textContent = 'Muy débil';
                meterText.className = 'strength-text weak';
                break;
            case 1:
                meterFill.style.width = '33%';  
                meterFill.style.background = 'red';
                meterText.textContent = 'Débil';
                meterText.className = 'strength-text weak';
                break;
            case 2:
                meterFill.style.width = '66%';  
                meterFill.style.background = 'orange';
                meterText.textContent = 'Mediana';
                meterText.className = 'strength-text medium';
                break;
            case 3:
                meterFill.style.width = '100%'; 
                meterFill.style.background = '#2ecc71';
                meterText.textContent = 'Fuerte';
                meterText.className = 'strength-text strong';
                break;
        }
        validateForm();
    }

    function validateForm() {
        const passwordScore = pwd.value.length >= 8 
            && /[A-Z]/.test(pwd.value) 
            && /[^A-Za-z0-9]/.test(pwd.value);
        submitBtn.disabled = !(passwordScore && acceptTerms.checked);
    }
    </script>
</body>
</html>
