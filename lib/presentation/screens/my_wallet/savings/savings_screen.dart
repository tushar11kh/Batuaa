import 'package:batuaa/colors.dart';
import 'package:batuaa/presentation/screens/my_wallet/savings/automatic_investment_screen.dart';
import 'package:batuaa/presentation/screens/my_wallet/savings/manual_investment_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../widgets/savings_balance_card.dart';
import '../../../widgets/null_error_message_widget.dart';
import '../../../widgets/transaction_card.dart';
import 'package:intl/intl.dart';
import '../../../widgets/saving_card.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref().child('Users');
  final user = FirebaseAuth.instance.currentUser!;

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
                                    height: constraints.maxHeight * 0.03,
                                  ),
                                  const Text(
                                    'Recent Savings',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  SizedBox(
                                    height: constraints.maxHeight * 0.03,
                                  ),
                                  map['savingInvestments'] == null
                                      ? const Center(
                                          child: Text('No savings yet'),
                                        )
                                      : StreamBuilder(
                                          stream: ref
                                              .child(user.uid)
                                              .child('split')
                                              .child('savingInvestments')
                                              .onValue,
                                          builder: (context,
                                              AsyncSnapshot<DatabaseEvent>
                                                  snapshot) {
                                            if (!snapshot.hasData) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                color: kGreenColor,
                                              ));
                                            } else {
                                              Map<dynamic, dynamic> map =
                                                  snapshot.data!.snapshot.value
                                                      as dynamic;
                                              List<dynamic> list = [];
                                              list.clear();
                                              list = map.values.toList();
                                              list.sort((a, b) => b[
                                                      'paymentDateTime']
                                                  .compareTo(
                                                      a['paymentDateTime']));

                                              dynamic formatDate(String date) {
                                                final dynamic newDate =
                                                    DateTime.parse(date);
                                                final DateFormat formatter =
                                                    DateFormat(
                                                        'E, d MMMM,   hh:mm a');
                                                final dynamic formatted =
                                                    formatter.format(newDate);
                                                return formatted;
                                              }

                                              return Row(
                                                children: [
                                                  Expanded(
                                                    child: SizedBox(
                                                      height: orientation ==
                                                              Orientation
                                                                  .portrait
                                                          ? constraints
                                                                  .maxHeight *
                                                              0.4
                                                          : constraints
                                                                  .maxHeight *
                                                              0.7,
                                                      child: ListView.builder(
                                                          itemCount: snapshot
                                                              .data!
                                                              .snapshot
                                                              .children
                                                              .length,
                                                          itemBuilder:
                                                              ((context,
                                                                  index) {
                                                            return TransactionCard(
                                                                constraints:
                                                                    constraints,
                                                                dateAndTime:
                                                                    formatDate(list[
                                                                            index]
                                                                        [
                                                                        'paymentDateTime']),
                                                                transactionAmount:
                                                                    '- ${list[index]['amount']}',
                                                                transactionName:
                                                                    list[index][
                                                                        'companyName'],
                                                                width: constraints
                                                                        .maxWidth *
                                                                    0.05);
                                                          })),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                  SizedBox(
                                    height: constraints.maxHeight * 0.04,
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
