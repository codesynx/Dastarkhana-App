import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class LocationBarWidget extends StatelessWidget {
  final String userAddress;
  final bool isFetchingAddress;

  const LocationBarWidget({
    Key? key,
    required this.userAddress,
    required this.isFetchingAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.location_on,
              color: successColor,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Жеткізу мекенжайы",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "SF-Pro-Text-Medium",
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  isFetchingAddress ? 'Мекенжай анықталуда...' : userAddress,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "SF-Pro-Text-Bold",
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[600]),
        ],
      ),
    );
  }
}
