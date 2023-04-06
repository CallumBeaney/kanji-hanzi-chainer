import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rensou_flutter/buttons.dart';
import 'package:rensou_flutter/cubit/recognition_manager_cubit.dart';
import 'package:rensou_flutter/locator.dart';

import 'ink_input.dart';

class ZhTradInkView extends StatefulWidget {
  const ZhTradInkView({super.key});

  @override
  State<ZhTradInkView> createState() => _ZhTradInkViewState();
}

class _ZhTradInkViewState extends State<ZhTradInkView> {
  // final List<String> rensou = ['連', '想', '漢', '字', '蝶', '番'];
  final List<String> kanjiListPlaceholder = [
    '這',
    '裡',
    '是',
    '您',
    '的',
    '漢',
    '字',
    '列',
    '表',
    '。',
    '按',
    '漢',
    '字',
    '可',
    '獲',
    '取',
    '有',
    '關',
    '它',
    '的',
    '信',
    '息',
    '。',
  ]; // "This is your kanji list"
  final List<String> recognitionKanjiPlaceholder = ['請', '寫', '一', '個', '漢', '字']; // "Write a kanji"

  // TODO: https://pub.dev/packages/number_to_words_chinese/install
  int getScore(List<String> answers) {
    return answers.map((e) => locator<Dictionary>().containsKey(e)).where((r) => r == true).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('日本語'),
      //   toolbarHeight: 50,
      //   foregroundColor: Colors.grey[900],
      //   backgroundColor: Colors.grey[200],
      // ),
      body: SafeArea(
        child: BlocBuilder<RecognitionManagerCubit, RecognitionManagerState>(
          builder: (context, state) {
            // If there are no results yet, display the name.
            final results = state.results.isEmpty ? kanjiListPlaceholder : state.results;
            final mostRecent = state.comparator == null ? '字' : state.comparator.toString();
            final int score = getScore(state.results);

            return Column(
              children: [
                Expanded(
                  child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                    return Row(
                      children: [
                        // HIDDEN BUTTON IN TOP LEFT COLUMN
                        Expanded(
                          flex: 1,
                          child: Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  color: Color.fromARGB(255, 108, 108, 108),
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Icon(
                                      Icons.arrow_back,
                                      color: Color.fromARGB(255, 221, 221, 221),
                                    ),
                                  ),
                                ),
                              )),
                          // child: Align(
                          //     alignment: Alignment.topCenter,
                          //     child:
                          //     Opacity(
                          //         // nest here to ensure proper centring of KANJI LIST below
                          //         opacity: 0.0,
                          //         child: Padding(
                          //           padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                          //           child: Text(""),
                          //         )))
                        ),

                        // The USER KANJI LIST
                        Expanded(
                          flex: 5,
                          child: Column(
                            // TODO: May need: https://stackoverflow.com/questions/51066628/fading-edge-listview-flutter
                            // ^^ SO examples not working, however
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        return SingleChildScrollView(
                                          reverse: results.length > 25 ? true : false,
                                          child: Wrap(
                                            children: [
                                              ...results.map((e) => ListKanjiButton(kanji: e)),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // BUTTONS AT TOP RIGHT HAND CORNER
                        Column(
                          children: [
                            // Expanded(
                            //   flex: 1,
                            const Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(1, 10, 10, 10),
                                  child: InfoButton(text: "何"),
                                )),
                            if (score != 0) ...[
                              Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                    child: Container(
                                      width: 45,
                                      height: 45,
                                      color: const Color.fromARGB(255, 49, 49, 49),
                                      child: TextButton(
                                        onPressed: () {},
                                        child: Text(
                                          score.toString(),
                                          style: TextStyle(
                                            fontSize: (score > 99) ? 15 : 25,
                                            color: const Color.fromARGB(255, 214, 214, 214),
                                            height: 1.26,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
                            ]
                          ],
                        ),
                      ],
                    );
                  }),
                ),
                // The black middle button contains the most recent inputted kanji
                // which is then compared against the user's next input
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const PunctuationButton(sign: '、'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35.0),
                        child: ComparisonKanjiButton(kanji: mostRecent),
                      ),
                      const PunctuationButton(sign: '。'),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final kanji = state.candidates.isEmpty ? recognitionKanjiPlaceholder : state.candidates;
                      final width = constraints.maxWidth;
                      int numKanji = width ~/ 60; // manage number of guesses displayed to stop overflow.
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...kanji.take(numKanji).map(
                                (e) => RecognizedKanjiButton(
                                  kanji: e,
                                ),
                              ),
                        ],
                      );
                    },
                  ),
                ),
                const InkInput(),
              ],
            );
          },
        ),
      ),
    );
  }
}
