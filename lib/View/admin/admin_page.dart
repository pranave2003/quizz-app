import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../ViewModel/admin/QuestionProvider.dart';
import 'Navigation/add_question_page.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      // Format the picked date to dd/MM/yyyy and store in selectedDate
      setState(() {
        selectedDate = DateFormat('dd/MM/yyyy').format(picked);
        print(selectedDate);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Provider.of<QuestionProvider>(context, listen: false).loadQuestions();
  }

  Future<void> _submitQuestions() async {
    await Provider.of<QuestionProvider>(context, listen: false).submitQuestionsToFirebase(selecteddata:selectedDate);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Questions submitted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionProvider = Provider.of<QuestionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Shedule'),
        actions: [
          Text("Date:${selectedDate??"No selected"}"),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              _selectDate(context);
              }
            ,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(selectedDate!=null){
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddQuestionPage(
                    quizDate: selectedDate,
                    onQuestionAdded: () => questionProvider.loadQuestions(), // Refresh questions
                  )));

          }
          else{
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('First pick your date')),
            );
          }


        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Expanded(
            child: questionProvider.questions.isEmpty
                ? Center(child: Text('No questions added yet.'))
                : ListView.builder(
              itemCount: questionProvider.questions.length,
              itemBuilder: (context, index) {
                final question = questionProvider.questions[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("${(index+1).toString()}."),
                            SizedBox(width: 5,),
                            Text(
                              question['question'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),

                        SizedBox(height: 8),
                        ...List.generate(question['options'].length, (i) {
                          return Row(
                            children: [
                              Text(
                                'Option ${i + 1}: ${question['options'][i]}',
                              ),
                            ],
                          );
                        }),
                        SizedBox(height: 8),
                        Text(
                          'Correct Option: Option ${question['correctOption'] + 1}',
                          style: TextStyle(color: Colors.green),
                        ),
                        Text(
                          'Date Added: ${question['dateAdded']}',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // Handle edit action
                                // You may create a separate EditQuestionPage to edit the question
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                questionProvider.deleteQuestion(index);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _submitQuestions,
              child: Text('Submit Questions to Firebase'),
            ),
          ),
        ],
      ),
    );
  }
}
