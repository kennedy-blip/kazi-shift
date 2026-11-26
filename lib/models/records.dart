enum Coverage { covered, gap, swapRequested }
enum Urgency { urgent, routine, completed }
enum Approval { pending, approved, rejected }

class ShiftRecord {
  ShiftRecord({required this.id, required this.member, required this.role, required this.day, required this.start, required this.end, this.coverage = Coverage.covered, this.swapWith = ''});
  final String id, member, role, day, start, end;
  Coverage coverage;
  String swapWith;
  Map<String, dynamic> toJson() => {'id':id,'member':member,'role':role,'day':day,'start':start,'end':end,'coverage':coverage.name,'swapWith':swapWith};
  factory ShiftRecord.fromJson(Map<String,dynamic> j) => ShiftRecord(id:j['id'],member:j['member'],role:j['role'],day:j['day'],start:j['start'],end:j['end'],coverage:Coverage.values.firstWhere((e)=>e.name==j['coverage'],orElse:()=>Coverage.covered),swapWith:j['swapWith']??'');
}
class HandoverRecord {
  HandoverRecord({required this.id,required this.title,required this.note,required this.owner,required this.createdAt,this.urgency=Urgency.routine,this.equipmentOk=true});
  final String id,title,note,owner; final DateTime createdAt; Urgency urgency; bool equipmentOk;
  Map<String,dynamic> toJson()=>{'id':id,'title':title,'note':note,'owner':owner,'createdAt':createdAt.toIso8601String(),'urgency':urgency.name,'equipmentOk':equipmentOk};
  factory HandoverRecord.fromJson(Map<String,dynamic> j)=>HandoverRecord(id:j['id'],title:j['title'],note:j['note'],owner:j['owner'],createdAt:DateTime.parse(j['createdAt']),urgency:Urgency.values.firstWhere((e)=>e.name==j['urgency'],orElse:()=>Urgency.routine),equipmentOk:j['equipmentOk']??true);
}
class OvertimeRecord {
  OvertimeRecord({required this.id,required this.member,required this.date,required this.scheduled,required this.actual,required this.rate,required this.multiplier,this.approval=Approval.pending});
  final String id,member,date; final double scheduled,actual,rate,multiplier; Approval approval;
  double get overtimeHours=>(actual-scheduled).clamp(0,24).toDouble();
  double get overtimePay=>overtimeHours*rate*multiplier;
  Map<String,dynamic> toJson()=>{'id':id,'member':member,'date':date,'scheduled':scheduled,'actual':actual,'rate':rate,'multiplier':multiplier,'approval':approval.name};
  factory OvertimeRecord.fromJson(Map<String,dynamic> j)=>OvertimeRecord(id:j['id'],member:j['member'],date:j['date'],scheduled:(j['scheduled'] as num).toDouble(),actual:(j['actual'] as num).toDouble(),rate:(j['rate'] as num).toDouble(),multiplier:(j['multiplier'] as num).toDouble(),approval:Approval.values.firstWhere((e)=>e.name==j['approval'],orElse:()=>Approval.pending));
}
