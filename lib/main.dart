import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:simple_calculator/custom_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_automation/flutter_automation.dart';

import 'config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  themeBox = await Hive.openBox('themes');
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MyApp()));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    currentTheme.addListener(() {
      //2
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.darkTheme,
      themeMode: currentTheme.currentTheme(),
      home: const SimpleCalculator(),
    );
  }
}

class SimpleCalculator extends StatefulWidget {
  const SimpleCalculator({Key? key}) : super(key: key);

  @override
  _SimpleCalculatorState createState() => _SimpleCalculatorState();
}

class _SimpleCalculatorState extends State<SimpleCalculator> {
  //declare the result string
  String _result = '';
  String equation = '';
  String _inputDisplay = '0';

//our results widget
  Widget _resultDisplay() {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.35,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
                onPressed: () {
                  currentTheme.toggleTheme();
                },
                icon: const Icon(Icons.light_mode)),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  alignment: Alignment.topRight,
                  child: FittedBox(
                    child: Text(
                      _inputDisplay,
                      style: Theme.of(context).textTheme.headline2,
                      maxLines: 4,
                      softWrap: true,
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  alignment: Alignment.topRight,
                  child: Text(
                    _result,
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

//calculator buttons
  Widget _calButton(
    String text,
  ) {
    return TextButton(
      onPressed: () => _calButtonPressed(text),
      onLongPress: () => _calButtonPressed(text),
      child: Text(
        text,
        style: Theme.of(context).textTheme.button,
      ),
    );
  }

  //method function to call when the calculator button is pressed
  void _calButtonPressed(String calButtonText) {
    setState(() {
      if (calButtonText == '⌫') {
        _inputDisplay = _inputDisplay.substring(0, _inputDisplay.length - 1);
        if (_inputDisplay == '') {
          _inputDisplay = '0';
        }
      } else if (calButtonText == 'C') {
        _result = '';
        equation = '0';
        _inputDisplay = '0';
      } else if (calButtonText == '-/+') {
        if (_inputDisplay[0] != '-') {
          _inputDisplay = '-$_inputDisplay';
        }
      } else if (calButtonText == '=') {
        equation = _inputDisplay;
        equation = equation.replaceAll('x', '*');
        equation = equation.replaceAll('÷', '/');

        try {
          final Parser p = Parser();
          final Expression expression = p.parse(equation);

          final ContextModel cm = ContextModel();
          _result = expression.evaluate(EvaluationType.REAL, cm).toString();
        } catch (e) {
          _result = 'Error';
        }
      } else {
        if (_inputDisplay == '0') {
          _inputDisplay = calButtonText;
        } else {
          _inputDisplay = _inputDisplay + calButtonText;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          _resultDisplay(),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _calButton(
                          'C',
                        ),
                        _calButton(
                          '-/+',
                        ),
                        _calButton('÷'),
                        _calButton('⌫'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _calButton(
                          '7',
                        ),
                        _calButton(
                          '8',
                        ),
                        _calButton(
                          '9',
                        ),
                        _calButton('x'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _calButton(
                          '4',
                        ),
                        _calButton(
                          '5',
                        ),
                        _calButton(
                          '6',
                        ),
                        _calButton('-'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _calButton(
                          '1',
                        ),
                        _calButton(
                          '2',
                        ),
                        _calButton(
                          '3',
                        ),
                        _calButton('+'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _calButton('%'),
                        _calButton(
                          '0',
                        ),
                        _calButton(
                          '.',
                        ),
                        _calButton('='),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
