import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';

class AdminPayToTeacherScreen extends StatefulWidget {
  AdminPayToTeacherScreen(this.teacherId, {Key key}) : super(key: key);
  int teacherId;
  @override
  State<AdminPayToTeacherScreen> createState() =>
      _AdminPayToTeacherScreenState();
}

class _AdminPayToTeacherScreenState extends State<AdminPayToTeacherScreen> {
  DateTime selectedDate = DateTime.now().subtract(Duration(days: 9));
  TextEditingController _dateController = TextEditingController();
  String amountToPay;
  bool isDirty = false;
  void getData() async {
    //GetTeacherPayment(int TeacherId, DateTime UpTo)
    setState(() {
      amountToPay = null;
    });
    await DioHelper.getData(
            url: 'Admin/GetTeacherPayment',
            query: {'TeacherId': widget.teacherId, 'UpTo': selectedDate},
            token: CacheHelper.getData(key: 'token'))
        .then((value) {
      if (value.data['status'] == true) {
        setState(() {
          amountToPay = value.data['data'];
          // amountToPay = 0;
        });
      } else {
        showToast(text: value.data['message'], state: ToastStates.ERROR);
      }
    });
  }

  void save() async {
    //PayToTeacher(int TeacherId, DateTime UpTo, DateTime PaymentDate)
    await DioHelper.postData(
            url: 'Admin/PayToTeacher',
            query: {
              'TeacherId': widget.teacherId,
              'UpTo': selectedDate,
              'PaymentDate': DateTime.now()
            },
            token: CacheHelper.getData(key: 'token'))
        .then((value) {
      if (value.data['status'] == true) {
        setState(() {
          amountToPay = '0';
        });
      } else {
        showToast(text: value.data['message'], state: ToastStates.ERROR);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
    getData();
  }

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
      });
      getData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(context, "Payoff Teacher"),
      body: RefreshIndicator(
        onRefresh: () async {
          getData();
        },
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Center(
              child: Column(
            children: [
              amountToPay == null
                  ? CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.all(25),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: defaultColor,
                        foregroundColor: Colors.white,
                        child: Text(
                          '${amountToPay} EGP',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
              SizedBox(
                height: 10,
              ),
              defaultFormField(
                  controller: _dateController,
                  type: TextInputType.text,
                  label: "Select Date",
                  suffix: Icons.calendar_month_sharp,
                  onTap: () => _selectDate(context)),
              SizedBox(
                height: 15,
              ),
              defaultButton(
                  function: () {
                    save();
                  },
                  text: "Pay",
                  background: Colors.green,
                  foregroundColor: Colors.white)
            ],
          )),
        ),
      ),
    );
  }
}
