import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Calculator extends StateNotifier<double> {
  Calculator() : super(0.0);

  void calculateBMI(double kg, double m) {
    state = double.parse((kg / (m * m) * 10000).toStringAsFixed(1));
  }
}

final calculatorProvider = StateNotifierProvider<Calculator, double>((ref) {
  return Calculator();
});

void main() {
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('BMI Calculator')),
        body: const Center(
          child: BMIWidget(),
        ),
      ),
    );
  }
}

class BMIWidget extends ConsumerStatefulWidget {
  const BMIWidget({super.key});

  @override
  _BMIWidgetState createState() => _BMIWidgetState();
}

class _BMIWidgetState extends ConsumerState<BMIWidget> {
  late TextEditingController weightController;
  late TextEditingController heightController;

  @override
  void initState() {
    super.initState();
    weightController = TextEditingController();
    heightController = TextEditingController();
  }

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bmi = ref.read(calculatorProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 250,
          child: TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your weight in kg',
              labelText: 'kg',
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 250,
          child: TextField(
            controller: heightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your height in cm',
              labelText: 'cm',
            ),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            final weight = double.tryParse(weightController.text);
            final height = double.tryParse(heightController.text);
            if (weight != null && height != null) {
              ref
                  .read(calculatorProvider.notifier)
                  .calculateBMI(weight, height);
            }
          },
          child: const Text('Calculate BMI'),
        ),
        const SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your BMI ', style: const TextStyle(fontSize: 25)),
            Text(bmi.toString(),
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
