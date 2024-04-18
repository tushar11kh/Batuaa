import 'package:batuaa/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../logic/open_camera.dart';
import '../../../widgets/savings_balance_card.dart';
import '../../../widgets/card_alt.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/saving_card.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_gemini/google_gemini.dart';
import '../../../widgets/null_error_message_widget.dart';
import '../../../widgets/transaction_card.dart';
import 'add_expenses_payer.dart';
import '../../auth/gemini_key.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String textChat = "sugestion come here"; //stores messages
  final DatabaseReference ref = FirebaseDatabase.instance.ref().child('Users');
  final user = FirebaseAuth.instance.currentUser!;
  final gemini = GoogleGemini(apiKey: GeminiApiKey.apiKey);
  void queryText({required String query}) {
    setState(() {
      // loading = true;
      textChat = query;
      // _textController.clear();
    });
    gemini.generateFromText(query).then((value) {
      //sets state of loader->false ie loader wont be displayed any more
      //adds respone value to textChat list based on role(gemini)
      setState(() {
        // loading = false;
        textChat = value.text;
      });
      // scrollToEnd();
    }).onError((error, stackTrace) {
      //loader->false; it will stop showing up on screen
      //error will added to chat from Gemini's side
      // loading = false;
      textChat = error.toString();
      // scrollToEnd();
    });
  }
  // void scrollToEnd() {
  //   _scroll.jumpTo(_scroll.position.maxScrollExtent);
  // }

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
                  body: ChangeNotifierProvider(
                create: (_) => CameraController(),
                child: Consumer<CameraController>(
                    builder: (context, provider, child) {
                  return SafeArea(
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return OrientationBuilder(
                          builder:
                              (BuildContext context, Orientation orientation) {
                            return SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    BalanceCard(
                                      amount:
                                          map['expenses'].toStringAsFixed(0),
                                      constraints:
                                          orientation == Orientation.portrait
                                              ? constraints.maxHeight * 0.2
                                              : constraints.maxHeight * 0.8,
                                    ),
                                    SizedBox(
                                      height: constraints.maxHeight * 0.03,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomCard(
                                          orientation: orientation,
                                          verHeight:
                                              constraints.maxHeight * 0.15,
                                          horiHeight:
                                              constraints.maxHeight * 0.5,
                                          verWidth:
                                              constraints.maxHeight * 0.23,
                                          horiWidth: constraints.maxWidth * 0.4,
                                          cardTitle: 'Income',
                                          cardBalance: map['expenses']
                                              .toStringAsFixed(0),
                                        ),
                                        CustomCard(
                                          orientation: orientation,
                                          verHeight:
                                              constraints.maxHeight * 0.15,
                                          horiHeight:
                                              constraints.maxHeight * 0.5,
                                          verWidth:
                                              constraints.maxHeight * 0.23,
                                          horiWidth: constraints.maxWidth * 0.4,
                                          cardTitle: 'Spendings',
                                          cardBalance:
                                              map['expensesSpendings'] == null
                                                  ? 0.toString()
                                                  : map['expensesSpendings']
                                                      .toStringAsFixed(0),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: constraints.maxHeight * 0.03,
                                    ),
                                    const Text(
                                      'Get Suggestations on your',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    SizedBox(
                                      height: constraints.maxHeight * 0.03,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            queryText(
                                                query:
                                                    "give me suggestion about expenses control");
                                          },
                                          child: SavingsCard(
                                            orientation: orientation,
                                            constraints: constraints,
                                            iconName: Icons.trending_down,
                                            title: 'Expences',
                                            verHeight:
                                                constraints.maxHeight * 0.15,
                                            horiHeight:
                                                constraints.maxHeight * 0.5,
                                            verWidth:
                                                constraints.maxHeight * 0.25,
                                            horiWidth:
                                                constraints.maxWidth * 0.4,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            queryText(
                                                query:
                                                    "give me suggestion about investment");
                                          },
                                          child: Stack(
                                            children: [
                                              SavingsCard(
                                                orientation: orientation,
                                                constraints: constraints,
                                                iconName: Icons.trending_up,
                                                title: 'Investment',
                                                verHeight:
                                                    constraints.maxHeight *
                                                        0.15,
                                                horiHeight:
                                                    constraints.maxHeight * 0.5,
                                                verWidth:
                                                    constraints.maxHeight *
                                                        0.25,
                                                horiWidth:
                                                    constraints.maxWidth * 0.4,
                                              ),
                                              Positioned(
                                                  left: orientation ==
                                                          Orientation.portrait
                                                      ? 42
                                                      : 125,
                                                  top: orientation ==
                                                          Orientation.portrait
                                                      ? 20
                                                      : 12,
                                                  child: const Icon(
                                                    Icons.update,
                                                    color: Colors.white,
                                                    size: 22,
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: constraints.maxHeight * 0.03,
                                    ),
                                    const Text(
                                      'Suggestations',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    SizedBox(
                                      height: constraints.maxHeight * 0.03,
                                    ),
                                    Text(textChat),
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
                  );
                }),
              ));
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
