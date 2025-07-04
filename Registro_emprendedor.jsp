<!-- Registro_emprendedor.jsp -->
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Registro de Emprendedor</title>
  <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
  <style>
    /* ===== RESET Y ESTILOS BÁSICOS ===== */
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    body {
      background: #121212;
      color: #e0e0e0;
      font-family: 'Segoe UI', Arial, sans-serif;
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
    }
    .form-container {
      background: #1f1f1f;
      padding: 2rem 2.5rem;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.5);
      width: 100%;
      max-width: 500px;
    }
    h2 {
      text-align: center;
      margin-bottom: 1.5rem;
      color: #1abc9c;
      font-size: 1.8rem;
    }
    .form-group {
      margin-bottom: 1rem;
    }
    .form-group label {
      display: block;
      margin-bottom: 0.3rem;
      font-weight: 500;
      color: #ccc;
    }
    .form-group input,
    .form-group select,
    .form-group textarea {
      width: 100%;
      padding: 0.5rem 0.75rem;
      background: #2a2a2a;
      border: 1px solid #444;
      border-radius: 4px;
      color: #e0e0e0;
      font-size: 1rem;
      outline: none;
      transition: border 0.2s;
    }
    .form-group input:focus,
    .form-group select:focus,
    .form-group textarea:focus {
      border-color: #1abc9c;
      box-shadow: 0 0 0 3px rgba(26, 188, 156, 0.15);
    }

    /* Lista de requisitos de contraseña */
    .password-requirements {
      list-style: none;
      margin-top: 0.5rem;
      padding-left: 1rem;
      color: #ccc;
      font-size: 0.9rem;
    }
    .password-requirements li {
      margin-bottom: 0.3rem;
      display: flex;
      align-items: center;
    }
    .password-requirements li .icon {
      display: inline-block;
      width: 1rem;
      text-align: center;
      margin-right: 0.5rem;
      font-weight: bold;
    }
    .icon.invalid {
      color: #e74c3c; /* rojo */
    }
    .icon.valid {
      color: #2ecc71; /* verde */
    }

    /* Checkbox de términos */
    .terms-container {
      margin-top: 1rem;
      display: flex;
      align-items: flex-start;
      gap: 0.5rem;
    }
    .terms-container input {
      margin-top: 0.2rem;
    }
    .terms-text {
      font-size: 0.9rem;
      line-height: 1.4;
      margin-top: 0.5rem;
      padding: 0.8rem;
      background: #2a2a2a;
      border: 1px solid #444;
      border-radius: 4px;
      max-height: 200px;
      overflow-y: auto;
    }

    .btn-submit {
      width: 100%;
      padding: 0.75rem;
      background: #1abc9c;
      color: white;
      border: none;
      border-radius: 4px;
      font-size: 1rem;
      font-weight: 600;
      cursor: pointer;
      transition: background 0.3s ease;
      margin-top: 1rem;
    }
    .btn-submit:disabled {
      background: #555;
      cursor: not-allowed;
    }
    .btn-submit:hover:enabled {
      background: #16a085;
    }

    .back-link {
      display: block;
      text-align: center;
      margin-top: 1rem;
      color: #888;
      font-size: 0.9rem;
      text-decoration: none;
    }
    .back-link:hover {
      color: #ccc;
    }
  </style>
