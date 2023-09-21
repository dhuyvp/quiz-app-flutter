import 'package:quiz_app/model/question_model.dart';
import 'package:dio/dio.dart';

List<QuestionModel> questions = [];

//////////////////////////
void getData() async {
  try {
    final dio = Dio();
    const String url = 'https://opentdb.com/api.php?amount=5&type=multiple';
    var response = await dio.get(url);
    questions.add(QuestionModel(response.data['results'][0]['question'], {
      "1": false,
      "2": false,
      "3": true,
      "4": false,
    }));

    // const String url = 'https://opentdb.com/api.php?amount=5&type=multiple';
    // var result = await http.get(Uri.parse(url));

    // print(questions[0].question);
    print('Data: ');
    print(response.data);
  } catch (e) {
    print('Error: ' + e.toString());
  }
}

void main() {
  getData();

  print('\n\nQuestions: ');
  print(questions);
}
