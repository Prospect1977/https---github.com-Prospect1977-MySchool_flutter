import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_school/cubits/StudentSelectedSubject_states.dart';
import 'package:my_school/cubits/StudentSelectedSubjects_cubit.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/studentDashboard_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/styles/colors.dart';

class StudentSelectedSubjectsScreen extends StatefulWidget {
  final int Id;
  const StudentSelectedSubjectsScreen(this.Id);

  @override
  State<StudentSelectedSubjectsScreen> createState() =>
      _StudentSelectedSubjectsScreenState();
}

class _StudentSelectedSubjectsScreenState
    extends State<StudentSelectedSubjectsScreen> {
  @override
  Widget build(BuildContext context) {
    var lang = CacheHelper.getData(key: "lang").toString().toLowerCase();
    return Scaffold(
      appBar: appBarComponent(
        context,
        lang == "En" ? "Available Subjects" : "المواد المتاحة",
        /*backButtonPage: CacheHelper.getData(key: "roles") == "Student"
              ? StudentDashboardScreen()
              : StudentDashboardScreen(Id: widget.Id)*/
      ),
      body: SubjectsList(widget.Id),
    );
  }
}

class SubjectsList extends StatefulWidget {
  final int Id;
  const SubjectsList(this.Id);

  @override
  State<SubjectsList> createState() => _SubjectsListState();
}

class _SubjectsListState extends State<SubjectsList> {
  @override
  List<int> _selectedItems = [];
  bool _isChanged = false;
  var lang = CacheHelper.getData(key: "lang").toString().toLowerCase();
  //bool _isCurrentItemSelected = false;
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          StudentSelectedSubjectsCubit(widget.Id)..getSubjectsList(),
      child: BlocConsumer<StudentSelectedSubjectsCubit,
          StudentSelectedSubjectsStates>(listener: (context, state) {
        if (state is UnAuthendicatedState) {
          navigateTo(context, LoginScreen());
        }
        var cubit = StudentSelectedSubjectsCubit.get(context);
        if (state is SuccessState) {
          for (var i = 0; i < cubit.StudentSubjectsList.length; i++) {
            if (cubit.StudentSubjectsList[i].Checked) {
              setState(() {
                _selectedItems.add(cubit.StudentSubjectsList[i].SubjectId);
              });
            }
          }
        }
      }, builder: (context, state) {
        var cubit = StudentSelectedSubjectsCubit.get(context);

        return (state is SuccessState)
            ? Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: cubit.StudentSubjectsList.length,
                        itemBuilder: ((context, index) {
                          var item = cubit.StudentSubjectsList[index];

                          return Container(
                            child: InkWell(
                              onTap: () {
                                if (!_selectedItems.contains(item.SubjectId)) {
                                  setState(() {
                                    _selectedItems.add(item.SubjectId);
                                    _isChanged = true;
                                  });
                                } else {
                                  setState(() {
                                    _selectedItems.removeWhere(
                                        (SId) => SId == item.SubjectId);
                                    _isChanged = true;
                                  });
                                }
                                print(_selectedItems);
                              },
                              child: Container(
                                child: Card(
                                    elevation: 3,
                                    child: Directionality(
                                      textDirection: item.dir == "ltr"
                                          ? TextDirection.ltr
                                          : TextDirection.rtl,
                                      child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: _selectedItems
                                                      .contains(item.SubjectId)
                                                  ? defaultColor
                                                  : Colors.white),
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              item.ParentId != null
                                                  ? SizedBox(
                                                      width: 20,
                                                    )
                                                  : Container(),
                                              Text(
                                                item.SubjectName,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color:
                                                        _selectedItems.contains(
                                                                item.SubjectId)
                                                            ? Colors.white
                                                            : Colors.black87,
                                                    fontWeight: item.ParentId ==
                                                            null
                                                        ? FontWeight.bold
                                                        : FontWeight.normal),
                                              ),
                                            ],
                                          )),
                                    )),
                              ),
                            ),
                          );
                        })),
                  ),
                  defaultButton(
                      function: _isChanged
                          ? () {
                              StudentSelectedSubjectsCubit.get(context)
                                ..saveSubjectsList(context, _selectedItems);
                              setState(() {
                                _isChanged = false;
                              });
                            }
                          : null,
                      borderRadius: 0,
                      text: lang == "en" ? "Save Changes" : "حفظ التعديلات",
                      background: _isChanged ? Colors.black87 : Colors.black54),
                ],
              )
            : Center(child: CircularProgressIndicator());
      }),
    );
  }
}

// Widget SubjectsList(StudentSelectedSubjectsCubit cubit) {
  
// }
