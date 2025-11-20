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
        "usd", // 🇺🇸 USD currency
      );
      if (result == null) return null;
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: result,
          billingDetails: BillingDetails(
            address: Address(
              city: '',
              country: 'US', // 🇺🇸
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
  /// The [paymentAmount] is the amount of the payment in USD.
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
      String? clientSecret = await createPaymentIntent(paymentAmount, "usd");
      if (clientSecret == null) {
        throw Exception('Failed to create payment intent');
      }

      // Present Apple Pay and confirm payment
      final paymentIntent = await Stripe.instance.confirmPlatformPayPaymentIntent(
        clientSecret: clientSecret,
        confirmParams: PlatformPayConfirmParams.applePay(
          applePay: ApplePayParams(
            merchantCountryCode: 'US', // 🇺🇸 Apple Pay merchant country
            currencyCode: 'USD',       // 💵 Apple Pay currency
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