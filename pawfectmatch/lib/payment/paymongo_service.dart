import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaymentService {
  final String _baseUrl = 'https://api.paymongo.com/v1/checkout_sessions';
  final String _secretKey = dotenv.env['PAYMONGO_SECRET_KEY']!;

  Future<Map<String, dynamic>> createCheckoutSession({
    required String description,
    required List<Map<String, dynamic>> lineItems,
    List<String> paymentMethods = const ['gcash', 'paymaya', 'card'],
  }) async {
    final url = Uri.parse(_baseUrl);

    final body = {
      "data": {
        "attributes": {
          // "success_url": "yourapp://success/profile",
          "success_url": "https://marievegillian.github.io/Redirect/",
          "send_email_receipt": false,
          "show_description": true,
          "show_line_items": true,
          "payment_method_types": paymentMethods,
          "description": description,
          "line_items": lineItems,
        }
      }
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode(_secretKey))}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create checkout session: ${response.body}');
    }
  }
}
