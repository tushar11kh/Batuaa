import 'package:batuaa/presentation/widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import '../../../colors.dart';
import '../../../logic/flutter_toast.dart';
import '../../widgets/text_field.dart';
import 'home_screen.dart';

class AddExpensesScreen extends StatefulWidget {
  const AddExpensesScreen({super.key});

  @override
  State<AddExpensesScreen> createState() => _AddExpensesScreenState();
}

class _AddExpensesScreenState extends State<AddExpensesScreen> {
  final _formKey = GlobalKey<FormState>();

  final user = FirebaseAuth.instance.currentUser!;

  DatabaseReference ref = FirebaseDatabase.instance.ref().child('Users');

  DateTime now = DateTime.now();

  final expensesController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    expensesController.dispose();
  }

  String? checkValid(value) {
    if (value.isEmpty || value == null) {
      return 'This field is required';
    }
    return null;
  }

  void add() {
    if (_formKey.currentState!.validate()) {
      double? expenses = double.tryParse(expensesController.text);

      if (expenses == null) {
        return ToastMessage()
            .toastMessage('Please enter the amount', Colors.red);
      }


        DatabaseReference splitRef = ref.child(user.uid).child('split');

        splitRef.update(
          {
            'expenses': ServerValue.increment(expenses),
          },
        ).then(
          (value) async {

            ToastMessage().toastMessage('Added!', Colors.green);

            final payer = {
              'name': 'expense added!',
              'expenses': '+ ${expensesController.text}',
              'paymentDateTime': now.toIso8601String(),
            };
            ref
                .child(user.uid)
                .child('split')
                .child('allTransactions')
                .push()
                .set(payer);
          },
        ).onError(
          (error, stackTrace) {
            ToastMessage().toastMessage(error.toString(), Colors.red);
          },
        );

        // ignore: use_build_context_synchronously
        Navigator.pop(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return OrientationBuilder(
              builder: (BuildContext context, Orientation orientation) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: constraints.maxHeight * 0.02),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.keyboard_backspace),
                              ),
                              SizedBox(
                                width: constraints.maxWidth * 0.03,
                              ),
                              const Text(
                                'Add Expense',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          SizedBox(height: constraints.maxHeight * 0.02),
                          const Text(
                            'Enter amount',
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(height: constraints.maxHeight * 0.02),
                          CustomTextField(
                              hint: 'expenses',
                              iconName: Icons.currency_rupee,
                              controller: expensesController,
                              validator: checkValid,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ]),                   
                          SizedBox(height: constraints.maxHeight * 0.04),
                          TButton(
                              constraints: constraints,
                              btnColor: Theme.of(context).primaryColor,
                              btnText: 'Add',
                              onPressed: () async {
                                add();
                              }),
                          SizedBox(
                              height: orientation == Orientation.portrait
                                  ? constraints.maxHeight * 0.02
                                  : constraints.maxHeight * 0.08),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
