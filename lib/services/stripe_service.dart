import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  Future<Map<String, dynamic>?> makePayment(double paymentAmount) async {
    try {
      String? result = await createPaymentIntent(
        paymentAmount,
        "gbp",
      );
      if (result == null) return null;
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: result,
          billingDetails: BillingDetails(
            address: Address(
              city: '',
              country: 'GB', // 🇬🇧 United Kingdom ISO code
              line1: '',
              line2: '',
              postalCode: '',
              state: '',
            ),
          ),
          merchantDisplayName: "E-Commerce App",
        ),
      );
      print('Stripe Payment Data is: $result');
      await Stripe.instance.presentPaymentSheet();
      final paymentIntent = await Stripe.instance.retrievePaymentIntent(result);
      print('Payment Successful: ${paymentIntent}');
      return paymentIntent.toJson();
    } catch (e) {
      if (e is StripeException) {
        print("Stripe Exception: ${e.error.localizedMessage}");
      } else {
        print("Payment error: $e");
      }
    }
    return null;
  }

/* <<<<<<<<<<<<<<  ✨ Windsurf Command ⭐ >>>>>>>>>>>>>>>> */
  /// Make an Apple Pay payment
  ///
  /// This method will create a payment intent for an Apple Pay payment
  /// and then present the payment sheet to the user.
  ///
  /// The [paymentAmount] is the amount of the payment in GBP.
  ///
  /// The method will return a map containing the Stripe response if the
  /// payment is successful, otherwise it will return null.
  ///
  /// The method will also log any errors that occur during the payment
  /// process.
  ///
  /// Example:
  ///
/* <<<<<<<<<<  ae996dca-875e-4f76-8640-d9423d96f94f  >>>>>>>>>>> */
  Future<Map<String, dynamic>?> payWithApplePay(double paymentAmount) async {
    try {
      // Create payment intent
      String? clientSecret = await createPaymentIntent(paymentAmount, "gbp");
      if (clientSecret == null) {
        throw Exception('Failed to create payment intent');
      }

      // Present Apple Pay and confirm payment
      final paymentIntent = await Stripe.instance.confirmPlatformPayPaymentIntent(
        clientSecret: clientSecret,
        confirmParams: PlatformPayConfirmParams.applePay(
          applePay: ApplePayParams(
            merchantCountryCode: 'GB', // 🇬🇧
            currencyCode: 'GBP',
            cartItems: [
              ApplePayCartSummaryItem.immediate(
                label: 'E-Commerce App',
                amount: paymentAmount.toStringAsFixed(2),
              ),
            ],
          ),
        ),
      );

      print('Apple Pay Successful: ${paymentIntent.toJson()}');
      return paymentIntent.toJson();
    } on StripeException catch (e) {
      print('Stripe Apple Pay error: ${e.error.localizedMessage}');
      if (e.error.code == FailureCode.Canceled) {
        throw Exception('Apple Pay was canceled by user');
      } else {
        throw Exception('Apple Pay failed: ${e.error.localizedMessage}');
      }
    } catch (e) {
      print('Apple Pay error: $e');
      throw Exception('Apple Pay failed: $e');
    }
  }

  Future<String?> createPaymentIntent(double amount, String currency) async {
    try {
      final stripeSecretKey = dotenv.env['STRIPE_SECRET_KEY'] ?? '';

      final Dio dio = Dio();
      Map<String, dynamic> data = {
        'amount': (amount * 100).toInt(), // Stripe expects amount in cents
        'currency': currency,
        'automatic_payment_methods[enabled]': 'true',
      };
      var response = await dio.post(
        'https://api.stripe.com/v1/payment_intents',
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer $stripeSecretKey",
            "Content-Type": "application/x-www-form-urlencoded",
          },
        ),
      );
      if (response.data != null) {
        print('Payment Response ${response.data}');
        return response.data['client_secret'];
      }

      return null;
    } catch (e) {
      if (e is DioException) {
        print('Dio Error: ${e.response?.data}');
      } else {
        print('Error creating Payment Intent: $e');
      }
      return null;
    }
  }

  String _calculateAmount(int amount) {
    final calculateAmount = amount * 100;
    return calculateAmount.toString();
  }
}

