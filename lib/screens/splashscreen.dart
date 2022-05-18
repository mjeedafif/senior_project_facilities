import 'package:flutter/material.dart';

class Splahscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 223, 244, 229),
      ),
      child: Center(
        child: Container(
          width: 250,
          height: 200,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/KAU.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
