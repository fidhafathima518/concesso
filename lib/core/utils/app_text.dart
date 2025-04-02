import 'package:flutter/material.dart';



class AppText extends StatelessWidget {

  final String data;
  final TextStyle ?mystyle;
  const AppText({super.key,required this.data,this.mystyle});

  @override
  Widget build(BuildContext context) {
    return Text(data,style: mystyle);
  }
}