// class StripeService {
//   static final StripeService _instance = StripeService._internal();
//   factory StripeService() => _instance;
//   StripeService._internal();
//
//   // Replace with your actual backend URL
//   static const String _backendUrl = 'https://api.stripe.com/v1';
//
//   /// Initialize Stripe with publishable key
//   static Future<void> initialize(String publishableKey) async {
//     Stripe.publishableKey = publishableKey;
//     await Stripe.instance.applySettings();
//   }
//
//   /// Create a payment intent on your backend
//   Future<Map<String, dynamic>> createPaymentIntent({
//     required int amount, // Amount in cents
//     required String currency,
//     String? customerId,
//     Map<String, dynamic>? metadata,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('https://api.stripe.com/v1/payment_intents'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'amount': amount,
//           'currency': currency,
//           'customer': customerId,
//           'metadata': metadata,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//       } else {
//         throw Exception('Failed to create payment intent: ${response.body}');
//       }
//     } catch (e) {
//       throw Exception('Error creating payment intent: $e');
//     }
//   }
//
//   /// Process a credit card payment
//   Future<void> processPayment({
//     required String clientSecret,
//     BillingDetails? billingDetails,
//   }) async {
//     try {
//       // Confirm the payment
//       await Stripe.instance.confirmPayment(
//         paymentIntentClientSecret: clientSecret,
//         data: PaymentMethodParams.card(
//           paymentMethodData: PaymentMethodData(
//             billingDetails: billingDetails,
//           ),
//         ),
//       );
//     } catch (e) {
//       throw Exception('Payment failed: $e');
//     }
//   }
//
//   /// Present payment sheet for easier payment flow
//   Future<void> initPaymentSheet({
//     required String clientSecret,
//     required String merchantDisplayName,
//     String? customerId,
//     String? customerEphemeralKeySecret,
//   }) async {
//     try {
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: clientSecret,
//           merchantDisplayName: merchantDisplayName,
//           customerId: customerId,
//           customerEphemeralKeySecret: customerEphemeralKeySecret,
//           style: ThemeMode.system,
//           appearance: PaymentSheetAppearance(
//             colors: PaymentSheetAppearanceColors(
//               primary: null,
//             ),
//           ),
//         ),
//       );
//     } catch (e) {
//       throw Exception('Failed to initialize payment sheet: $e');
//     }
//   }
//
//   /// Present the payment sheet
//   Future<void> presentPaymentSheet() async {
//     try {
//       await Stripe.instance.presentPaymentSheet();
//     } on StripeException catch (e) {
//       if (e.error.code == FailureCode.Canceled) {
//         throw Exception('Payment canceled by user');
//       } else {
//         throw Exception('Payment failed: ${e.error.localizedMessage}');
//       }
//     } catch (e) {
//       throw Exception('Payment failed: $e');
//     }
//   }
//
//   /// Complete payment flow with payment sheet
//   Future<void> makePayment({
//     required double amount,
//     required String currency,
//     required String merchantDisplayName,
//     Map<String, dynamic>? metadata,
//   }) async {
//     try {
//       // Create payment intent
//       final paymentIntentData = await createPaymentIntent(
//         amount: (amount * 100).toInt(), // Convert to cents
//         currency: currency,
//         metadata: metadata,
//       );
//
//       final clientSecret = paymentIntentData['clientSecret'] as String;
//
//       // Initialize payment sheet
//       await initPaymentSheet(
//         clientSecret: clientSecret,
//         merchantDisplayName: merchantDisplayName,
//       );
//
//       // Present payment sheet
//       await presentPaymentSheet();
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   /// Validate card number using Luhn algorithm
//   static bool validateCardNumber(String cardNumber) {
//     final cleaned = cardNumber.replaceAll(RegExp(r'\s+'), '');
//     if (cleaned.length < 13 || cleaned.length > 19) {
//       return false;
//     }
//
//     int sum = 0;
//     bool alternate = false;
//
//     for (int i = cleaned.length - 1; i >= 0; i--) {
//       int digit = int.parse(cleaned[i]);
//
//       if (alternate) {
//         digit *= 2;
//         if (digit > 9) {
//           digit -= 9;
//         }
//       }
//
//       sum += digit;
//       alternate = !alternate;
//     }
//
//     return sum % 10 == 0;
//   }
//
//   /// Get card brand from card number
//   static CardBrand getCardBrand(String cardNumber) {
//     final cleaned = cardNumber.replaceAll(RegExp(r'\s+'), '');
//
//     if (cleaned.isEmpty) {
//       return CardBrand.Unknown;
//     }
//
//     if (cleaned.startsWith(RegExp(r'^4'))) {
//       return CardBrand.Visa;
//     } else if (cleaned.startsWith(RegExp(r'^5[1-5]'))) {
//       return CardBrand.Mastercard;
//     } else if (cleaned.startsWith(RegExp(r'^3[47]'))) {
//       return CardBrand.AmericanExpress;
//     } else if (cleaned.startsWith(RegExp(r'^6(?:011|5)'))) {
//       return CardBrand.Discover;
//     }
//
//     return CardBrand.Unknown;
//   }
//
//   /// Validate expiry date
//   static bool validateExpiryDate(String expiry) {
//     if (!RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$').hasMatch(expiry)) {
//       return false;
//     }
//
//     final parts = expiry.split('/');
//     final month = int.parse(parts[0]);
//     final year = int.parse('20${parts[1]}');
//
//     final now = DateTime.now();
//     final expiryDate = DateTime(year, month);
//
//     return expiryDate.isAfter(DateTime(now.year, now.month));
//   }
//
//   /// Validate CVV
//   static bool validateCVV(String cvv, CardBrand brand) {
//     if (brand == CardBrand.AmericanExpress) {
//       return cvv.length == 4;
//     }
//     return cvv.length == 3;
//   }
// }
//
// enum CardBrand {
//   Visa,
//   Mastercard,
//   AmericanExpress,
//   Discover,
//   Unknown,
// }