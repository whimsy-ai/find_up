import 'package:flutter/material.dart';

class InfoTable extends StatelessWidget {
  final List<(String, dynamic)> rows;
  final double space;
  final double runSpace;
  final TextStyle? style;

  const InfoTable({
    super.key,
    required this.rows,
    this.space = 12,
    this.runSpace = 0,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final style = (this.style ?? DefaultTextStyle.of(context).style)
        .copyWith(height: 1.3);
    return DefaultTextStyle(
      style: style,
      child: Table(
        defaultColumnWidth: IntrinsicColumnWidth(),
        children: rows
            .map((e) => TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: runSpace / 2),
                      child: Text(e.$1.toString()),
                    ),
                    SizedBox(width: space),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: runSpace / 2),
                      child: Text(e.$2.toString()),
                    ),
                  ],
                ))
            .toList(),
      ),
      // child: Wrap(
      //   spacing: space,
      //   children: [
      //     Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: rows.map((e) => Text(e.$1)).toList(),
      //     ),
      //     Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: rows
      //           .map((e) => Text(
      //                 e.$2.toString(),
      //                 softWrap: true,
      //                 overflow: TextOverflow.ellipsis,
      //               ))
      //           .toList(),
      //     ),
      //   ],
      // ),
    );
  }
}
