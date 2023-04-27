import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_school/cubits/StudentSelectedSubject_states.dart';
import 'package:my_school/cubits/StudentSelectedSubjects_cubit.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/studentDashboard_screen.dart';
import 'package:my_school/screens/studentLearnBySubjectScreen2.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/styles/colors.dart';

class StudentLearnBySubjectScreen1 extends StatefulWidget {
  final int Id;
  const StudentLearnBySubjectScreen1(this.Id);

  @override
  State<StudentLearnBySubjectScreen1> createState() =>
      _StudentLearnBySubjectScreen1State();
}

class _StudentLearnBySubjectScreen1State
    extends State<StudentLearnBySubjectScreen1> {
  @override
  Widget build(BuildContext context) {
    var lang = CacheHelper.getData(key: "lang").toString().toLowerCase();
    return Scaffold(
      appBar: appBarComponent(
        context,
        lang == "En" ? "Select Subject" : "إختر المادة",
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

                          return item.Checked == false
                              ? Container()
                              : Container(
                                  child: InkWell(
                                    onTap: () {
                                      CacheHelper.saveData(
                                          key: "yearSubjectId",
                                          value: item.YearSubjectId);
                                      CacheHelper.saveData(
                                          key: "subjectName",
                                          value: item.SubjectName);
                                      CacheHelper.saveData(
                                          key: "dir", value: item.dir);
                                      navigateTo(
                                          context,
                                          StudentLearnBySubjectScreen2(
                                            YearSubjectId: item.YearSubjectId,
                                            dir: item.dir,
                                            studentId: widget.Id,
                                            SubjectName: item.SubjectName,
                                          ));
                                    },
                                    child: Container(
                                      child: Card(
                                          elevation: 0,
                                          child: Directionality(
                                            textDirection: item.dir == "ltr"
                                                ? TextDirection.ltr
                                                : TextDirection.rtl,
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    border: Border.all(
                                                        color: defaultColor
                                                            .withOpacity(0.3)),
                                                    color: Colors.white),
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  children: [
                                                    item.ParentId != null
                                                        ? SizedBox(
                                                            width: 20,
                                                          )
                                                        : Container(),
                                                    Expanded(
                                                      child: Text(
                                                        item.SubjectName,
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color: defaultColor,
                                                            fontWeight: item
                                                                        .ParentId ==
                                                                    null
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .normal),
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                          )),
                                    ),
                                  ),
                                );
                        })),
                  ),
                ],
              )
            : Center(child: CircularProgressIndicator());
      }),
    );
  }
}

// Widget SubjectsList(StudentSelectedSubjectsCubit cubit) {
  
// }
