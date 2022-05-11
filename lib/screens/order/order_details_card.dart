import 'package:flutter/material.dart';
import 'package:skyewooapp/handlers/formatter.dart';
import 'package:skyewooapp/site.dart';

class OrderDetailsCard extends StatelessWidget {
  const OrderDetailsCard({
    Key? key,
    required this.quantity,
    required this.name,
    required this.amount,
  }) : super(key: key);

  final String quantity;
  final String name;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      child: Stack(
        children: [
          Row(
            children: [
              Text(
                "x" + quantity,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(right: 30),
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                Site.CURRENCY + Formatter.format(amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
