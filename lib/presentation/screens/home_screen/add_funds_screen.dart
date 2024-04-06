import 'package:batuaa/presentation/widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import '../../../colors.dart';
import '../../../logic/flutter_toast.dart';
import '../../widgets/text_field.dart';
import 'home_screen.dart';

class AddFundsScreen extends StatefulWidget {
  const AddFundsScreen({Key? key}) : super(key: key);

  @override
  State<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends State<AddFundsScreen> {
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser!;
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('Users');
  DateTime now = DateTime.now();
  final amountController = TextEditingController();

  String? selectedFundType;
  List<String> fundTypes = [
    'Salary',
    'Business Profits',
    'Rental Income',
    'Other Income'
  ];

  @override
  void dispose() {
    super.dispose();
    amountController.dispose();
  }

  String? checkValid(value) {
    if (value.isEmpty || value == null) {
      return 'This field is required';
    }
    return null;
  }

  void add() {
    if (_formKey.currentState!.validate()) {
      double? amount = double.tryParse(amountController.text);

      if (amount == null) {
        ToastMessage().toastMessage('Please enter a valid amount', Colors.red);
        return;
      }

      DatabaseReference splitRef = ref.child(user.uid).child('split');

      splitRef.update({
        'amount': ServerValue.increment(amount),
      }).then((value) async {
        DatabaseReference expensesRef = ref.child(user.uid).child('split');

        ToastMessage().toastMessage('Funds added!', Colors.green);

        final payer = {
          'name': selectedFundType, // Use the selected fund type
          'amount': '+ ${amountController.text}',
          'paymentDateTime': now.toIso8601String(),
        };

        ref
            .child(user.uid)
            .child('split')
            .child('allTransactions')
            .push()
            .set(payer);
      }).onError((error, stackTrace) {
        ToastMessage().toastMessage(error.toString(), Colors.red);
      });

      Navigator.pop(context);
    }
  }

  void selectFundType(String type) {
    setState(() {
      selectedFundType = type;
    });
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
                              SizedBox(width: constraints.maxWidth * 0.03),
                              const Text(
                                'Add Funds',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: constraints.maxHeight * 0.02),
                          const Text(
                            'Select Income ',
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(height: constraints.maxHeight * 0.02),
                          Wrap(
                            // Wrap widget for button layout
                            spacing: 10.0, // spacing between buttons
                            runSpacing: 5.0, // spacing between rows of buttons
                            children: fundTypes
                                .map((String type) => ElevatedButton(
                                      onPressed: () => selectFundType(type),
                                      child: Text(type),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: selectedFundType ==
                                                type
                                            ? Theme.of(context).primaryColor
                                            : kGrayTextfieldC, // Change button color based on selection
                                      ),
                                    ))
                                .toList(),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.02),
                          const Text(
                            'Enter amount',
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(height: constraints.maxHeight * 0.02),
                          CustomTextField(
                            hint: 'Amount',
                            iconName: Icons.currency_rupee,
                            controller: amountController,
                            validator: checkValid,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                          SizedBox(height: constraints.maxHeight * 0.04),
                          TButton(
                            constraints: constraints,
                            btnColor: Theme.of(context).primaryColor,
                            btnText: 'Add',
                            onPressed: add,
                          ),
                          SizedBox(
                            height: orientation == Orientation.portrait
                                ? constraints.maxHeight * 0.02
                                : constraints.maxHeight * 0.08,
                          ),
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
