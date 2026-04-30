import 'package:flutter/material.dart';
import 'package:cropsense/core/theme.dart';

class CorrelationHeatmap extends StatefulWidget {
  const CorrelationHeatmap({super.key});
  @override
  State<CorrelationHeatmap> createState() => _CorrelationHeatmapState();
}

class _CorrelationHeatmapState extends State<CorrelationHeatmap> {
  int? _hoveredRow;
  int? _hoveredCol;

  final _labels = ['Yield', 'NDVI', 'Rain', 'TempMax', 'TempMin', 'Soil'];

  final _matrix = const [
    [1.00,  0.82,  0.54, -0.61,  0.23,  0.71],
    [0.82,  1.00,  0.48, -0.53,  0.19,  0.65],
    [0.54,  0.48,  1.00, -0.31,  0.42,  0.58],
    [-0.61,-0.53, -0.31,  1.00, -0.28, -0.44],
    [0.23,  0.19,  0.42, -0.28,  1.00,  0.31],
    [0.71,  0.65,  0.58, -0.44,  0.31,  1.00],
  ];

  Color _cellColor(double v) {
    if (v > 0) return Color.lerp(Colors.white, AppColors.limeGreen, v)!;
    return Color.lerp(Colors.white, AppColors.burntOrange, -v)!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.skyBlue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.grid_on_rounded, color: AppColors.skyBlue, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Correlation Matrix', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
              Text('Tap a cell to see correlation', style: TextStyle(fontSize: 11, color: Color(0xFF757575))),
            ]),
          ]),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cellSize = (constraints.maxWidth - 48) / _labels.length;
                return Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _labels.map((l) => SizedBox(
                        width: 44,
                        child: Text(l, style: const TextStyle(fontSize: 9, color: Color(0xFF757575)), overflow: TextOverflow.ellipsis),
                      )).toList(),
                    ),
                    Expanded(
                      child: Column(
                        children: List.generate(_matrix.length, (row) => Expanded(
                          child: Row(
                            children: List.generate(_matrix[row].length, (col) {
                              final v = _matrix[row][col];
                              final isHovered = _hoveredRow == row && _hoveredCol == col;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _hoveredRow = row;
                                    _hoveredCol = col;
                                  }),
                                  child: MouseRegion(
                                    onEnter: (_) => setState(() { _hoveredRow = row; _hoveredCol = col; }),
                                    onExit: (_) => setState(() { _hoveredRow = null; _hoveredCol = null; }),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      margin: const EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        color: _cellColor(v),
                                        borderRadius: BorderRadius.circular(3),
                                        border: isHovered ? Border.all(color: AppColors.deepGreen, width: 2) : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          v.toStringAsFixed(2),
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: v.abs() > 0.5 ? Colors.white : const Color(0xFF424242),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        )),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (_hoveredRow != null && _hoveredCol != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.deepGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '\${_labels[_hoveredRow!]} ↔ \${_labels[_hoveredCol!]}: \${_matrix[_hoveredRow!][_hoveredCol!].toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.deepGreen),
              ),
            ),
        ],
      ),
    );
  }
}
