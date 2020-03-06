import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

class KoalaView extends StatefulWidget {
  bool _isPaused;
  String _animation;
  FlareControls _controls;

  KoalaView({bool isPaused, String animation, FlareControls controller}){
    _isPaused = isPaused;
    _animation = animation;
    _controls = controller;
  }

  @override
  _KoalaViewState createState() => _KoalaViewState(_isPaused,_animation,_controls);
}

class _KoalaViewState extends State<KoalaView> {
  _KoalaViewState(bool _isPaused, String _animation, FlareControls _controls){
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
    bottom: 30,
        top: 30 ,
        child: GestureDetector(
            child: FractionallySizedBox(
                heightFactor: 0.5,
                child: Container(child: FlareActor("assets/koala.flr",
                  alignment: Alignment.center,
                  isPaused: this.widget._isPaused,
                  fit: BoxFit.scaleDown,
                  animation: this.widget._animation,
                  controller: this.widget._controls,
                ))))
    );
  }
}