// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_typing_uninitialized_variables, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class NoConnection extends StatelessWidget {
  final checkConnection;
  const NoConnection({required this.checkConnection});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              SizedBox(
                height: 160,
                width: 160,
                child: SvgPicture.asset(
                  'assets/offline.svg',
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "No Internet Connection !",
                style: GoogleFonts.goldman(
                  textStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              RaisedButton(
                color: Colors.orange,
                onPressed: checkConnection,
                child: Text(
                  "Retry",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
