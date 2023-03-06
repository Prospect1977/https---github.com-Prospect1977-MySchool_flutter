import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_school/cubits/parentStudent_cubit.dart';
import 'package:my_school/cubits/parentStudent_states.dart';
import 'package:my_school/screens/add_student_screen.dart';

import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/studentDashboard_screen.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/routes.dart';
import 'package:my_school/shared/styles/colors.dart';

class ParentsLandingScreen extends StatelessWidget {
  const ParentsLandingScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ParentStudentCubit()..getStudents(),
      child: BlocConsumer<ParentStudentCubit, ParentStudentStates>(
          listener: (context, state) {
        if (state is UnAuthendicatedState) {
          navigateAndFinish(context, LoginScreen());
        }
      }, builder: (context, state) {
        var cubit = ParentStudentCubit.get(context);
        return Scaffold(
          appBar: (state is SuccessState)
              ? appBarComponent(context,
                  cubit.lang.toLowerCase() == "en" ? "Children" : "الأبناء")
              : appBarComponent(context, "الأبناء"),
          body: (state is SuccessState)
              ? ChildrenList(cubit: cubit)
              : Center(
                  child: CircularProgressIndicator(),
                ),
        );
      }),
    );
  }
}

class ChildrenList extends StatelessWidget {
  const ChildrenList({
    Key key,
    @required this.cubit,
  }) : super(key: key);

  final ParentStudentCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: cubit.lang.toLowerCase() == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 8.0,
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cubit.students.length,
                itemBuilder: (context, index) {
                  // cubit.students[index].fullName;
                  return Card(
                    elevation: 0,
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: defaultColor, width: 1),
                          borderRadius: BorderRadius.circular(5)),
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          navigateTo(
                              context,
                              StudentDashboardScreen(
                                Id: cubit.students[index].Id,
                                FullName: cubit.students[index].FullName,
                                Gender: cubit.students[index].Gender,
                                SchoolTypeId:
                                    cubit.students[index].SchoolTypeId,
                                YearOfStudyId:
                                    cubit.students[index].YearOfStudyId,
                              ));
                        },
                        child: ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(65),
                                  border:
                                      Border.all(color: Colors.grey, width: 2)),
                              child: cubit.students[index].Gender == null
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(55)),
                                      child: Icon(
                                        Icons.account_circle,
                                        size: 50,
                                        color: Colors.black38,
                                      ),
                                    )
                                  : (cubit.students[index].Gender == "Female"
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(55)),
                                          child: Image.asset(
                                            "assets/images/girlAvatar.jpg",
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(55)),
                                          child: Image.asset(
                                            "assets/images/boyAvatar.jpg",
                                            fit: BoxFit.cover,
                                          ),
                                        )),
                            ),
                            title: Text(
                              cubit.students[index].FullName,
                              style:
                                  TextStyle(fontSize: 22, color: Colors.purple),
                            )),
                      ),
                    ),
                  );
                },
              ),
            ),
            // ElevatedButton(onPressed: (){}), child: child)
            defaultButton(
                function: () {
                  navigateTo(context, AddStudentScreen());
                },
                text: cubit.lang.toLowerCase() == "en"
                    ? 'Add a Student'
                    : 'إضافة طالب',
                isUpperCase: false,
                borderRadius: 0,
                fontWeight: FontWeight.bold,
                background: Colors.green.shade700)
          ],
        ),
      ),
    );
  }
}
