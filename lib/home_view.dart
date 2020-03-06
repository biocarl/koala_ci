import 'dart:async';
import 'dart:convert' as convert;

import 'package:KoalaCI/koala_view.dart';
import 'package:KoalaCI/url_input.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';



class HomeView extends StatefulWidget {
  HomeView({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomeViewState createState() => new _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Koala animation
  bool _isPaused = false;
  String _animation = "";
  FlareControls _animationController = FlareControls();

  // Status updates
  List<TextSpan> _buildStatusSpans;
  String _url;
  static const int FETCH_INTERVAL = 3;

  //<TWU specific> specific
  String _currentTeam;
  var _teams = <String>['team1', 'team2', 'team3', 'team4', 'team5', 'team6'];

  @override
  void initState() {
    super.initState();
    new Timer.periodic(Duration(seconds: FETCH_INTERVAL),
            (Timer t) => parseBuildResultsFromJson());
    requireUrlFromUser();
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey,
      body: new Stack(
        children: [
          inflateTeamNameDropdown(),
          inflateReactionToBuildStatus(),
          KoalaView( isPaused: _isPaused, animation: _animation, controller: _animationController),
          inflateBuildStatusDescription()
        ],
      ),
    );
  }

  inflateTeamNameDropdown(){
   return Positioned.fill(
         child: Align(
             alignment: FractionalOffset.topCenter,
             child: Padding(
                 padding: EdgeInsets.all(50.0),
                 child: DropdownButton<String>(
                   value: _currentTeam,
                   onChanged: (String newValue) {
                     setState(() {
                       _currentTeam = newValue;
                       _animation = "";
                       _isPaused = true;
                     });
                   },
                   items: _teams
                       .map<DropdownMenuItem<String>>((String value) {
                     return DropdownMenuItem<String>(
                       value: value,
                       child: Text(value,
                           style: TextStyle(fontWeight: FontWeight.bold)),
                     );
                   }).toList(),
                 ))));
  }

  inflateBuildStatusDescription() {
    return Positioned.fill(
      child: new Align(
          alignment: FractionalOffset.bottomCenter,
          child: RichText( text: TextSpan( style: TextStyle(fontSize: 10), children:_buildStatusSpans, )
    )
    ),
    );
  }

  Future<List> fetchData() async {
    var json_list = List();
    if(_url == null || _url.isEmpty) {
      return json_list;
    }

    try {
      var request1 = await get(getUrlForCurrentTeam(),
          headers: {
            'Accept': 'application/vnd.go.cd.v3+json'
          }
      );

      // Test
      // print("${getUrlForCurrentTeam()} $_currentTeam");
      // json_list.add(convert.jsonDecode(await loadAsset()));
      // return json_list;

      if (request1.statusCode == 200) {
        json_list.add(convert.jsonDecode(request1.body));
      } else {
        print("Car Status: ${request1.statusCode}");
        return List();
      }
    } catch(e){
      print("Car Error: ${e.toString()}");
    }
    return json_list;
  }

  parseBuildResultsFromJson() {
    print("${getUrlForCurrentTeam()}");
    fetchData().then((data) {
      if (data.isNotEmpty) {
        var overallSuccess = true;
        var isPending = false;
        _buildStatusSpans = new List();

        for (int i = 2; i < 5; i++) {
          //<TWU specific> - skip the first two pipelines i=0,1
          var pipeline = data[0]["_embedded"]["pipelines"][i];
          var pipelineName = pipeline["name"];
          _buildStatusSpans.add(TextSpan(
              text: "$pipelineName \n",
              style: TextStyle(fontWeight: FontWeight.bold)));
          pipeline["_embedded"]["instances"][0]["_embedded"]["stages"]
              .forEach((testType) {
            var name = testType["name"];
            var status = testType["status"];

            //<TWU specific>, skip manually triggered builds
            if (name == "deploy-to-QA" ||
                name == "deploy-to-staging" ||
                name == "deploy-to-prod") {
              return;
            }

            _buildStatusSpans.add(TextSpan(
                text: "\t \t $name: \t",
                style: TextStyle(fontStyle: FontStyle.italic)));

            if (status == "Failed" || status == "Cancelled") {
              overallSuccess = false;
              _buildStatusSpans.add(TextSpan(
                  text: "$status",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)));
            } else if (status == "Building") {
              _buildStatusSpans.add(TextSpan(
                  text: "$status",
                  style: TextStyle(
                      color: Colors.yellow, fontWeight: FontWeight.bold)));
              isPending = true;
            } else if (status == "Passed") {
              _buildStatusSpans.add(TextSpan(
                  text: "$status",
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold)));
            } else if (status == "Unknown") {
              _buildStatusSpans.add(TextSpan(
                  text: "Wait",
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold)));
            }

            _buildStatusSpans.add(TextSpan(text: "\n"));
          });
        }

        String animation = "";
        if (isPending) {
          animation = "";
        } else {
          if (overallSuccess) {
            animation = "love";
          } else {
            animation = "laugh";
          }
        }

        setState(() {
          _animation = animation;
          _isPaused = false;
          _animationController.play(_animation);
          _buildStatusSpans.add(TextSpan(text: "\n\n"));
        });
      } else {
        print('Request failed with status');
        // Resetting url
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString('cd-url', "");
        });
      }
    });
  }

  requireUrlFromUser() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String url = "";
      var prefs = await SharedPreferences.getInstance();
      String storedUrl = prefs.getString('cd-url');
      if (storedUrl != null && storedUrl.isNotEmpty) {
        url = storedUrl;
      }else{
        url = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UrlInput()),
        );
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString('cd-url', url);
        });
      }

      setState(() {
        _currentTeam = obtainTeamFromUrl(url);
        _url = url;
      });
    });
  }

  inflateReactionToBuildStatus() {
   return Positioned.fill(
        top: 120,
        child: Text( (_animation == "love") ? "Success!" : (_animation == "laugh" ? "... heeeelp!" : "be patient..."),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
                fontSize: 50)));
  }

  //<TWU specific> specific
  String obtainTeamFromUrl(String url) {
    final teamNameR = RegExp(r'(team\d)');
    return teamNameR.firstMatch(url).group(0);
  }

  String getUrlForCurrentTeam() {
    return _url.replaceAll(RegExp(r'team\d'), _currentTeam)+"/go/api/dashboard";
  }
}


Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/test.json');
}
