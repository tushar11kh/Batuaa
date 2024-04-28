import 'package:flutter/material.dart';

class AiOutput extends StatelessWidget {
  const AiOutput({
    Key? key,
    required this.title,
    required this.paragraphs,
  }) : super(key: key);

  final List<String> title;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < title.length; i++)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title[i],
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10.0),
                Text(
                  paragraphs[i],
                  style: const TextStyle(fontSize: 18.0),
                ),
                const SizedBox(
                    height: 10.0), // Add some space between paragraphs
              ],
            ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class AiOutput extends StatelessWidget {
//   const AiOutput({
//     super.key,
//     required this.title,
//     required this.paragraphs,
//   });

//   final String title;
//   final List<String> paragraphs;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 10.0),
//         ...paragraphs.map((para) => Text(para)),
//       ],
//     );
//   }
// }
