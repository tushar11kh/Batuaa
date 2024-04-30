import 'package:batuaa/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../widgets/savings_balance_card.dart';
import '../../../widgets/null_error_message_widget.dart';
import 'package:batuaa/batuaa_themes.dart';
import '../../../../logic/flutter_toast.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('Users');
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser!;
  String? selectedFundType;
  final amountController = TextEditingController();

  DateTime now = DateTime.now();
  final expenseNameController = TextEditingController();
  final expensesController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    expenseNameController.dispose();
    expensesController.dispose();
  }

  String? checkValid(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      // Set the lastDate to the current date to prevent future dates
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != now) {
      setState(() {
        now = picked;
      });
    }
  }

  void add() {
    dynamic amount = 310.0;

    DatabaseReference ref = FirebaseDatabase.instance.ref().child('Users');

    // 1. Store the previous amount in a variable
    final double previousAmount = amount!; // Use the parsed amount directly

    DatabaseReference splitRef = ref.child(user.uid).child('split');

    splitRef.update({
      'amount': ServerValue.increment(previousAmount),
    }).then((value) async {
      // ... existing success logic ...

      ToastMessage().toastMessage('Funds added!', Colors.green);

      // 2. Clear the amount field
      amountController.text = '';

      final payer = {
        'name': selectedFundType,
        // 3. Set display amount to 0
        'amount': '+ 0.00', // Assuming you want two decimal places
        'paymentDateTime': now.toIso8601String(),
        'value': previousAmount, // Store the actual amount
        'type': "Income",
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: ref.child(user.uid.toString()).child('split').onValue,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.snapshot.value == null) {
              return const NullErrorMessage(
                message: 'Something went wrong!',
              );
            } else {
              Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
              return Scaffold(
                body: SafeArea(
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return OrientationBuilder(
                        builder:
                            (BuildContext context, Orientation orientation) {
                          var sizedBox = SizedBox(
                            height: constraints.maxHeight * 0.02,
                          );
                          return SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BalanceCard(
                                    amount: map['savings'].toStringAsFixed(0),
                                    constraints:
                                        orientation == Orientation.portrait
                                            ? constraints.maxHeight * 0.25
                                            : constraints.maxHeight * 0.8,
                                  ),

                                  SizedBox(
                                      height: 20,
                                      width:
                                          20), // Horizontal spacing between buttons
                                  // Add Expenses Button
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.075,
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: batuaaThemes.isDarkMode(context)
                                          ? kDarkGreenBackC
                                          : kGreenDarkC,
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        if (map['amount'] > 0) {
                                          ref
                                              .child(user.uid)
                                              .child('split')
                                              .update({
                                            'savings': map['savings'] +
                                                map['amount'] -
                                                map['expenses'],
                                            'amount': 0,
                                            'expenses': 0,
                                          });
                                        } else {
                                          ToastMessage().toastMessage(
                                              'No amount available to transfer!',
                                              Colors.red);
                                          print(
                                              "Error: Amount is already 0. Cannot update.");
                                        }
                                        // add();
                                        // Map<dynamic, dynamic> map =
                                        //     snapshot.data.snapshot.value;

                                        // dynamic total =
                                        //     map['amount'] as dynamic;

                                        // print('total');
                                      },
                                      child: Column(
                                        // Wrap everything in a Column
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(width: 5),
                                              Flexible(
                                                child: Text(
                                                  'Transfer Savings',
                                                  style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines:
                                                      1, // Limit to one line to prevent overflow
                                                ),
                                              ),
                                            ],
                                          ),
                                          // Row(
                                          //   mainAxisAlignment:
                                          //       MainAxisAlignment.center,
                                          //   children: [
                                          //     const Text(
                                          //       // Const Text for "This feature is disabled"
                                          //       'This feature is disabled',
                                          //       style: TextStyle(
                                          //         fontSize: 12,
                                          //         color: Colors.grey,
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // sizedBox,
                                  // const Text(
                                  //   'All Transactions',
                                  //   style: TextStyle(fontSize: 20),
                                  // ),
                                  // SizedBox(
                                  //   height: constraints.maxHeight * 0.015,
                                  // ),
                                ],
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
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: kGreenColor,
              ),
            );
          }
        });
  }
}
