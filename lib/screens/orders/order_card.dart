import 'package:flutter/material.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/handlers/formatter.dart';
import 'package:skyewooapp/site.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    Key? key,
    required this.orderID,
    required this.date,
    required this.status,
    required this.paymentMethod,
    required this.amount,
    required this.onTapped,
  }) : super(key: key);

  final String orderID;
  final String date;
  final String status;
  final String paymentMethod;
  final String amount;
  final Function() onTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        clipBehavior: Clip.hardEdge,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            side: BorderSide(color: AppColors.hover),
          ),
          primary: AppColors.white,
          onPrimary: AppColors.hover,
          shadowColor: Colors.transparent,
        ),
        onPressed: onTapped,
        child: Container(
          color: Colors.transparent,
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Order Code",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "#" + orderID,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    date,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    "Payment Status",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        Site.payment_method_title(paymentMethod),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 5),
                      (() {
                        if (paymentMethod == "paypal" && status == "on-hold") {
                          return const Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 20,
                          );
                        } else if (status != "completed" &&
                            paymentMethod == "cod") {
                          return const Icon(
                            Icons.pending_actions,
                            color: Colors.red,
                            size: 20,
                          );
                        } else if (status == "completed" ||
                            status == "processing") {
                          return const Icon(
                            Icons.check,
                            color: Colors.green,
                            size: 20,
                          );
                        } else {
                          return const Icon(
                            Icons.pending_actions,
                            color: Colors.red,
                            size: 20,
                          );
                        }
                      }())
                    ],
                  )
                ],
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    Site.CURRENCY + Formatter.format(amount),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
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
