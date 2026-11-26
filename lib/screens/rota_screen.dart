import 'package:flutter/material.dart';
import '../models/records.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';
class RotaScreen extends StatelessWidget {
  const RotaScreen({super.key,required this.palette,required this.shifts,required this.isAdmin,required this.onAdd,required this.onUpdate});
  final AppPalette palette; final List<ShiftRecord> shifts; final bool isAdmin; final VoidCallback onAdd; final ValueChanged<ShiftRecord> onUpdate;
  @override Widget build(BuildContext context){
    final gaps=shifts.where((s)=>s.coverage==Coverage.gap).length;
    return ListView(padding:const EdgeInsets.all(18),children:[
      Row(children:[Expanded(child:Text('Coverage board',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800))),if(isAdmin)FilledButton.icon(onPressed:onAdd,icon:const Icon(Icons.add),label:const Text('Add shift'))]),
      const SizedBox(height:6),Text('This week · local schedule',style:TextStyle(color:palette.muted)),const SizedBox(height:16),
      Row(children:[Expanded(child:_metric('Scheduled','${shifts.length}',Icons.calendar_month,palette.accent)),const SizedBox(width:10),Expanded(child:_metric('Coverage gaps','$gaps',Icons.warning_amber,gaps>0?Colors.orange:Colors.green))]),
      const SizedBox(height:18),
      ...shifts.map((s)=>Padding(padding:const EdgeInsets.only(bottom:10),child:GlassPanel(palette:palette,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[Expanded(child:Text(s.role,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:16))),_status(s.coverage)]),
        const SizedBox(height:10),Row(children:[Icon(Icons.person_outline,size:17,color:palette.muted),const SizedBox(width:6),Text(s.member),const Spacer(),Text('${s.start} – ${s.end}',style:TextStyle(color:palette.accent,fontWeight:FontWeight.w700))]),
        const SizedBox(height:5),Text(s.day,style:TextStyle(color:palette.muted)),
        if(s.coverage==Coverage.swapRequested)Text('Swap requested · ${s.swapWith}',style:TextStyle(color:palette.secondary)),
        if(isAdmin&&s.coverage!=Coverage.covered)Align(alignment:Alignment.centerRight,child:TextButton(onPressed:()=>onUpdate(s),child:const Text('Mark covered')))
      ])))),
      if(shifts.isEmpty)const Center(child:Text('No shifts yet. Add your first shift.'))
    ]);
  }
  Widget _metric(String label,String value,IconData icon,Color color)=>GlassPanel(palette:palette,child:Row(children:[Icon(icon,color:color),const SizedBox(width:10),Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(value,style:TextStyle(fontSize:22,fontWeight:FontWeight.w800,color:palette.text)),Text(label,style:TextStyle(fontSize:12,color:palette.muted))])]));
  Widget _status(Coverage c){final color=c==Coverage.covered?Colors.green:c==Coverage.gap?Colors.orange:palette.secondary;final label=c==Coverage.covered?'Covered':c==Coverage.gap?'Gap':'Swap';return Chip(label:Text(label,style:TextStyle(color:color,fontSize:11)),backgroundColor:color.withValues(alpha:.12),side:BorderSide.none,visualDensity:VisualDensity.compact);}
}
