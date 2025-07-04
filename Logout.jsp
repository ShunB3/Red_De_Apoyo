<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Invalidar la sesión actual
    javax.servlet.http.HttpSession sesion = request.getSession(false);
    if (sesion != null) {
        sesion.invalidate();
    }
    // Redirigir al inicio
    response.sendRedirect("index.jsp");
%>
