import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/dio_helper.dart';

import '../models/ticket_model.dart';
import 'package:intl/intl.dart' as intl;

class AdminTicketsScreen extends StatefulWidget {
  const AdminTicketsScreen({Key key}) : super(key: key);

  @override
  State<AdminTicketsScreen> createState() => _AdminTicketsScreenState();
}

class _AdminTicketsScreenState extends State<AdminTicketsScreen> {
  List<Ticket> model;
  String _filterBy = "unresolved";
  void getData() async {
    setState(() {
      model = null;
    });
    await DioHelper.getData(url: 'Tickets', query: {"FilterBy": _filterBy})
        .then((value) {
      if (value.data["status"] == false) {
        showToast(text: value.data['message'], state: ToastStates.ERROR);
      }
      setState(() {
        model = (value.data["data"] as List)
            .map((item) => Ticket.fromJson(item))
            .toList();
      });
    });
  }

  void switchResolved(int id) async {
    await DioHelper.postData(
        url: 'Tickets/SwitchResolved',
        token: CacheHelper.getData(key: 'token'),
        lang: CacheHelper.getData(key: 'lang'),
        query: {"Id": id, "ResolvedDate": DateTime.now()}).then((value) {
      if (value.data["status"] == false) {
        showToast(text: value.data['message'], state: ToastStates.ERROR);
      }
      setState(() {
        var item = model.firstWhere((element) => element.id == id);
        if (item.resolved == false) {
          item.resolveDate = DateTime.now();
        }
        item.resolved = !item.resolved;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        getData();
      },
      child: Scaffold(
        appBar: appBarComponent(context, "Tickets"),
        body: model == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    frame(
                        borderColor: Colors.black26,
                        textDirection: TextDirection.ltr,
                        title: "Show",
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_filterBy != "all") {
                                      _filterBy = "all";
                                      getData();
                                    }
                                  });
                                },
                                child: Container(
                                  child: Text(
                                    'All',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: _filterBy == "all"
                                            ? Colors.green.shade800
                                            : Colors.black54),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: _filterBy == "all"
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.black.withOpacity(0.05),
                                      border: Border.all(
                                          color: _filterBy == "all"
                                              ? Colors.green.withOpacity(0.85)
                                              : Colors.black38),
                                      borderRadius: BorderRadius.circular(5)),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_filterBy != "unresolved") {
                                      _filterBy = "unresolved";
                                      getData();
                                    }
                                  });
                                },
                                child: Container(
                                  child: Text(
                                    'Unresolved',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: _filterBy == "unresolved"
                                            ? Colors.green.shade800
                                            : Colors.black54),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: _filterBy == "unresolved"
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.black.withOpacity(0.05),
                                      border: Border.all(
                                          color: _filterBy == "unresolved"
                                              ? Colors.green.withOpacity(0.85)
                                              : Colors.black38),
                                      borderRadius: BorderRadius.circular(5)),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_filterBy != "resolved") {
                                      _filterBy = "resolved";
                                      getData();
                                    }
                                  });
                                },
                                child: Container(
                                  child: Text(
                                    'Resolved',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: _filterBy == "resolved"
                                            ? Colors.green.shade800
                                            : Colors.black54),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: _filterBy == "resolved"
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.black.withOpacity(0.05),
                                      border: Border.all(
                                          color: _filterBy == "resolved"
                                              ? Colors.green.withOpacity(0.85)
                                              : Colors.black38),
                                      borderRadius: BorderRadius.circular(5)),
                                ),
                              ),
                            ],
                          ),
                        )),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.separated(
                          separatorBuilder: (context, index) => Divider(
                            thickness: 1,
                          ),
                          itemCount: model.length,
                          itemBuilder: (context, index) {
                            var item = model[index];
                            return Directionality(
                                textDirection: item.descriptionDir == "ltr"
                                    ? TextDirection.ltr
                                    : TextDirection.rtl,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        GestureDetector(
                                            onTap: () async {
                                              await FlutterPhoneDirectCaller
                                                  .callNumber(item.phoneNumber);
                                            },
                                            child: Text(
                                              item.fullName,
                                              style: TextStyle(
                                                  color: Colors.blue.shade700,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                color: Colors.black45,
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: Text(
                                              item.roles[0],
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ))
                                      ],
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Text(
                                        intl.DateFormat('dd/MM/yyyy | HH:mm')
                                            .format(item.publishDate)
                                            .toString(),
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    Text(item.description),
                                    if (item.fileUrl != null)
                                      SizedBox(
                                        height: 6,
                                      ),
                                    if (item.fileUrl != null)
                                      Container(
                                        width: double.infinity,
                                        child: Image.network(item.urlSource ==
                                                "web"
                                            ? '${webUrl}Assets/tickets/${item.fileUrl}'
                                            : '${baseUrl0}Assets/tickets/${item.fileUrl}'),
                                      ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            await switchResolved(item.id);
                                          },
                                          child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 2, horizontal: 8),
                                              decoration: BoxDecoration(
                                                  color: item.resolved
                                                      ? Colors.green
                                                          .withOpacity(0.2)
                                                      : Colors.amber
                                                          .withOpacity(0.05),
                                                  border: Border.all(
                                                      color: item.resolved
                                                          ? Colors.green
                                                              .withOpacity(0.85)
                                                          : Colors.amber),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Text(
                                                item.resolved
                                                    ? 'Resolved'
                                                    : 'Unresolved',
                                                style: TextStyle(
                                                    color: item.resolved
                                                        ? Colors.green.shade800
                                                        : Colors
                                                            .amber.shade800),
                                              )),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        if (item.resolved)
                                          Directionality(
                                            textDirection: TextDirection.ltr,
                                            child: Text(
                                              intl.DateFormat(
                                                      'dd/MM/yyyy | HH:mm')
                                                  .format(item.resolveDate)
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.black45,
                                                  fontStyle: FontStyle.italic),
                                            ),
                                          ),
                                      ],
                                    )
                                  ],
                                ));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
