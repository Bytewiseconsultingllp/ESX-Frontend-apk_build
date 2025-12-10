import 'package:flutter_dotenv/flutter_dotenv.dart';

final String authUrl = dotenv.env['AUTH_URL']!;
final String userUrl = dotenv.env['USER_URL']!;
final String productUrl = dotenv.env['PRODUCT_URL']!;
final String orderUrl = dotenv.env['ORDER_URL']!;