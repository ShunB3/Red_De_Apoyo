<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*" %>
<%
    Integer adminId = (Integer) session.getAttribute("adminId");
    String adminName = (String) session.getAttribute("adminName");
    if (adminId == null) {
        response.sendRedirect("Login_admin.jsp");
        return;
    }

    // Parámetros de filtro
    String catFilter = request.getParameter("categoria");
    String deptoFilter = request.getParameter("departamento");
    String ciudadFilter = request.getParameter("ciudad");

    // Construir WHERE dinámico
    List<String> clauses = new ArrayList<>();
    if (catFilter != null && !catFilter.isEmpty()) clauses.add("categoria='"+catFilter+"'");
    if (deptoFilter != null && !deptoFilter.isEmpty()) clauses.add("departamento='"+deptoFilter+"'");
    if (ciudadFilter != null && !ciudadFilter.isEmpty()) clauses.add("ciudad='"+ciudadFilter+"'");
    String where = clauses.isEmpty() ? "" : " WHERE " + String.join(" AND ", clauses);

    // Si descarga CSV
    if ("csv".equals(request.getParameter("download"))) {
        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment;filename=emprendedores.csv");
        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/red_de_apoyo","root","")) {
            Statement st = conn.createStatement();
            ResultSet rs = st.executeQuery("SELECT nombre,email,negocio,categoria,direccion,ciudad,departamento FROM emprendedores" + where);
            out.println("Nombre,Email,Negocio,Categoria,Direccion,Ciudad,Departamento");
            while (rs.next()) {
                out.println(String.format("\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"",
                    rs.getString("nombre"), rs.getString("email"), rs.getString("negocio"),
                    rs.getString("categoria"), rs.getString("direccion"), rs.getString("ciudad"), rs.getString("departamento")
                ));
            }
        }
        return;
    }

    // Consultar emprendedores
    List<Map<String,String>> emprendedores = new ArrayList<>();
    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/red_de_apoyo","root","")) {
        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery("SELECT id,nombre,email,negocio,categoria,direccion,ciudad,departamento FROM emprendedores"+where);
        while (rs.next()) {
            Map<String,String> m = new HashMap<>();
            m.put("id", rs.getString("id"));
            m.put("nombre", rs.getString("nombre"));
            m.put("email", rs.getString("email"));
            m.put("negocio", rs.getString("negocio"));
            m.put("categoria", rs.getString("categoria"));
            m.put("direccion", rs.getString("direccion"));
            m.put("ciudad", rs.getString("ciudad"));
            m.put("departamento", rs.getString("departamento"));
            emprendedores.add(m);
        }
    } catch(Exception e){ e.printStackTrace(new java.io.PrintWriter(out)); }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Panel de Administración – RED DE APOYO</title>
    <link rel="shortcut icon" href="Img/imgEmprender.png" type="image/png">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        :root {
            --primary-color: #008891;
            --primary-dark: #006b73;
            --primary-light: #00a5a8;
            --bg-primary: #0f172a;
            --bg-secondary: #1e293b;
            --text-primary: #f1f5f9;
            --text-secondary: #94a3b8;
            --border-color: #334155;
            --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.2);
            --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.3), 0 2px 4px -2px rgb(0 0 0 / 0.2);
            --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.4), 0 4px 6px -4px rgb(0 0 0 / 0.3);
        }

        body {
            font-family: 'Inter', 'Segoe UI', -apple-system, BlinkMacSystemFont, sans-serif;
            background: var(--bg-primary);
            color: var(--text-primary);
            line-height: 1.6;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        header {
            background: var(--bg-secondary);
            border-bottom: 1px solid var(--border-color);
            box-shadow: var(--shadow-sm);
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .header-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 1.5rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 2rem;
        }

        .header-title {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .header-title h1 {
            font-size: 1.875rem;
            font-weight: 700;
            color: var(--primary-color);
            margin: 0;
        }

        .admin-badge {
            background: linear-gradient(135deg, var(--primary-color), var(--primary-light));
            color: white;
            padding: 0.375rem 0.75rem;
            border-radius: 0.5rem;
            font-size: 0.875rem;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .header-actions {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .main-container {
            flex: 1;
            max-width: 1400px;
            margin: 0 auto;
            padding: 2rem;
            width: 100%;
        }

        .page-header {
            margin-bottom: 2rem;
        }

        .page-title {
            font-size: 2rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
        }

        .page-subtitle {
            color: var(--text-secondary);
            font-size: 1.125rem;
        }

        .filters-card {
            background: var(--bg-secondary);
            border-radius: 1rem;
            padding: 1.5rem;
            margin-bottom: 2rem;
            box-shadow: var(--shadow-md);
            border: 1px solid var(--border-color);
        }

        .filters-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }

        .filters-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--text-primary);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .filters-form {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            align-items: end;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        .form-label {
            font-weight: 500;
            color: var(--text-primary);
            font-size: 0.875rem;
        }

        .form-input,
        .form-select {
            padding: 0.75rem 1rem;
            border: 2px solid var(--border-color);
            border-radius: 0.5rem;
            background: var(--bg-secondary);
            color: var(--text-primary);
            font-size: 0.875rem;
            transition: all 0.2s ease;
        }

        .form-input:focus,
        .form-select:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgb(0 136 145 / 0.3);
        }

        .btn {
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 0.5rem;
            font-weight: 500;
            font-size: 0.875rem;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            text-decoration: none;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary-color), var(--primary-light));
            color: white;
        }

        .btn-primary:hover {
            background: linear-gradient(135deg, var(--primary-dark), var(--primary-color));
            transform: translateY(-1px);
            box-shadow: var(--shadow-md);
        }

        .btn-secondary {
            background: var(--bg-secondary);
            color: var(--text-primary);
            border: 2px solid var(--border-color);
        }

        .btn-secondary:hover {
            background: #475569;
            color: var(--text-primary);
            border-color: var(--primary-color);
        }

        .btn-download {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
        }

        .btn-download:hover {
            background: linear-gradient(135deg, #059669, #047857);
            transform: translateY(-1px);
            box-shadow: var(--shadow-md);
        }

        .btn-logout {
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
        }

        .btn-logout:hover {
            background: linear-gradient(135deg, #dc2626, #b91c1c);
            transform: translateY(-1px);
            box-shadow: var(--shadow-md);
        }

        .data-card {
            background: var(--bg-secondary);
            border-radius: 1rem;
            box-shadow: var(--shadow-md);
            border: 1px solid var(--border-color);
            overflow: hidden;
        }

        .data-header {
            padding: 1.5rem;
            border-bottom: 1px solid var(--border-color);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .data-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--text-primary);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .record-count {
            background: var(--primary-color);
            color: white;
            padding: 0.25rem 0.75rem;
            border-radius: 1rem;
            font-size: 0.875rem;
            font-weight: 500;
        }

        .table-container {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th,
        td {
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid var(--border-color);
        }

        th {
            background: #0f172a;
            font-weight: 600;
            color: var(--text-primary);
            font-size: 0.875rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        td {
            color: var(--text-primary);
            font-size: 0.875rem;
        }

        tbody tr {
            transition: background-color 0.2s ease;
        }

        tbody tr:hover {
            background: #475569;
        }

        .table-cell-id {
            font-weight: 600;
            color: var(--primary-color);
        }

        .table-cell-category {
            background: var(--primary-color);
            color: white;
            padding: 0.25rem 0.75rem;
            border-radius: 1rem;
            font-size: 0.75rem;
            font-weight: 500;
            display: inline-block;
        }

        .empty-state {
            padding: 3rem;
            text-align: center;
            color: var(--text-secondary);
        }

        .empty-state i {
            font-size: 3rem;
            color: var(--primary-color);
            margin-bottom: 1rem;
        }

        footer {
            background: var(--bg-secondary);
            border-top: 1px solid var(--border-color);
            padding: 2rem;
            text-align: center;
            color: var(--text-secondary);
            margin-top: auto;
        }

        @media (max-width: 768px) {
            .header-container {
                flex-direction: column;
                gap: 1rem;
                padding: 1rem;
            }

            .main-container {
                padding: 1rem;
            }

            .filters-form {
                grid-template-columns: 1fr;
            }

            .data-header {
                flex-direction: column;
                gap: 1rem;
                align-items: flex-start;
            }

            .header-actions {
                flex-wrap: wrap;
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <header>
        <div class="header-container">
            <div class="header-title">
                <h1><i class="fas fa-network-wired"></i> RED DE APOYO</h1>
                <div class="admin-badge">
                    <i class="fas fa-user-shield"></i>
                    <span>Administrador</span>
                </div>
            </div>
            <div class="header-actions">
                <form method="get" style="display: inline;">
                    <input type="hidden" name="download" value="csv">
                    <% if(catFilter!=null){ %><input type="hidden" name="categoria" value="<%=catFilter%>"><% } %>
                    <% if(deptoFilter!=null){ %><input type="hidden" name="departamento" value="<%=deptoFilter%>"><% } %>
                    <% if(ciudadFilter!=null){ %><input type="hidden" name="ciudad" value="<%=ciudadFilter%>"><% } %>
                    <button type="submit" class="btn btn-download">
                        <i class="fas fa-download"></i>
                        Exportar CSV
                    </button>
                </form>
                <button class="btn btn-logout" onclick="location.href='admin_home.jsp'">
                    <i class="fas fa-sign-out-alt"></i>
                     Panel
                </button>
            </div>
        </div>
    </header>

    <main class="main-container">
        <div class="page-header">
            <h2 class="page-title">Panel de Administración</h2>
            <p class="page-subtitle">Gestiona y consulta la información de emprendedores registrados</p>
        </div>

        <div class="filters-card">
            <div class="filters-header">
                <h3 class="filters-title">
                    <i class="fas fa-filter"></i>
                    Filtros de Búsqueda
                </h3>
            </div>
            <form method="get" class="filters-form">
                <div class="form-group">
                    <label class="form-label">Categoría</label>
                    <select name="categoria" class="form-select">
                        <option value="">Todas las categorías</option>
                        <option value="Alimentos"<%= "Alimentos".equals(catFilter)?" selected":"" %>>Alimentos</option>
                        <option value="Arte"<%= "Arte".equals(catFilter)?" selected":"" %>>Arte</option>
                        <option value="Artesanía"<%= "Artesanía".equals(catFilter)?" selected":"" %>>Artesanía</option>
                        <option value="Belleza"<%= "Belleza".equals(catFilter)?" selected":"" %>>Belleza</option>
                        <option value="Café"<%= "Café".equals(catFilter)?" selected":"" %>>Café</option>
                        <option value="Construcción"<%= "Construcción".equals(catFilter)?" selected":"" %>>Construcción</option>
                        <option value="Deportes"<%= "Deportes".equals(catFilter)?" selected":"" %>>Deportes</option>
                        <option value="Educación"<%= "Educación".equals(catFilter)?" selected":"" %>>Educación</option>
                        <option value="Flores"<%= "Flores".equals(catFilter)?" selected":"" %>>Flores</option>
                        <option value="Hogar"<%= "Hogar".equals(catFilter)?" selected":"" %>>Hogar</option>
                        <option value="Moda"<%= "Moda".equals(catFilter)?" selected":"" %>>Moda</option>
                        <option value="Salud"<%= "Salud".equals(catFilter)?" selected":"" %>>Salud</option>
                        <option value="Servicios"<%= "Servicios".equals(catFilter)?" selected":"" %>>Servicios</option>
                        <option value="Tecnología"<%= "Tecnología".equals(catFilter)?" selected":"" %>>Tecnología</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Departamento</label>
                    <select name="departamento" class="form-select">
                        <option value="">Todos los departamentos</option>
                        <option value="Antioquia"<%= "Antioquia".equals(deptoFilter)?" selected":"" %>>Antioquia</option>
                        <option value="Atlántico"<%= "Atlántico".equals(deptoFilter)?" selected":"" %>>Atlántico</option>
                        <option value="Bogotá D.C."<%= "Bogotá D.C.".equals(deptoFilter)?" selected":"" %>>Bogotá D.C.</option>
                        <option value="Bolívar"<%= "Bolívar".equals(deptoFilter)?" selected":"" %>>Bolívar</option>
                        <option value="Boyacá"<%= "Boyacá".equals(deptoFilter)?" selected":"" %>>Boyacá</option>
                        <option value="Caldas"<%= "Caldas".equals(deptoFilter)?" selected":"" %>>Caldas</option>
                        <option value="Cauca"<%= "Cauca".equals(deptoFilter)?" selected":"" %>>Cauca</option>
                        <option value="Cundinamarca"<%= "Cundinamarca".equals(deptoFilter)?" selected":"" %>>Cundinamarca</option>
                        <option value="Huila"<%= "Huila".equals(deptoFilter)?" selected":"" %>>Huila</option>
                        <option value="magdalena"<%= "Magdalena".equals(deptoFilter)?" selected":"" %>>Magdalena</option>
                        <option value="Meta"<%= "Meta".equals(deptoFilter)?" selected":"" %>>Meta</option>
                        <option value="Nariño"<%= "Nariño".equals(deptoFilter)?" selected":"" %>>Nariño</option>
                        <option value="Norte de Santander"<%= "Norte de Santander".equals(deptoFilter)?" selected":"" %>>Norte de Santander</option>
                        <option value="Santander"<%= "Santander".equals(deptoFilter)?" selected":"" %>>Santander</option>
                        <option value="Tolima"<%= "Tolima".equals(deptoFilter)?" selected":"" %>>Tolima</option>
                        <option value="Valle del Cauca"<%= "Valle del Cauca".equals(deptoFilter)?" selected":"" %>>Valle del Cauca</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Ciudad</label>
                    <input type="text" name="ciudad" class="form-input" placeholder="Ingresa una ciudad" value="<%= ciudadFilter!=null?ciudadFilter:"" %>">
                </div>
                <div class="form-group">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-search"></i>
                        Buscar
                    </button>
                </div>
            </form>
        </div>

        <div class="data-card">
            <div class="data-header">
                <h3 class="data-title">
                    <i class="fas fa-users"></i>
                    Lista de Emprendedores
                </h3>
                <div class="record-count">
                    <%= emprendedores.size() %> registros
                </div>
            </div>
            <div class="table-container">
                <% if(emprendedores.isEmpty()) { %>
                    <div class="empty-state">
                        <i class="fas fa-inbox"></i>
                        <h3>No se encontraron resultados</h3>
                        <p>No hay emprendedores que coincidan con los filtros seleccionados</p>
                    </div>
                <% } else { %>
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Nombre</th>
                                <th>Email</th>
                                <th>Negocio</th>
                                <th>Categoría</th>
                                <th>Dirección</th>
                                <th>Ciudad</th>
                                <th>Departamento</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for(Map<String,String> e: emprendedores) { %>
                            <tr>
                                <td class="table-cell-id"><%=e.get("id")%></td>
                                <td><%=e.get("nombre")%></td>
                                <td><%=e.get("email")%></td>
                                <td><%=e.get("negocio")%></td>
                                <td>
                                    <span class="table-cell-category"><%=e.get("categoria")%></span>
                                </td>
                                <td><%=e.get("direccion")%></td>
                                <td><%=e.get("ciudad")%></td>
                                <td><%=e.get("departamento")%></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>
        </div>
    </main>

    <footer>
        <p>&copy; 2025 Red de Apoyo a Emprendedores Locales. Todos los derechos reservados.</p>
    </footer>
</body>
</html>