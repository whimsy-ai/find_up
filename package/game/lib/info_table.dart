import 'package:flutter/material.dart';

class InfoTable extends StatelessWidget {
  final List<(String, dynamic)> rows;
  final double firstColumnWidth;
  final double runSpace;
  final TextStyle? style;

  const InfoTable({
    super.key,
    required this.rows,
    this.firstColumnWidth = 100,
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
        columnWidths: {
          0: FixedColumnWidth(firstColumnWidth),
        },
        children: rows
            .map((e) => TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: runSpace / 2),
                      child: Text(e.$1.toString()),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: runSpace / 2),
                      child: Text(
                        e.$2.toString(),
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ))
            .toList(),
      ),
    );
  }
}