</head>
<body>

  <div class="form-container">
    <h2>Registrar Emprendedor</h2>
    <form id="registroForm" action="registro_emprendedor_action.jsp" method="post">
      <!-- Nombre completo -->
      <div class="form-group">
        <label for="nombre">Nombre completo:</label>
        <input type="text" id="nombre" name="nombre" required>
      </div>

      <!-- Correo electrónico -->
      <div class="form-group">
        <label for="email">Correo electrónico:</label>
        <input type="email" id="email" name="email" required>
      </div>

      <!-- Contraseña con requisitos dinámicos -->
      <div class="form-group">
        <label for="password">Contraseña:</label>
        <input
          type="password"
          id="password"
          name="password"
          required
          minlength="8"
          title="8+ caracteres, al menos una mayúscula, una minúscula, un dígito y un carácter especial (!@#$%^&*)"
        >
        <!-- Lista de requisitos -->
        <ul class="password-requirements" id="pwd-requirements">
          <li id="req-length">
            <span class="icon invalid" id="icon-length">✖</span>
            Mínimo 8 caracteres
          </li>
          <li id="req-lower">
            <span class="icon invalid" id="icon-lower">✖</span>
            Al menos una letra minúscula
          </li>
          <li id="req-upper">
            <span class="icon invalid" id="icon-upper">✖</span>
            Al menos una letra mayúscula
          </li>
          <li id="req-digit">
            <span class="icon invalid" id="icon-digit">✖</span>
            Al menos un dígito
          </li>
          <li id="req-special">
            <span class="icon invalid" id="icon-special">✖</span>
            Al menos un carácter especial (!@#$%^&*)
          </li>
        </ul>
      </div>

      <!-- Nombre del negocio -->
      <div class="form-group">
        <label for="negocio">Nombre de tu negocio:</label>
        <input type="text" id="negocio" name="negocio" required>
      </div>

      <!-- Categoría -->
      <div class="form-group">
        <label for="categoria">Categoría:</label>
        <select id="categoria" name="categoria" required>
          <option value="">-- Selecciona una categoría --</option>
          <option value="Alimentos">Alimentos</option>
          <option value="Artesanía">Artesanía</option>
          <option value="Arte">Arte</option>
          <option value="Belleza">Belleza</option>
          <option value="Café">Café</option>
          <option value ="Construcción">Construcción</option>
          <option value="Deportes">Deportes</option>
          <option value="Educación">Educación</option>
          <option value="Flores">Flores</option>
          <option value="Hogar">Hogar</option>
          <option value="Moda">Moda</option>
          <option value="Salud">Salud</option>
          <option value="Servicios">Servicios</option>
          <option value="Tecnología">Tecnología</option>
        </select>
      </div>

      <!-- Dirección física -->
      <div class="form-group">
        <label for="direccion">Dirección de tu local:</label>
        <input type="text" id="direccion" name="direccion" placeholder="Av. Principal #123" required>
      </div>


      <!-- Departamento -->
      <div class="form-group">
        <label for="departamento">Departamento:</label>
        <select id="departamento" name="departamento" required>
          <option value="">-- Selecciona un departamento --</option>
            <option value="Antioquia">Antioquia</option>
            <option value="Atlántico">Atlántico</option>
            <option value="Bolívar">Bolívar</option>
            <option value="Bogotá D.C.">Bogotá D.C.</option>
            <option value="Boyacá">Boyacá</option>
            <option value="Caldas">Caldas</option>
            <option value="Cauca">Cauca</option>
            <option value="Cundinamarca">Cundinamarca</option>
            <option value="Huila">Huila</option>
            <option value="Magdalena">Magdalena</option>
            <option value="Meta">Meta</option>
            <option value="Nariño">Nariño</option>
            <option value="Norte de Santander">Norte de Santander</option>
            <option value="Quindío">Quindío</option>
            <option value="Risaralda">Risaralda</option>
            <option value="Santander">Santander</option>
            <option value="Tolima">Tolima</option>
            <option value="Valle del Cauca">Valle del Cauca</option>

          <!-- … añade el resto de departamentos … -->
        </select>
      </div>

      <!-- Ciudad (se llena dinámicamente) -->
      <div class="form-group">
        <label for="ciudad">Ciudad:</label>
        <select id="ciudad" name="ciudad" required>
          <option value="">Primero elige un departamento</option>
        </select>
      </div>

      <!-- Teléfono -->
      <div class="form-group">
        <label for="telefono">Teléfono:</label>
        <input type="tel" id="telefono" name="telefono" placeholder="+57 300 1234567" required>
      </div>

      <!-- Descripción -->
      <div class="form-group">
        <label for="descripcion">Descripción breve de tu emprendimiento:</label>
        <textarea id="descripcion" name="descripcion" rows="3"></textarea>
      </div>
  <!-- Redes Sociales -->
      <div class="form-group">
        <label for="instagram">Link Instagram:</label>
        <input type="url" id="instagram" name="instagram" placeholder="https://instagram.com/tu_usuario">
      </div>
      <div class="form-group">
        <label for="facebook">Link Facebook:</label>
        <input type="url" id="facebook" name="facebook" placeholder="https://facebook.com/tu_pagina">
      </div>
      <div class="form-group">
        <label for="tiktok">Link TikTok:</label>
        <input type="url" id="tiktok" name="tiktok" placeholder="https://tiktok.com/@tu_usuario">
      </div>
      <!-- Acepto Términos y Condiciones -->
      <div class="terms-container">
        <input type="checkbox" id="acepto" name="acepto" required>
        <label for="acepto">Acepto los <a href="#terminos" style="color:#1abc9c; text-decoration:underline;">Términos y Condiciones</a></label>
      </div>

      <!-- Texto de Términos y Condiciones (sólo lectura) -->
      <div class="terms-text" id="terminos">
<p><strong>Términos y Condiciones</strong></p>
<p>Bienvenido a la plataforma Red de Apoyo a Emprendedores Locales (“nosotros”, “la plataforma”). Al registrarte como emprendedor aceptas cumplir con los siguientes términos y condiciones:</p>
<ol style="margin-left:1rem; margin-bottom:0.5rem;">
  <li><strong>Objeto:</strong> La plataforma conecta mentores con emprendedores. Tú, como emprendedor, te comprometes a proporcionar información veraz sobre tu negocio y a utilizar los servicios de asesoría de buena fe.</li>
  <li><strong>Responsabilidad de Contenido:</strong> Eres responsable de toda la información que subas (texto, imágenes, videos). No se permite contenido ilegal, difamatorio, obsceno o que infrinja derechos de terceros.</li>
  <li><strong>Protección de Datos:</strong> Los datos personales que nos proporciones serán tratados conforme a nuestra Política de Privacidad. Nos comprometemos a no compartir tu información con terceros sin tu consentimiento, salvo requerimientos legales.</li>
  <li><strong>Conducta:</strong> No se tolerará ningún tipo de acoso, discriminación o comportamiento abusivo. El incumplimiento de esta norma podrá derivar en la suspensión o eliminación de tu cuenta.</li>
  <li><strong>Terminación:</strong> Puedes solicitar la eliminación de tu cuenta en cualquier momento. La plataforma se reserva el derecho de suspender o cancelar tu cuenta si detecta cualquier violación a estos Términos y Condiciones.</li>
  <li><strong>Modificaciones:</strong> Podremos modificar estos Términos y Condiciones en cualquier momento. Te notificaremos con antelación razonable. El uso continuado tras cambios implica tu aceptación.</li>
  <li><strong>Jurisdicción:</strong> Estos términos se rigen por las leyes del país donde opera la plataforma. Cualquier controversia será resuelta ante tribunales competentes de esa jurisdicción.</li>
</ol>
      </div>

      <button type="submit" id="btn-submit" class="btn-submit" disabled>Registrarme</button>
    </form>

    <a href="Login_emprendedor.jsp" class="back-link">← Ya tengo cuenta</a>
  </div>

  <script>
    // Mapeo departamentos → ciudades (10 ciudades por departamento)
   const ciudadesPorDepartamento = {
  "Antioquia": [
    "Medellín", "Envigado", "Bello", "Itagüí", "Rionegro", "Sabaneta", "La Estrella", "Copacabana", "Apartadó", "Turbo"
  ],
  "Atlántico": [
    "Barranquilla", "Soledad", "Malambo", "Sabanalarga", "Galapa", "Baranoa", "Puerto Colombia", "Santo Tomás", "Palmar de Varela", "Campo de la Cruz"
  ],
  "Bolívar": [
    "Cartagena", "Magangué", "Turbaco", "Arjona", "El Carmen de Bolívar", "San Juan Nepomuceno", "Santa Rosa", "Mompox", "María La Baja", "Clemencia"
  ],
  "Bogotá D.C.": [
    "Bogotá"
  ],
  "Boyacá": [
    "Tunja", "Duitama", "Sogamoso", "Chiquinquirá", "Paipa", "Villa de Leyva", "Moniquirá", "Samacá", "Tibasosa", "Soatá"
  ],
  "Caldas": [
    "Manizales", "Villamaría", "Chinchiná", "La Dorada", "Riosucio", "Anserma", "Salamina", "Neira", "Supía", "Pensilvania"
  ],
  "Cauca": [
    "Popayán", "Santander de Quilichao", "Puerto Tejada", "Patía", "El Tambo", "Guapi", "Piendamó", "Inzá", "Mercaderes", "Timbío"
  ],
  "Cundinamarca": [
    "Soacha", "Chía", "Fusagasugá", "Girardot", "Zipaquirá", "Facatativá", "Madrid", "Mosquera", "Cajicá", "La Calera"
  ],
  "Huila": [
    "Neiva", "Pitalito", "Garzón", "La Plata", "Campoalegre", "Algeciras", "Yaguará", "San Agustín", "Isnos", "Rivera"
  ],
  "Magdalena": [
    "Santa Marta", "Ciénaga", "Fundación", "El Banco", "Plato", "Pivijay", "Aracataca", "Zona Bananera", "Sitionuevo", "Puebloviejo"
  ],
  "Meta": [
    "Villavicencio", "Acacías", "Granada", "Puerto López", "Cumaral", "San Martín", "Restrepo", "Puerto Gaitán", "Guamal", "Castilla La Nueva"
  ],
  "Nariño": [
    "Pasto", "Tumaco", "Ipiales", "Túquerres", "Sandoná", "La Unión", "Samaniego", "El Charco", "Barbacoas", "Cumbal"
  ],
  "Norte de Santander": [
    "Cúcuta", "Ocaña", "Pamplona", "Villa del Rosario", "Los Patios", "El Zulia", "Tibú", "Ábrego", "Chinácota", "Sardinata"
  ],
  "Quindío": [
    "Armenia", "Calarcá", "Montenegro", "La Tebaida", "Quimbaya", "Circasia", "Filandia", "Salento", "Pijao", "Buenavista"
  ],
  "Risaralda": [
    "Pereira", "Dosquebradas", "La Virginia", "Santa Rosa de Cabal", "Belén de Umbría", "Marsella", "Quinchía", "Apía", "Mistrató", "Guática"
  ],
  "Santander": [
    "Bucaramanga", "Floridablanca", "Piedecuesta", "Girón", "Barrancabermeja", "San Gil", "Socorro", "Lebrija", "Rionegro"
  ],
  "Tolima": [
    "Ibagué", "Espinal", "Melgar", "Honda", "Líbano", "Chaparral", "Mariquita", "Guamo", "Flandes", "Purificación"
  ],
  "Valle del Cauca": [
    "Cali", "Palmira", "Buenaventura", "Jamundí", "Tuluá", "Buga", "Cartago", "Yumbo", "Candelaria", "Sevilla"
  ]
};


    document.addEventListener('DOMContentLoaded', () => {
      const departamentoSelect = document.getElementById('departamento');
      const ciudadSelect       = document.getElementById('ciudad');

      // Cada vez que cambia el departamento, actualizamos lista de ciudades:
      departamentoSelect.addEventListener('change', () => {
        const depto = departamentoSelect.value;
        // Primero limpiamos el <select> de ciudad:
        ciudadSelect.innerHTML = '<option value="">-- Selecciona una ciudad --</option>';

        if (ciudadesPorDepartamento[depto]) {
          ciudadesPorDepartamento[depto].forEach(ciudad => {
            const option = document.createElement('option');
            option.value = ciudad;
            option.textContent = ciudad;
            ciudadSelect.appendChild(option);
          });
          ciudadSelect.disabled = false;
        } else {
          // Si no hay ciudades definidas para ese departamento:
          const opt = document.createElement('option');
          opt.value = "";
          opt.textContent = "Sin datos de ciudades";
          ciudadSelect.appendChild(opt);
          ciudadSelect.disabled = true;
        }
      });

      // -------- LÓGICA DE CONTRASEÑA Y TÉRMINOS --------
      const pwdInput       = document.getElementById('password');
      const btnSubmit      = document.getElementById('btn-submit');
      const checkboxAcepto = document.getElementById('acepto');

      // Íconos de requisitos
      const iconLength  = document.getElementById('icon-length');
      const iconLower   = document.getElementById('icon-lower');
      const iconUpper   = document.getElementById('icon-upper');
      const iconDigit   = document.getElementById('icon-digit');
      const iconSpecial = document.getElementById('icon-special');

      function compruebaRequisitos() {
        const pwd = pwdInput.value;

        const okLength  = pwd.length >= 8;
        const okLower   = /[a-z]/.test(pwd);
        const okUpper   = /[A-Z]/.test(pwd);
        const okDigit   = /\d/.test(pwd);
        const okSpecial = /[!@#$%^&*]/.test(pwd);

        toggleIcon(iconLength, okLength);
        toggleIcon(iconLower, okLower);
        toggleIcon(iconUpper, okUpper);
        toggleIcon(iconDigit, okDigit);
        toggleIcon(iconSpecial, okSpecial);

        const todosOk = okLength && okLower && okUpper && okDigit && okSpecial && checkboxAcepto.checked;
        btnSubmit.disabled = !todosOk;
      }

      function toggleIcon(element, isValid) {
        if (isValid) {
          element.textContent   = '✓';
          element.classList.remove('invalid');
          element.classList.add('valid');
        } else {
          element.textContent   = '✖';
          element.classList.remove('valid');
          element.classList.add('invalid');
        }
      }

      pwdInput.addEventListener('input', compruebaRequisitos);
      checkboxAcepto.addEventListener('change', compruebaRequisitos);
    });
  </script>

</body>
</html>
