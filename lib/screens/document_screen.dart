import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DocumentScreen extends StatelessWidget {
  const DocumentScreen({@required this.Url, @required this.Title, Key key})
      : super(key: key);
  final String Url;
  final String Title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarComponent(context, this.Title),
        body: WebView(
          initialUrl: Url,
          javascriptMode: JavascriptMode.unrestricted,
        ));
  }
}
