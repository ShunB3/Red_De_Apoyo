<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Registro Cliente</title>
  <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">

  <style>
    /* ===== Reset y tema oscuro ===== */
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

    /* ===== Formulario ===== */
    form {
      background-color: #1f1f1f;
      padding: 2rem;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.5);
      width: 100%;
      max-width: 400px;
    }
    form label {
      display: block;
      margin-top: 1rem;
      font-weight: bold;
    }
    form input {
      width: 100%;
      padding: 0.6rem;
      margin-top: 0.4rem;
      background-color: #2a2a2a;
      border: 1px solid #444;
      border-radius: 4px;
      color: #e0e0e0;
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
    .btn:hover {
      background-color: #006f78;
    }
    form a {
      display: block;
      margin-top: 1rem;
      text-align: center;
      color: #00c1c1;
      text-decoration: none;
    }
    form a:hover {
      text-decoration: underline;
    }
    footer {
      background-color: #1e1e1e;
      text-align: center;
      padding: 1rem;
      color: #888;
    }

    /* ===== Estilos para el medidor de fuerza ===== */
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
    /* Añadir estos estilos */
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
      display: flex;
      align-items: center;
      margin-top: 0;
      font-size: 0.95rem;
    }
    .terms a {
      margin: 0 0 0 4px;
      display: inline;
    }
          /* Estilos para los requisitos de contraseña */
          .pwd-requisitos {
            margin-top: 1rem;
            background-color: #2a2a2a;
            padding: 1rem;
            border-radius: 4px;
          }
          .pwd-requisitos ul {
            list-style: none;
            padding: 0;
            margin: 0;
          }
          .pwd-requisitos li {
            margin: 0.5rem 0;
            color: #e0e0e0;
            display: flex;
            align-items: center;
          }
          .req-icon {
            margin-right: 8px;
            color: #e74c3c;
          }
          .no-metido .req-icon {
            color: #e74c3c;
          }
          .metido .req-icon {
            color: #2ecc71;
          }
          .pwd-requisitos strong {
            color: #00c1c1;
          }
    /* Estilos para el modal */
    .modal {
      display: none;
      position: fixed;
      z-index: 1000;
      left: 0;
      top: 0;
      width: 100%;
      height: 100%;
      background-color: rgba(0,0,0,0.7);
    }
    .modal-content {
      background-color: #1f1f1f;
      margin: 5% auto;
      padding: 2rem;
      border-radius: 8px;
      width: 80%;
      max-width: 700px;
      max-height: 80vh;
      overflow-y: auto;
      color: #e0e0e0;
      box-shadow: 0 4px 12px rgba(0,0,0,0.5);
    }
    .close-modal {
      color: #888;
      float: right;
      font-size: 1.5rem;
      cursor: pointer;
    }
    .close-modal:hover {
      color: #fff;
    }
    .modal-content h2 {
      color: #00c1c1;
      margin-top: 0;
    }
    .modal-content p {
      margin: 1rem 0;
      line-height: 1.6;
    }
  </style>
</head>
<body>
    <header>
        <h1>Registro de Cliente</h1>
    </header>

    <main>
        <form action="registro_cliente_action.jsp" method="post" id="regForm">
            <label for="nombre">Nombre:</label>
            <input type="text" name="nombre" id="nombre" required>

            <label for="email">Correo electrónico:</label>
            <input type="email" name="email" id="email" required>

            <label for="password">Contraseña:</label>
            <input type="password" name="password" id="password" required>

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

            <div class="terms">
                <label>
                    <input type="checkbox" id="acceptTerms" required>
                    Acepto los <a href="#" id="openTerms">Términos y Condiciones</a>
                </label>
            </div>

            <button class="btn" type="submit" id="submitBtn" disabled>Registrarse</button>
            <a href="Login_cliente.jsp">Ya tengo cuenta</a>
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
            
            <h3>1. Aceptación de los Términos</h3>
            <p>Al registrarte en Red de Apoyo a Emprendedores, aceptas estos términos y condiciones en su totalidad.</p>

            <h3>2. Uso del Servicio</h3>
            <p>Nuestro servicio está diseñado para conectar emprendedores con mentores y clientes. Te comprometes a usar el servicio de manera ética y legal.</p>

            <h3>3. Registro y Cuenta</h3>
            <p>- Debes proporcionar información precisa y completa durante el registro.<br>
            - Eres responsable de mantener la seguridad de tu cuenta.<br>
            - No debes compartir tu cuenta con terceros.</p>

            <h3>4. Privacidad</h3>
            <p>Protegemos tu información personal según nuestra política de privacidad. Al registrarte, aceptas nuestras prácticas de manejo de datos.</p>

            <h3>5. Contenido</h3>
            <p>- No debes publicar contenido ilegal, ofensivo o fraudulento.<br>
            - Respetamos los derechos de propiedad intelectual.<br>
            - Nos reservamos el derecho de eliminar contenido inapropiado.</p>

            <h3>6. Limitación de Responsabilidad</h3>
            <p>No nos hacemos responsables por pérdidas o daños derivados del uso de nuestro servicio.</p>

           </div>
    </div>

    <script>
    const pwd       = document.getElementById('password');
    const meterFill = document.getElementById('strengthFill');
    const meterText = document.getElementById('strengthText');
    const submitBtn = document.getElementById('submitBtn');

    pwd.addEventListener('input', updateStrength);
    function updateStrength() {
      const val = pwd.value;
      let score = 0;
      if (val.length >= 8)       score++;
      if (/[A-Z]/.test(val))     score++;
      if (/[^A-Za-z0-9]/.test(val)) score++;

      switch (score) {
        case 0:
          meterFill.style.width = '0%';   meterFill.style.background = 'red';
          meterText.textContent = 'Muy débil';
          meterText.className = 'strength-text weak';
          submitBtn.disabled = true;
          break;
        case 1:
          meterFill.style.width = '33%';  meterFill.style.background = 'red';
          meterText.textContent = 'Débil';
          meterText.className = 'strength-text weak';
          submitBtn.disabled = true;
          break;
        case 2:
          meterFill.style.width = '66%';  meterFill.style.background = 'orange';
          meterText.textContent = 'Mediana';
          meterText.className = 'strength-text medium';
          submitBtn.disabled = true;
          break;
        case 3:
          meterFill.style.width = '100%'; meterFill.style.background = 'green';
          meterText.textContent = 'Fuerte';
          meterText.className = 'strength-text strong';
          submitBtn.disabled = false;
          break;
      }
    }
    // Modal de Términos y Condiciones
    const modal = document.getElementById('termsModal');
    const openTermsBtn = document.getElementById('openTerms');
    const closeModal = document.getElementById('closeModal');
    const acceptTerms = document.getElementById('acceptTerms');

    openTermsBtn.onclick = function(e) {
        e.preventDefault();
        modal.style.display = 'block';
    }

    closeModal.onclick = function() {
        modal.style.display = 'none';
    }

    window.onclick = function(e) {
        if (e.target == modal) {
            modal.style.display = 'none';
        }
    }

    // Actualizar el script existente para incluir la verificación de términos
    acceptTerms.addEventListener('change', function() {
        if (this.checked && meterText.textContent === 'Fuerte') {
            submitBtn.disabled = false;
        } else {
            submitBtn.disabled = true;
        }
    });
    </script>
</body>
</html>
