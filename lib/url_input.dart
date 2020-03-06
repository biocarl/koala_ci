import 'package:flutter/material.dart';

class UrlInput extends StatefulWidget {

  @override
  _UrlInputState createState() {
    return _UrlInputState();
  }
}

class _UrlInputState extends State<UrlInput> {
  var inputTextController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setup your koala'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: TextField(
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20.0),
                    labelText: "Provide your goCD server url",
                    hintText: "https://go ..."),
                style: TextStyle(
                  fontSize: 22.0,
                  //color: Theme.of(context).accentColor,
                ),
                controller: inputTextController,
                cursorWidth: 5.0,
                autocorrect: true,
                autofocus: true,
                maxLines: 1,
                //onSubmitted: ,
              ),
            ),
            Center(
                child: new ButtonBar(mainAxisSize: MainAxisSize.min,
                    // this will take space as minimum as posible(to center)
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context, inputTextController.text);
                        },
                        child: Text('Submit',
                            style: new TextStyle(
                              fontSize: 15.0,
                            )),
                      ),
                    ])),
          ],
        ),
      ),
    );
  }
}
