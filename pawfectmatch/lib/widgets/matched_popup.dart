import 'dart:async';
import 'package:flutter/material.dart';

class MatchedPopup extends StatefulWidget {
  final String dogProfilePictureUrl;

  const MatchedPopup({
    Key? key,
    required this.dogProfilePictureUrl,
  }) : super(key: key);

  @override
  _MatchedPopupState createState() => _MatchedPopupState();
}

class _MatchedPopupState extends State<MatchedPopup> {
  late OverlayEntry _overlayEntry;
  late Completer<void> _overlayClosedCompleter;

  @override
  void initState() {
    super.initState();
    _overlayClosedCompleter = Completer<void>();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _showOverlay();
    });
  }

  void _showOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.2,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(widget.dogProfilePictureUrl),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'YOU HAVE MATCHED',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Get to chatting or continue browsing?',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _overlayEntry.remove();
                              _overlayClosedCompleter.complete();
                              // Redirect back to matching_screen.dart
                              Navigator.pop(context);
                            },
                            child: Text('Continue Browsing'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              //_overlayEntry.remove();
                              //_overlayClosedCompleter.complete();
                              // Redirect to chatlist_screen.dart
                              //Navigator.pushNamed(context, '/chat'); // Replace with your chatlist screen route
                            },
                            child: Text('Go To Chat'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(_overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _overlayClosedCompleter.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SizedBox.shrink(); // The overlay is closed, return an empty widget
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}