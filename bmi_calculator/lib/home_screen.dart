import 'package:flutter/material.dart';

enum WeightType{kg, lb}
enum HeightType { meter,cm,feetInch }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WeightType weightType = WeightType.kg;
  HeightType heightType = HeightType.cm;

  final weightCtr = TextEditingController();
  final cmCtr = TextEditingController();
  final feetCtr = TextEditingController();
  final inchCtr = TextEditingController();
  final meterCtr = TextEditingController();

  String _bmiResult = "";
  String? category;

  // --------Category Color --------
  Color getCategoryColor(String? category) {
    switch (category) {
      case "Underweight":
        return Colors.blue;
      case "Healthy Weight":
        return Colors.green;
      case "Overweight":
        return Colors.orange;
      case "Obesity":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // -------- Category Result --------
  String categoryResult(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 24.9) return "Healthy Weight";
    if (bmi < 29.9) return "Overweight";
    return "Obesity";
  }

  // -------- Height Conversions --------
  double? cmToM() {
    final cm = double.tryParse(cmCtr.text.trim());
    if (cm == null || cm <= 0) return null;

    return cm / 100.0;
  }

  double? meterValue() {
    final m = double.tryParse(meterCtr.text.trim());
    if (m == null || m <= 0) return null;
    return m;
  }

  double? feetInchToM() {
    double? feet = double.tryParse(feetCtr.text.trim());
    double? inch = double.tryParse(inchCtr.text.trim());

    if (feet == null || feet <= 0 || inch == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid Value')));
      return null;
    }
    if (inch >= 12) {
      feet += (inch ~/ 12);
      inch = inch % 12;
      feetCtr.text = feet.toStringAsFixed(0);
      inchCtr.text = inch.toStringAsFixed(0);
    }

    final totalInch = feet * 12 + inch;
    if (totalInch <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid Value')));
      return null;
    }
    return totalInch * 0.0254;
  }

  // -------- Calculate BMI --------
  void _calculator() {
    final weight = double.tryParse(weightCtr.text.trim());
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid Value')));
      return;
    }

    double? m;
    switch (heightType) {
      case HeightType.cm:
        m = cmToM();
        break;
      case HeightType.meter:
        m = meterValue();
        break;
      case HeightType.feetInch:
        m = feetInchToM();
        break;
    }

    if (m == null || m <=0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid Value')));
      return;
    }

    final weightInKg = weightType == WeightType.lb ? weight * 0.45359237 : weight;
    final bmi = weightInKg / (m * m);
    final cat = categoryResult(bmi);

    setState(() {
      _bmiResult = bmi.toStringAsFixed(2);
      category = cat;
    });
    weightCtr.clear();
    cmCtr.clear();
    meterCtr.clear();
    feetCtr.clear();
    inchCtr.clear();
  }

  @override
  void dispose() {
    weightCtr.dispose();
    cmCtr.dispose();
    feetCtr.dispose();
    inchCtr.dispose();
    meterCtr.dispose();
    super.dispose();
  }

  // -------- UI --------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BMI Calculator'), centerTitle: true),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          //..... Weight toggle ......
          SegmentedButton<WeightType>(segments: const[
            ButtonSegment<WeightType>(value: WeightType.kg,
              label: Text("Kg"),),
            ButtonSegment<WeightType>(value: WeightType.lb,
              label: Text("Lb"),)
          ],
            selected:{weightType},
            onSelectionChanged: (value) {
              setState(() {
                weightType = value.first;
              });
            },
          ),
          SizedBox(height: 10),

          //...... Weight input .......
          TextFormField(
            controller: weightCtr,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: weightType == WeightType.kg ? "Weight (Kg)" : "Weight (Lb)",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Height Unit',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          //....... Height toggle ......
          SegmentedButton<HeightType>(
            segments: [
              const ButtonSegment<HeightType>(
                value: HeightType.cm,
                label: Text("cm"),
              ),
              const ButtonSegment<HeightType>(
                value: HeightType.meter,
                label: Text("Meter"),
              ),
              const ButtonSegment<HeightType>(
                value: HeightType.feetInch,
                label: Text("Feet/Inch"),
              ),
            ],
            selected: {heightType},
            onSelectionChanged: (value) =>
                setState(() => heightType = value.first),
          ),
          
          const SizedBox(height: 10),

          //....... Height inputs .....
          if (heightType == HeightType.cm) ...[
            TextFormField(
              controller: cmCtr,
              decoration: InputDecoration(
                labelText: "Height (Cm)",
                border: OutlineInputBorder(),
              ),
            ),
          ] else if (heightType == HeightType.meter) ...[
            TextFormField(
              controller: meterCtr,
              decoration: const InputDecoration(
                labelText: "Height (m)",
                border: OutlineInputBorder(),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: feetCtr,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: "Feet(')",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: inchCtr,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Inch(")',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 15),
          ElevatedButton(onPressed: _calculator, child: Text("Show Result")),
          const SizedBox(height: 15),

          //........ Result Card ....
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your BMI Score:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _bmiResult.isEmpty ? "—" : _bmiResult,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (category != null)
                    Row(
                      children: [
                        Text(
                          "Category: ",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Chip(
                          label: Text(
                            category!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: getCategoryColor(category),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
