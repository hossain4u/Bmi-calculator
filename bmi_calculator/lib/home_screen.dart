import 'package:flutter/material.dart';
enum HeightType {cm, feetInch}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HeightType heightType = HeightType.cm;

  final weightCtr = TextEditingController();
  final cmCtr = TextEditingController();
  final feetCtr = TextEditingController();
  final inchCtr = TextEditingController();
  String _bmiResult= "";

  double? cmToM(){
    final cm =double.tryParse(cmCtr.text.trim());
    if (cm == null || cm <=0 ) return null;

    return cm/100.0;
  }
  double? feetInchToM(){
    final feet =double.tryParse(feetCtr.text.trim());
    final inch =double.tryParse(inchCtr.text.trim());

    if (feet == null || feet <=0 || inch == null || inch <=0 ){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Invalid Value')));
      return null;
    }
    final totalInch= feet*12+inch;
    if(totalInch <=0){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Invalid Value')));
      return null;
    }
    return totalInch * 0.0254;
  }

  void _calculator(){
    final weight =double.tryParse(weightCtr.text.trim());
    if (weight == null || weight <=0 ){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Invalid Value')));
      return;
    }
    final m = heightType == HeightType.cm ? cmToM() : feetInchToM();
    if (m== null){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Invalid Value')));
      return;
    }
    final bmi = weight /(m*m);
    setState(() {
      _bmiResult = bmi.toStringAsFixed(2);
    });

  }

  @override
  void dispose(){
    weightCtr.dispose();
    cmCtr.dispose();
    feetCtr.dispose();
    inchCtr.dispose();
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          TextFormField(
            controller: weightCtr,
            decoration: InputDecoration(
              labelText: "Weight (Kg)",
              border: OutlineInputBorder(
              )
            ),
          ),
          const SizedBox(height: 15,),
          Text('Height Unit',style: TextStyle(fontSize:20, fontWeight: FontWeight.bold),),
          const SizedBox(height: 12,),
          SegmentedButton<HeightType>(segments: [
            const ButtonSegment<HeightType>(value: HeightType.cm, label: Text("cm")),
            const ButtonSegment<HeightType>(value: HeightType.feetInch, label: Text("Feet/Inch")),
          ], selected: {heightType},
          onSelectionChanged: (value)=> setState(()=> heightType =value.first ),
          ),
          const SizedBox(height: 10),
          if(heightType == HeightType.cm)...[
            TextFormField(
              controller: cmCtr,
              decoration: InputDecoration(
                  labelText: "Height (Cm)",
                  border: OutlineInputBorder(
                  )
              ),
            ),
          ]else...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: feetCtr,
                    decoration: InputDecoration(
                        labelText: "Feet(')",
                        border: OutlineInputBorder(
                        )
                    ),
                  ),
                ),
                const SizedBox(width:10),
                Expanded(
                  child: TextFormField(
                    controller: inchCtr,
                    decoration: InputDecoration(
                        labelText: 'Inch(")',
                        border: OutlineInputBorder(
                        )
                    ),
                  ),
                ),
              ],
            )
          ],
          const SizedBox(height: 15,),
          ElevatedButton(onPressed: _calculator, child: Text("Show Result")),
          const SizedBox(height: 15,),
          Text("Result : $_bmiResult"),
          const SizedBox(height: 15,),

        ],
      ),
    );
  }
}
