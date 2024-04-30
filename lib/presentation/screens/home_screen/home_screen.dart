import 'package:batuaa/batuaa_themes.dart';
import 'package:batuaa/logic/flutter_toast.dart';
import 'package:batuaa/presentation/screens/home_screen/add_funds_screen.dart';
import 'package:batuaa/presentation/screens/home_screen/add_expenses_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:batuaa/presentation/widgets/custom_card.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import '../../../colors.dart';
import '../../../logic/autodeduct_emergencyfunds.dart';
import '../../../logic/autodeduct_monthend.dart';
import '../../widgets/button.dart';
import '../../widgets/null_error_message_widget.dart';
import '../../widgets/transaction_card.dart';
import 'package:intl/intl.dart';

import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('Users');

  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();

    AutoDeductEmergencyFunds emergencyEMI = AutoDeductEmergencyFunds();
    emergencyEMI.autoDeductEmergencyFunds();

    AutodeductMonthend deductBal = AutodeductMonthend();
    deductBal.autodeductMonthend();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // isAutoPayOn = false;
          SystemNavigator.pop();
          return true;
        },
        child: StreamBuilder(
            stream: ref.child(user.uid.toString()).child('split').onValue,
            builder: ((context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.snapshot.value == null) {
                  return LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const NullErrorMessage(
                              message:
                                  'Something went wrong!\n Make sure you have verified your mail',
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TButton(
                              constraints: constraints,
                              btnColor: Theme.of(context).primaryColor,
                              btnText: 'Sign up again!',
                              onPressed: () {
                                FirebaseAuth.instance.currentUser!.delete();
                                FirebaseAuth.instance.signOut;
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: const LoginScreen(),
                                  withNavBar:
                                      false, // OPTIONAL VALUE. True by default.
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  Map<dynamic, dynamic> map = snapshot.data.snapshot.value;

                  dynamic total = (map['amount'] - map['expenses']) as dynamic;

                  return WillPopScope(
                    onWillPop: () async {
                      // isAutoPayOn = false;
                      SystemNavigator.pop();
                      return true;
                    },
                    child: Scaffold(
                      body: SafeArea(
                        child: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return OrientationBuilder(
                              builder: (BuildContext context,
                                  Orientation orientation) {
                                return SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: constraints.maxHeight * 0.03,
                                        ),
                                        Text(
                                          'Batuaa',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 32,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          height: constraints.maxHeight * 0.02,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Monthly Balance Container
                                            Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.15,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Monthly Balance',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.currency_rupee,
                                                        size: 36,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(width: 5),
                                                      Flexible(
                                                        child: Text(
                                                          total.toStringAsFixed(
                                                              0),
                                                          style: TextStyle(
                                                            fontSize: 30,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines:
                                                              1, // Limit to one line to prevent overflow
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                                height:
                                                    20), // Vertical spacing between sections
                                            // Row for Add Funds and Add Expenses buttons
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                // Add Funds Button
                                                Flexible(
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.1,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                      color: batuaaThemes
                                                              .isDarkMode(
                                                                  context)
                                                          ? kDarkGreenBackC
                                                          : kGreenDarkC,
                                                    ),
                                                    child: TextButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const AddFundsScreen(),
                                                          ),
                                                        );
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                            size: 20,
                                                          ),
                                                          SizedBox(width: 5),
                                                          Flexible(
                                                            child: Text(
                                                              'Add Funds',
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines:
                                                                  1, // Limit to one line to prevent overflow
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                        20), // Horizontal spacing between buttons
                                                // Add Expenses Button
                                                Flexible(
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.1,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                      color: batuaaThemes
                                                              .isDarkMode(
                                                                  context)
                                                          ? kDarkGreenBackC
                                                          : kGreenDarkC,
                                                    ),
                                                    child: TextButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const AddExpensesScreen(),
                                                          ),
                                                        );
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                            size: 20,
                                                          ),
                                                          SizedBox(width: 5),
                                                          Flexible(
                                                            child: Text(
                                                              'Add Expenses',
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines:
                                                                  1, // Limit to one line to prevent overflow
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: constraints.maxHeight * 0.02,
                                        ),
                                        Text(
                                          '${DateFormat.MMMM().format(DateTime.now())} ${DateTime.now().year}',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        SizedBox(
                                          height: constraints.maxHeight * 0.02,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomCard(
                                              orientation: orientation,
                                              verHeight:
                                                  constraints.maxHeight * 0.14,
                                              horiHeight:
                                                  constraints.maxHeight * 0.35,
                                              verWidth:
                                                  constraints.maxHeight * 0.23,
                                              horiWidth:
                                                  constraints.maxWidth * 0.45,
                                              cardTitle: 'Income',
                                              cardBalance: map['amount']
                                                  .toStringAsFixed(0),
                                            ),
                                            CustomCard(
                                              orientation: orientation,
                                              verHeight:
                                                  constraints.maxHeight * 0.14,
                                              horiHeight:
                                                  constraints.maxHeight * 0.35,
                                              verWidth:
                                                  constraints.maxHeight * 0.23,
                                              horiWidth:
                                                  constraints.maxWidth * 0.45,
                                              cardTitle: 'Expenses',
                                              cardBalance: map['expenses']
                                                  .toStringAsFixed(0),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: constraints.maxHeight * 0.02,
                                        ),
                                        const Text(
                                          'All Transactions',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        SizedBox(
                                          height: constraints.maxHeight * 0.015,
                                        ),
                                        StreamBuilder(
                                          stream: ref
                                              .child(user.uid)
                                              .child('split')
                                              .child('allTransactions')
                                              .onValue,
                                          builder: (context,
                                              AsyncSnapshot<DatabaseEvent>
                                                  snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: kGreenColor,
                                                ),
                                              );
                                            } else if (snapshot.hasError) {
                                              return Center(
                                                child: Text(
                                                    'Error loading transactions'),
                                              );
                                            } else if (snapshot.data == null ||
                                                snapshot.data!.snapshot.value ==
                                                    null) {
                                              return Center(
                                                child: Text(
                                                    'No transactions available'),
                                              );
                                            } else {
                                              Map<dynamic, dynamic>? transmap =
                                                  snapshot.data!.snapshot.value
                                                      as Map<dynamic, dynamic>?;

                                              if (transmap == null ||
                                                  transmap.isEmpty) {
                                                return Center(
                                                  child: Text(
                                                      'No transactions available'),
                                                );
                                              }

                                              // Extract keys (transaction IDs)
                                              List<String> transactionKeys =
                                                  transmap.keys
                                                      .cast<String>()
                                                      .toList();

                                              // Sort transactions based on 'paymentDateTime'
                                              List<dynamic> sortedTransactions =
                                                  transmap.values.toList();
                                              sortedTransactions.sort((a, b) =>
                                                  b['paymentDateTime']
                                                      .compareTo(a[
                                                          'paymentDateTime']));

                                              dynamic formatDate(String date) {
                                                final newDate =
                                                    DateTime.parse(date);
                                                final formatter =
                                                    DateFormat('E, d MMMM');
                                                return formatter
                                                    .format(newDate);
                                              }

                                              return SizedBox(
                                                height: orientation ==
                                                        Orientation.portrait
                                                    ? constraints.maxHeight *
                                                        0.4
                                                    : constraints.maxHeight *
                                                        0.6,
                                                child: ListView.builder(
                                                  itemCount:
                                                      sortedTransactions.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    // Get transaction ID
                                                    dynamic transactionData =
                                                        sortedTransactions[
                                                            index];
                                                    // Find the transaction ID (key) corresponding to the current transaction data
                                                    String transactionId =
                                                        transactionKeys
                                                            .firstWhere(
                                                      (key) =>
                                                          transmap[key] ==
                                                          transactionData,
                                                    );

                                                    return Dismissible(
                                                      key: Key(
                                                          transactionId), // Use transaction ID as the unique key
                                                      onDismissed: (direction) {
                                                        if(total>=transactionData[
                                                                    'value']){
                                                        if (transactionData[
                                                                'type'] ==
                                                            'Income') {
                                                          ref
                                                              .child(user.uid)
                                                              .child('split')
                                                              .update({
                                                            'amount': map[
                                                                    'amount'] -
                                                                transactionData[
                                                                    'value'],
                                                          });
                                                        } else {
                                                          ref
                                                              .child(user.uid)
                                                              .child('split')
                                                              .update({
                                                            'expenses': map[
                                                                    'expenses'] -
                                                                transactionData[
                                                                    'value'],
                                                          });
                                                        } // Recalculate updated total amount
                                                        ref
                                                            .child(user.uid)
                                                            .child('split')
                                                            .child(
                                                                'allTransactions')
                                                            .child(
                                                                transactionId)
                                                            .remove();
                                                      }else{
                                                         ToastMessage().toastMessage('Not possible', Colors.red);
                                                         setState(() {
                                                           
                                                         });
                                                      }},
                                                      background: Container(
                                                        color: Colors.red,
                                                        child: Icon(
                                                            Icons.delete,
                                                            color:
                                                                Colors.white),
                                                        alignment: Alignment
                                                            .centerRight,
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 20.0),
                                                      ),
                                                      child: TransactionCard(
                                                        constraints:
                                                            constraints,
                                                        dateAndTime: formatDate(
                                                            transactionData[
                                                                'paymentDateTime']),
                                                        transactionAmount:
                                                            transactionData[
                                                                    'amount']
                                                                .toString(),
                                                        transactionName:
                                                            transactionData[
                                                                'name'],
                                                        width: constraints
                                                                .maxWidth *
                                                            0.05,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                        SizedBox(
                                          height: orientation ==
                                                  Orientation.portrait
                                              ? constraints.maxHeight * 0.04
                                              : constraints.maxHeight * 0.1,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
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
            })));
  }
}
