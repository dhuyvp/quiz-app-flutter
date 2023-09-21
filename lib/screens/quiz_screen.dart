import 'package:flutter/material.dart';
// import 'package:quiz_app/data/questions_example.dart';
// import 'package:quiz_app/data/questions_api.dart';
import 'package:quiz_app/model/question_model.dart';
import 'package:quiz_app/screens/result_screen.dart';
import 'package:quiz_app/ui/shared/color.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int score = 0;
  bool btnPressed = false;
  PageController? _controller;
  String btnText = "Next Question";
  bool answered = false;
  bool isLoadingQuestions = false;

  late Future<List<Question>> futureQuestion;
  List<QuestionModel> questions = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
    _controller = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: AppColor.pripmaryColor,
        body: isLoadingQuestions
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(18.0),
                child: PageView.builder(
                  controller: _controller!,
                  onPageChanged: (page) {
                    if (page == questions.length - 1) {
                      setState(() {
                        btnText = "See Results";
                      });
                    }
                    setState(() {
                      answered = false;
                    });
                  },
                  itemBuilder: (context, index) {
                    return SingleChildScrollView(
                      physics: const ScrollPhysics(),
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              "Question ${index + 1}/${questions.length}",
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28.0,
                              ),
                            ),
                          ),
                          const Divider(
                            color: Colors.white,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          SizedBox(
                            width: double.infinity,
                            // height: 200.0,
                            child: Text(
                              "${questions[index].question}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22.0,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 50.0,
                          ),
                          for (int i = 0;
                              i < questions[index].answers!.length;
                              i++)
                            Container(
                              width: double.infinity,
                              height: 100.0,
                              margin: const EdgeInsets.only(
                                  bottom: 20.0, left: 10.0, right: 10.0),
                              child: RawMaterialButton(
                                padding: const EdgeInsets.all(10.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                fillColor: btnPressed
                                    ? questions[index]
                                            .answers!
                                            .values
                                            .toList()[i]
                                        ? Colors.green
                                        : Colors.red
                                    : AppColor.secondaryColor,
                                onPressed: !answered
                                    ? () {
                                        if (questions[index]
                                            .answers!
                                            .values
                                            .toList()[i]) {
                                          score++;
                                          print("yes");
                                        } else {
                                          print("no");
                                        }
                                        setState(() {
                                          btnPressed = true;
                                          answered = true;
                                        });
                                      }
                                    : null,
                                child: Text(
                                    questions[index].answers!.keys.toList()[i],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                    )),
                              ),
                            ),
                          const SizedBox(
                            height: 40.0,
                          ),
                          Container(
                              alignment: Alignment.bottomCenter,
                              padding: const EdgeInsets.all(10.0),
                              child: RawMaterialButton(
                                onPressed: () {
                                  if (_controller!.page?.toInt() ==
                                      questions.length - 1) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ResultScreen(score)));
                                  } else {
                                    _controller!.nextPage(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        curve: Curves.easeInExpo);

                                    setState(() {
                                      btnPressed = false;
                                    });
                                  }
                                },
                                shape: const StadiumBorder(),
                                fillColor: Colors.blue,
                                padding: const EdgeInsets.all(18.0),
                                elevation: 0.0,
                                child: Text(
                                  btnText,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ))
                        ],
                      ),
                    );
                  },
                  itemCount: questions.length,
                )),
      ),
    );
  }

  Future<void> fetchData() async {
    setState(() {
      isLoadingQuestions = true;
    });

    try {
      // final response =
      // await http.get(Uri.parse('https://opentdb.com/api.php?amount=10'));
      final response = await http.get(Uri.parse(
          'https://quizapi.io/api/v1/questions?apiKey=o4cyXTyUzwBiKZkKVlE0vhjwsfxD5cwriPE6U49v&limit=10'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        List<dynamic> results = jsonResponse;

        questions = results.map((result) {
          String question = result['question'];

          Map<String, bool> answers = {};

          result['answers'].forEach((key, value) {
            if (value != null) {
              answers[value] =
                  (result['correct_answers'][key + '_correct'] == 'true'
                      ? true
                      : false);
            }
            // print(value);
            // print(answers[value]);
          });

          // question =
          //     'aasada\nadafasda\ndsadasa\ndsadasa\ndsadasa\ndsadasa\ndsadasa\ndsadasa\ndsadasa\ndsadasa\n';

          return QuestionModel(question, answers);
        }).toList();
      } else {
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoadingQuestions = false;
      });
    }
  }
}
