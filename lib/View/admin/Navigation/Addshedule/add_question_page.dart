import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../ViewModel/admin/QuestionProvider.dart';

class Createaptitude_sub extends StatefulWidget {
  final  quizDate;
  final Function onQuestionAdded;

  Createaptitude_sub({required this.quizDate, required this.onQuestionAdded});

  @override
  _Createaptitude_subState createState() => _Createaptitude_subState();
}

class _Createaptitude_subState extends State<Createaptitude_sub> {
  final _formKey = GlobalKey<FormState>();
  String questionText = '';
  List<String> options = List.filled(4, '');
  int correctOption = 0;



  @override
  Widget build(BuildContext context) {
    final questionProvider = Provider.of<QuestionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Question'),
        actions: [
          // IconButton(
          //     onPressed: () => _selectDate(context),
          //     icon: Icon(Icons.calendar_month))
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Date:${widget.quizDate ?? "please pick"}",
                    style: TextStyle(color: Colors.red),
                  )
                ],
              ),
              // Question text field
              TextFormField(
                decoration: InputDecoration(labelText: 'Question'),
                onChanged: (val) => questionText = val,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a question';
                  }
                  return null;
                },
              ),
              // Options text fields
              for (int i = 0; i < 4; i++)
                TextFormField(
                  decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                  onChanged: (val) => options[i] = val,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Option ${i + 1}';
                    }
                    return null;
                  },
                ),
              // Correct option selection
              Row(children: [ Text("Choose currect option",style: TextStyle(fontSize: 30),)],),
              Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: RadioListTile(
                      title: Text('Option ${index + 1}'),
                      value: index,
                      groupValue: correctOption,
                      onChanged: (value) {
                        setState(() {
                          correctOption = value as int;
                        });
                      },
                    ),
                  );
                }),
              ),
              // Add Question button
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                      questionProvider.saveQuestion(
                        questionText,
                        options,
                        correctOption,
                        widget.quizDate,
                      );
                      widget.onQuestionAdded(); // Refresh questions in AdminPage
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Question Added')),
                      );


                      Navigator.pop(context); //

                  }
                },
                child: Text('Add Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
