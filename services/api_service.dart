import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Android/emulador: 10.0.2.2
  static const String _mobileBaseUrl = 'http://10.0.2.2:3000/api';

  // Web/Chrome/cualquier navegador: se conecta directo a localhost
  static const String _webBaseUrl = 'http://localhost:3000/api';

  static String get baseUrl => kIsWeb ? _webBaseUrl : _mobileBaseUrl;

  /// Obtiene el token guardado para peticiones autenticadas
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Headers con autorización Bearer
  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        final usuario = data['usuario'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setInt('userId', usuario['id_usuario']);
        await prefs.setString('userNombre', usuario['nombre']);
        await prefs.setString('userApellido', usuario['apellido']);
        await prefs.setString('userEmail', usuario['correo']);

        return {'success': true};
      }
      return {'success': false, 'error': data['error'] ?? 'Error en login'};
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión'};
    }
  }

  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': userData['nombre'],
          'apellido': userData['apellido'],
          'correo': userData['correo'],
          'password': userData['password'],
        }),
      );

      final data = jsonDecode(response.body);
      return {'success': data['success'] == true, 'error': data['error']};
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión'};
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': email}),
      );
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] == true,
        'mensaje':
            data['mensaje'] ??
            (data['success'] == true
                ? 'Se ha enviado una nueva contraseña a tu correo'
                : data['error']),
      };
    } catch (e) {
      return {'success': false, 'mensaje': 'Error de conexión'};
    }
  }

  /// Actualizar nombre y apellido del perfil (requiere token)
  static Future<Map<String, dynamic>> updatePerfil(
    String nombre,
    String apellido,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      if (userId == null) return {'success': false, 'error': 'No hay sesión'};

      final response = await http.put(
        Uri.parse('$baseUrl/auth/perfil'),
        headers: await _authHeaders(),
        body: jsonEncode({'nombre': nombre, 'apellido': apellido}),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        await prefs.setString('userNombre', nombre);
        await prefs.setString('userApellido', apellido);
        return {'success': true};
      }
      return {
        'success': false,
        'error': data['error'] ?? 'Error al actualizar',
      };
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión'};
    }
  }

  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'nombre': prefs.getString('userNombre') ?? '',
      'apellido': prefs.getString('userApellido') ?? '',
      'email': prefs.getString('userEmail') ?? '',
    };
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // --- CÁLCULOS ---
  static Future<Map<String, dynamic>> getHistorialCalculos({
    String? tipo,
    String? desde,
    String? hasta,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/calculos/historial');
      if (tipo != null && tipo.isNotEmpty && tipo.toLowerCase() != 'todos') {
        uri = uri.replace(queryParameters: {'tipo': tipo});
      }
      if (desde != null && desde.isNotEmpty) {
        final params = Map<String, String>.from(uri.queryParameters)
          ..['desde'] = desde;
        uri = uri.replace(queryParameters: params);
      }
      if (hasta != null && hasta.isNotEmpty) {
        final params = Map<String, String>.from(uri.queryParameters)
          ..['hasta'] = hasta;
        uri = uri.replace(queryParameters: params);
      }

      final response = await http.get(uri, headers: await _authHeaders());
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'data': data['data'] ?? []};
      }
      return {'success': false, 'data': []};
    } catch (e) {
      return {'success': false, 'data': []};
    }
  }

  static Future<Map<String, dynamic>> guardarCalculo({
    required int idTipoInteres,
    required double capitalInicial,
    required double tasaInteres,
    required String periodoTipo,
    required int tiempoValor,
    required String fechaInicio,
    required String fechaFin,
    required double resultadoFinal,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/calculos/guardar'),
        headers: await _authHeaders(),
        body: jsonEncode({
          'id_tipo_interes': idTipoInteres,
          'capital_inicial': capitalInicial,
          'tasa_interes': tasaInteres,
          'periodo_tipo': periodoTipo,
          'tiempo_valor': tiempoValor,
          'fecha_inicio': fechaInicio,
          'fecha_fin': fechaFin,
          'resultado_final': resultadoFinal,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión'};
    }
  }

  // --- METAS JUBILACIÓN ---
  static Future<Map<String, dynamic>> getMetaJubilacion() async {
    try {
      final userId = await getUserId();
      if (userId == null) return {'success': false};

      final response = await http.get(
        Uri.parse('$baseUrl/metas/$userId'),
        headers: await _authHeaders(),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'data': null};
    } catch (e) {
      return {'success': false, 'data': null};
    }
  }

  static Future<Map<String, dynamic>> updateMetaJubilacion(
    double montoActual,
  ) async {
    try {
      final userId = await getUserId();
      if (userId == null) return {'success': false};

      final response = await http.put(
        Uri.parse('$baseUrl/metas/$userId'),
        headers: await _authHeaders(),
        body: jsonEncode({'monto_actual': montoActual}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false};
    }
  }

  // --- CONFIGURACIÓN (tema, notificaciones) ---
  static Future<Map<String, dynamic>> getConfiguracion() async {
    try {
      final userId = await getUserId();
      if (userId == null) return {'success': false};

      final response = await http.get(
        Uri.parse('$baseUrl/configuracion/$userId'),
        headers: await _authHeaders(),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false};
    } catch (e) {
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> updateConfiguracion({
    String? tema,
    bool? notificacionesActivas,
  }) async {
    try {
      final userId = await getUserId();
      if (userId == null) return {'success': false};

      final body = <String, dynamic>{};
      if (tema != null) body['tema'] = tema;
      if (notificacionesActivas != null)
        body['notificaciones_activas'] = notificacionesActivas;

      final response = await http.put(
        Uri.parse('$baseUrl/configuracion/$userId'),
        headers: await _authHeaders(),
        body: jsonEncode(body),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false};
    }
  }

  // --- CAMBIAR CONTRASEÑA ---
  static Future<Map<String, dynamic>> changePassword(
    String passwordActual,
    String passwordNueva,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/cambiar-contrasena'),
        headers: await _authHeaders(),
        body: jsonEncode({
          'passwordActual': passwordActual,
          'passwordNueva': passwordNueva,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true};
      }

      return {
        'success': false,
        'error': data['error'] ?? 'Error al cambiar la contraseña',
      };
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión'};
    }
  }
}
