<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Registro de Mentor</title>
  <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
  <style>
    /* ===== Tema oscuro & reset básico ===== */
    body {
      font-family: 'Segoe UI', sans-serif;
      background-color: #121212;
      color: #e0e0e0;
      margin: 0; padding: 0;
      display: flex; flex-direction: column;
      min-height: 100vh;
    }
    header {
      background-color: #1e1e1e;
      padding: 1.2rem;
      text-align: center;
      box-shadow: 0 2px 8px rgba(0,0,0,0.3);
    }
    header h1 {
      margin: 0;
      font-size: 2rem;
    }
    main {
      flex: 1;
      display: flex; justify-content: center; align-items: center;
      padding: 2rem;
    }

    /* ===== Formulario ===== */
    form {
      background-color: #1f1f1f;
      padding: 2rem;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.5);
      width: 100%; max-width: 400px;
    }
    form label {
      display: block;
      margin-top: 1rem;
      font-weight: bold;
    }
    form input, form textarea {
      width: 100%;
      padding: 0.6rem;
      margin-top: 0.4rem;
      background-color: #2a2a2a;
      border: 1px solid #444;
      border-radius: 4px;
      color: #e0e0e0;
    }
    form textarea { resize: vertical; }

    /* ===== Medidor de fuerza ===== */
    .strength-meter {
      height: 6px; border-radius: 3px;
      background: #444; margin-top: 0.5rem;
      overflow: hidden;
    }
    .strength-meter-fill {
      height: 100%; width: 0;
      background: red;
      transition: width 0.3s ease, background 0.3s ease;
    }
    .strength-text {
      margin-top: 0.3rem; font-size: 0.85rem; color: #ccc;
    }
    .strength-text.weak   { color: #e74c3c; }
    .strength-text.medium { color: #f39c12; }
    .strength-text.strong { color: #2ecc71; }

    /* ===== Requisitos de contraseña ===== */
    .pwd-requisitos {
      margin-top: 0.5rem;
      font-size: 0.9rem;
      color: #ccc;
    }
    .pwd-requisitos p {
      margin: 0;
      font-weight: bold;
      color: #e0e0e0;
    }
    .pwd-requisitos ul {
      margin: 0.25rem 0 0 1.2rem;
      padding: 0;
      list-style: none;
    }
    .pwd-requisitos li {
      margin-bottom: 0.25rem;
      display: flex; align-items: center;
    }
    .req-icon {
      display: inline-block;
      width: 1em; text-align: center;
      margin-right: 0.5em;
      color: #e74c3c;
      transition: color 0.3s;
    }
    .pwd-requisitos li.metido .req-icon {
      color: #2ecc71;
    }
    .pwd-requisitos li.metido {
      color: #ccc;
    }
    .pwd-requisitos li.no-metido {
      color: #888;
    }

    /* ===== Checkbox inline ===== */
    .terms {
      margin-top: 1rem; font-size: 0.9rem;
    }
    .terms label {
      display: inline-flex; align-items: center;
      cursor: pointer; user-select: none;
      color: #e0e0e0;
    }
    .terms input[type=checkbox] {
      margin-right: 0.5rem;
    }
    .terms a {
      color: #00c1c1; text-decoration: none;
      margin-left: 0.25rem;
    }
    .terms a:hover {
      text-decoration: underline;
    }

    /* ===== Botón ===== */
    .btn {
      background-color: #008891; color: #fff;
      padding: 0.75rem; border: none;
      border-radius: 4px;
      cursor: pointer; width: 100%;
      margin-top: 1.5rem;
      font-size: 1rem; font-weight: bold;
      transition: background-color 0.3s ease;
    }
    .btn:disabled {
      background-color: #555;
      cursor: not-allowed; opacity: 0.6;
    }
    .btn:hover:enabled {
      background-color: #006f78;
    }

    form a.login-link {
      display: block; margin-top: 1rem;
      text-align: center; color: #00c1c1;
      text-decoration: none;
    }
    form a.login-link:hover {
      text-decoration: underline;
    }

    /* ===== Footer ===== */
    footer {
      background-color: #1e1e1e;
      text-align: center; padding: 1rem;
      color: #888;
    }

    /* ===== Modal de T&C ===== */
    .modal {
      display: none;
      position: fixed;
      top: 0; left: 0;
      width: 100%; height: 100%;
      background: rgba(0,0,0,0.7);
      justify-content: center; align-items: center;
      padding: 1rem; box-sizing: border-box;
    }
    .modal-content {
      background: #1f1f1f;
      max-width: 600px; width: 100%;
      max-height: 80%; overflow-y: auto;
      padding: 1.5rem; border-radius: 6px;
      position: relative;
    }
    .modal-content h2 {
      margin-top: 0;
      border-bottom: 2px solid #00a5a5;
      padding-bottom: 0.5rem;
    }
    .modal-content p {
      margin-bottom: 1rem; line-height: 1.5; color: #ccc;
      font-size: 0.95rem;
    }
    .modal-close {
      position: absolute; top: .5rem; right: .75rem;
      background: none; border: none;
      font-size: 1.5rem; color: #888; cursor: pointer;
    }
    .modal-close:hover {
      color: #fff;
    }
  </style>
</head>
<body>

<header>
  <h1>Registro de Mentor</h1>
</header>

<main>
  <form action="registro_mentor_action.jsp" method="post" id="regForm">
    <label for="nombre">Nombre:</label>
    <input type="text" name="nombre" id="nombre" required>

    <label for="email">Correo electrónico:</label>
    <input type="email" name="email" id="email" required>

    <label for="password">Contraseña:</label>
    <input type="password" name="password" id="password" required>

    <!-- Medidor -->
    <div class="strength-meter" id="strengthMeter">
      <div class="strength-meter-fill" id="strengthFill"></div>
    </div>
    <div class="strength-text" id="strengthText">Introduce una contraseña</div>

    <!-- Requisitos -->
    <div class="pwd-requisitos">
     
      <ul>
        <li id="req-length"  class="no-metido"><span class="req-icon">✖</span> Al menos <strong>8 caracteres</strong></li>
        <li id="req-upper"   class="no-metido"><span class="req-icon">✖</span> Contener <strong>una letra mayúscula</strong></li>
        <li id="req-special" class="no-metido"><span class="req-icon">✖</span> Contener <strong>un carácter especial</strong> (p. ej. !@#$%)</li>
      </ul>
    </div>

    <label for="especialidad">Especialidad:</label>
    <input type="text" name="especialidad" id="especialidad" required>

    <label for="experiencia">Experiencia:</label>
    <textarea name="experiencia" id="experiencia" rows="3" required></textarea>

    <label for="tarifa">Tarifa:</label>
    <input type="text" name="tarifa" id="tarifa" required>

    <div class="terms">
      <label>
        <input type="checkbox" id="acceptTerms">
        Acepto los
        <a href="#" id="openTerms">Términos y Condiciones</a>
      </label>
    </div>

    <button class="btn" type="submit" id="submitBtn" disabled>Registrarse</button>
    <a href="Login_mentor.jsp" class="login-link">Ya tengo cuenta</a>
  </form>
</main>

<footer>
  <p>&copy; 2025 Red de Apoyo a Emprendedores</p>
</footer>

<!-- Modal de Términos y Condiciones -->
<div class="modal" id="termsModal">
  <div class="modal-content">
    <button class="modal-close" id="closeTerms">&times;</button>
    <h2>Términos y Condiciones</h2>
    <p><strong>1. Objeto:</strong> Estos términos regulan el uso de nuestros servicios de mentoría online.</p>
    <p><strong>2. Registro:</strong> El mentor garantiza que la información proporcionada es veraz y actualizada.</p>
    <p><strong>3. Confidencialidad:</strong> Ambas partes acuerdan mantener la confidencialidad de la información compartida.</p>
    <p><strong>4. Responsabilidad:</strong> El mentor se compromete a ofrecer orientación profesional, pero no garantiza resultados específicos.</p>
    <p><strong>5. Protección de datos:</strong> Cumplimos con la normativa de protección de datos personales y no compartiremos tu información con terceros sin tu consentimiento.</p>
    <p><strong>6. Terminación:</strong> Podrás cancelar tu cuenta en cualquier momento. Podremos suspenderla si incumples estos términos.</p>
    <p><strong>7. Legislación aplicable:</strong> Estos términos se rigen por la legislación local vigente.</p>
    <p>Al hacer clic en “Registrarse” aceptas estos términos en su totalidad.</p>
  </div>
</div>

<script>
  const pwd       = document.getElementById('password');
  const meterFill = document.getElementById('strengthFill');
  const meterText = document.getElementById('strengthText');
  const submitBtn = document.getElementById('submitBtn');
  const termsChk  = document.getElementById('acceptTerms');

  pwd.addEventListener('input', updateStrength);
  termsChk.addEventListener('change', updateButtonState);

  function updateStrength() {
    const val = pwd.value;
    const okLen     = val.length >= 8;
    const okUpper   = /[A-Z]/.test(val);
    const okSpecial = /[^A-Za-z0-9]/.test(val);

    toggleRequirement('req-length',  okLen);
    toggleRequirement('req-upper',   okUpper);
    toggleRequirement('req-special', okSpecial);

    let score = okLen + okUpper + okSpecial;
    switch (score) {
      case 0:
        meterFill.style.width = '0%';   meterFill.style.background = 'red';
        meterText.textContent = 'Muy débil'; meterText.className = 'strength-text weak';
        break;
      case 1:
        meterFill.style.width = '33%';  meterFill.style.background = 'red';
        meterText.textContent = 'Débil'; meterText.className = 'strength-text weak';
        break;
      case 2:
        meterFill.style.width = '66%';  meterFill.style.background = 'orange';
        meterText.textContent = 'Mediana'; meterText.className = 'strength-text medium';
        break;
      case 3:
        meterFill.style.width = '100%'; meterFill.style.background = 'green';
        meterText.textContent = 'Fuerte'; meterText.className = 'strength-text strong';
        break;
    }
    updateButtonState();
  }

  function toggleRequirement(id, met) {
    const li = document.getElementById(id);
    if (met) {
      li.classList.add('metido');
      li.classList.remove('no-metido');
    } else {
      li.classList.add('no-metido');
      li.classList.remove('metido');
    }
  }

  function updateButtonState() {
    const strong = meterFill.style.width === '100%';
    submitBtn.disabled = !(strong && termsChk.checked);
  }

  // Modal Términos
  const modal    = document.getElementById('termsModal');
  const openBtn  = document.getElementById('openTerms');
  const closeBtn = document.getElementById('closeTerms');

  openBtn.addEventListener('click', e => {
    e.preventDefault();
    modal.style.display = 'flex';
  });
  closeBtn.addEventListener('click', () => modal.style.display = 'none');
  window.addEventListener('click', e => {
    if (e.target === modal) modal.style.display = 'none';
  });
</script>

</body>
</html>
