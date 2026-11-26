import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_shift/models/records.dart';

void main() {
  test('overtime is clamped to non-negative actual minus scheduled', () {
    final row=OvertimeRecord(id:'1',member:'Test',date:'2026-01-01',scheduled:8,actual:10,rate:200,multiplier:1.5);
    expect(row.overtimeHours,2);
    expect(row.overtimePay,600);
  });
  test('negative overtime is zero', () {
    final row=OvertimeRecord(id:'2',member:'Test',date:'2026-01-01',scheduled:9,actual:8,rate:200,multiplier:1.5);
    expect(row.overtimeHours,0);
  });
}
