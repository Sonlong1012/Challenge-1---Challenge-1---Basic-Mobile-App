
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang Chủ'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Chào Mừng Bạn Đến với Trang Chủ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CurrencyConverterScreen()),
                );
              },
              child: const Text('Go to Converter'),
            ),
          ],
        ),
      ),
    );
  }
}

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  _CurrencyConverterScreenState createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'VND';
  String? _convertedValue;
  bool _isLoading = false;
  final _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'AUD', 'VND'];

  Future<void> _convertCurrency() async {
    final amountText = _amountController.text;
    if (amountText.isEmpty || double.tryParse(amountText) == null) {
      _showError('Please enter a valid amount.');
      return;
    }

    final amount = double.parse(amountText);
    setState(() {
      _isLoading = true;
    });

    try {
      final url = 'https://api.exchangerate-api.com/v4/latest/$_fromCurrency';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rate = data['rates'][_toCurrency];
        if (rate != null) {
          setState(() {
            _convertedValue = (amount * rate).toStringAsFixed(2);
          });
        } else {
          _showError('Currency conversion rate not found.');
        }
      } else {
        _showError('Failed to fetch exchange rate.');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số Tiền',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _fromCurrency,
                    items: _currencies
                        .map((currency) => DropdownMenuItem(
                            value: currency, child: Text(currency)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _fromCurrency = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'From',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _toCurrency,
                    items: _currencies
                        .map((currency) => DropdownMenuItem(
                            value: currency, child: Text(currency)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _toCurrency = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'To',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _convertCurrency,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.black,
                    )
                  : const Text('Chuyển đổi',),
            ),
            const SizedBox(height: 16),
            if (_convertedValue != null)
              Text(
                'Giá trị: $_convertedValue $_toCurrency',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
              ),
          ],
        ),
      ),
    );
  }
}
