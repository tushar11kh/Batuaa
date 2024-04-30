import 'package:batuaa/presentation/widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import '../../../colors.dart';
import '../../../logic/flutter_toast.dart';
import '../../widgets/text_field.dart';
import 'home_screen.dart';
import 'package:intl/intl.dart';

class AddExpensesScreen extends StatefulWidget {
  const AddExpensesScreen({Key? key}) : super(key: key);

  @override
  State<AddExpensesScreen> createState() => _AddExpensesScreenState();
}

class _AddExpensesScreenState extends State<AddExpensesScreen> {
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('Users');
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser!;

  DateTime now = DateTime.now();
  final expenseNameController = TextEditingController();
  final expensesController = TextEditingController();

  String? selectedCategory;
  List<String> expenseCategories = [
    'Food & Drinks',
    'Shopping',
    'Housing',
    'Transportation',
    'Vehicle',
    'Life & Entertainment',
    'Electronics',
    'Other Expenses'
  ];

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
    if (_formKey.currentState!.validate()) {
      // Parse the entered expenses amount
      double? expenses = double.tryParse(expensesController.text);

      DatabaseReference amountRef = ref.child(user.uid).child('split/amount');
      DatabaseReference expensesRef =
          ref.child(user.uid).child('split/expenses');

      // Fetch amount and expenses from Firebase
      Future<List<double>> futureValues = Future.wait([
        amountRef
            .get()
            .then((snapshot) => double.parse(snapshot.value.toString())),
        expensesRef
            .get()
            .then((snapshot) => double.parse(snapshot.value.toString())),
      ]);

      futureValues.then((values) {
        double availableBalance = values[0] - values[1];

        if (expenses != null && expenses <= availableBalance) {
          // Proceed to add expense
          DatabaseReference splitRef = ref.child(user.uid).child('split');

          splitRef.update({
            'expenses': ServerValue.increment(expenses),
          }).then((_) {
            DatabaseReference expensesRef = ref.child(user.uid).child('split');
            ToastMessage().toastMessage('Expense added!', Colors.green);

            final payer = {
              'name': expenseNameController.text.trim(),
              'amount': '- ${expensesController.text}',
              'category': selectedCategory ?? 'Other Expenses',
              'paymentDateTime': now.toIso8601String(),
              'value': double.parse(expensesController.text),
              'type': "Expense",
            };

            ref
                .child(user.uid)
                .child('split')
                .child('allTransactions')
                .push()
                .set(payer);

            Navigator.pop(context); // Go back to previous screen
          }).catchError((error) {
            ToastMessage()
                .toastMessage('Failed to add expense: $error', Colors.red);
          });
        } else {
          // Show error message if expense exceeds available balance
          ToastMessage().toastMessage(
              'Insufficient Balance! Your monthly balance left: ₹$availableBalance',
              Colors.red);
        }
      }).catchError((error) {
        // Show error if fetching data from Firebase fails
        ToastMessage().toastMessage('Failed to fetch data: $error', Colors.red);
      });
    }
  }

  Widget buildCategoryButton(String category) {
    bool isSelected = category == selectedCategory;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCategory = isSelected ? null : category;
        });
      },
      style: ButtonStyle(
        backgroundColor: isSelected
            ? MaterialStateProperty.all(Theme.of(context).primaryColor)
            : MaterialStateProperty.all(kGrayTextfieldC),
      ),
      child: Text(category),
    );
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
                          SizedBox(height: 16.0),
                          Row(
                            children: [
                              Text(
                                'Select Date: ${DateFormat('E, d MMMM').format(now)}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(width: 13.0),
                              ElevatedButton(
                                onPressed: () => _selectDate(context),
                                child: Text('Change'),
                              ),
                            ],
                          ),
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
                            'Expense Name',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.02),
                          CustomTextField(
                            iconName: Icons.add_shopping_cart_outlined,
                            hint: 'Enter Expense Name',
                            controller: expenseNameController,
                            validator: checkValid,
                          ),
                          SizedBox(height: constraints.maxHeight * 0.02),
                          const Text(
                            'Enter Amount',
                            style: TextStyle(fontSize: 18),
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
                            ],
                          ),
                          SizedBox(height: constraints.maxHeight * 0.02),
                          const Text(
                            'Select Category',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.02),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: expenseCategories.map((category) {
                              return buildCategoryButton(category);
                            }).toList(),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.02),
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
