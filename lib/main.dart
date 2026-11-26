import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'models/records.dart';
import 'storage/local_store.dart';
import 'theme/app_theme.dart';
import 'screens/rota_screen.dart';
import 'screens/handover_screen.dart';
import 'screens/overtime_screen.dart';
import 'screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStore.instance.init();
  runApp(const KaziShiftApp());
}

class KaziShiftApp extends StatefulWidget {
  const KaziShiftApp({super.key});
  @override State<KaziShiftApp> createState()=>_KaziShiftAppState();
}
class _KaziShiftAppState extends State<KaziShiftApp> {
  KaziTheme _theme=KaziTheme.obsidian;
  bool _admin=true;
  bool _loaded=false;
  int _tab=0;
  final _uuid=const Uuid();
  final List<ShiftRecord> _shifts=[];
  final List<HandoverRecord> _handovers=[];
  final List<OvertimeRecord> _overtime=[];
  AppPalette get _palette=>AppPalette(_theme);

  @override void initState(){super.initState();_load();}
  Future<void> _load() async {
    final prefs=await SharedPreferences.getInstance();
    _theme=KaziTheme.values[prefs.getInt('theme')??0];
    _admin=prefs.getBool('admin')??true;
    final store=LocalStore.instance;
    _shifts.addAll(store.read('shifts').map(ShiftRecord.fromJson));
    _handovers.addAll(store.read('handovers').map(HandoverRecord.fromJson));
    _overtime.addAll(store.read('overtime').map(OvertimeRecord.fromJson));
    if(_shifts.isEmpty){
      _shifts.addAll([
        ShiftRecord(id:_uuid.v4(),member:'Amina W.',role:'Front Desk',day:'Monday · 08:00–16:00',start:'08:00',end:'16:00'),
        ShiftRecord(id:_uuid.v4(),member:'Brian K.',role:'Operations',day:'Monday · 16:00–00:00',start:'16:00',end:'00:00'),
        ShiftRecord(id:_uuid.v4(),member:'Unassigned',role:'Night Security',day:'Monday · 00:00–08:00',start:'00:00',end:'08:00',coverage:Coverage.gap),
        ShiftRecord(id:_uuid.v4(),member:'Carol N.',role:'Front Desk',day:'Tuesday · 08:00–16:00',start:'08:00',end:'16:00')
      ]);
      await _save();
    }
    if(_handovers.isEmpty){
      _handovers.add(HandoverRecord(id:_uuid.v4(),title:'Generator inspection due',note:'Check fuel level and record the meter reading before the night shift.',owner:'Amina W.',createdAt:DateTime.now(),urgency:Urgency.urgent,equipmentOk:false));
      await _save();
    }
    if(mounted)setState(()=>_loaded=true);
  }
  Future<void> _save() async {
    final s=LocalStore.instance;
    await s.write('shifts',_shifts.map((e)=>e.toJson()).toList());
    await s.write('handovers',_handovers.map((e)=>e.toJson()).toList());
    await s.write('overtime',_overtime.map((e)=>e.toJson()).toList());
  }
  Future<void> _setTheme(KaziTheme t) async {setState(()=>_theme=t);final p=await SharedPreferences.getInstance();await p.setInt('theme',t.index);}
  Future<void> _switchRole() async {setState(()=>_admin=!_admin);final p=await SharedPreferences.getInstance();await p.setBool('admin',_admin);}
  void _message(String text)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(text)));

  Future<void> _addShift() async {
    final member=TextEditingController(),role=TextEditingController(),day=TextEditingController(text:'Wednesday'),start=TextEditingController(text:'08:00'),end=TextEditingController(text:'16:00');
    final ok=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('Add shift'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
      _field(member,'Team member'),_field(role,'Role / station'),_field(day,'Day'),Row(children:[Expanded(child:_field(start,'Start')),const SizedBox(width:8),Expanded(child:_field(end,'End'))])
    ])),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Save shift'))]));
    if(ok==true&&member.text.trim().isNotEmpty&&role.text.trim().isNotEmpty){setState(()=>_shifts.add(ShiftRecord(id:_uuid.v4(),member:member.text.trim(),role:role.text.trim(),day:day.text.trim(),start:start.text.trim(),end:end.text.trim(),coverage:member.text.toLowerCase().contains('unassigned')?Coverage.gap:Coverage.covered)));await _save();}
    member.dispose();role.dispose();day.dispose();start.dispose();end.dispose();
  }
  Future<void> _updateShift(ShiftRecord s) async {
    setState((){s.coverage=_admin?Coverage.covered:Coverage.swapRequested;s.swapWith=_admin?'':'Requested by staff';});
    await _save();_message(_admin?'Shift marked covered':'Swap request recorded locally');
  }
  Future<void> _addHandover() async {
    final title=TextEditingController(),note=TextEditingController();
    Urgency urgency=Urgency.routine;bool equipment=true;
    final ok=await showDialog<bool>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,setD)=>AlertDialog(title:const Text('New handover entry'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
      _field(title,'Task / subject'),_field(note,'Handover notes',maxLines:4),
      DropdownButtonFormField<Urgency>(value:urgency,decoration:const InputDecoration(labelText:'Urgency'),items:Urgency.values.map((e)=>DropdownMenuItem(value:e,child:Text(e.name))).toList(),onChanged:(v)=>setD(()=>urgency=v??Urgency.routine)),
      SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('Equipment checked and OK'),value:equipment,onChanged:(v)=>setD(()=>equipment=v))
    ])),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Save entry'))])));
    if(ok==true&&title.text.trim().isNotEmpty){setState(()=>_handovers.insert(0,HandoverRecord(id:_uuid.v4(),title:title.text.trim(),note:note.text.trim(),owner:_admin?'Shift Lead':'Team Member',createdAt:DateTime.now(),urgency:urgency,equipmentOk:equipment)));await _save();_message('Handover saved offline');}
    title.dispose();note.dispose();
  }
  Future<void> _completeHandover(HandoverRecord e) async {setState(()=>e.urgency=Urgency.completed);await _save();}
  Future<void> _addOvertime() async {
    final member=TextEditingController(text:_admin?'Team member':'My shift'),date=TextEditingController(text:DateTime.now().toIso8601String().substring(0,10)),scheduled=TextEditingController(text:'8'),actual=TextEditingController(text:'9'),rate=TextEditingController(text:'200'),mult=TextEditingController(text:'1.5');
    final ok=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('Log worked hours'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
      _field(member,'Team member'),_field(date,'Date (YYYY-MM-DD)'),Row(children:[Expanded(child:_field(scheduled,'Scheduled h')),const SizedBox(width:8),Expanded(child:_field(actual,'Actual h'))]),Row(children:[Expanded(child:_field(rate,'Hourly rate (KES)')),const SizedBox(width:8),Expanded(child:_field(mult,'Multiplier'))])
    ])),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Save hours'))]));
    if(ok==true){final sh=double.tryParse(scheduled.text)??0,ac=double.tryParse(actual.text)??0,rt=double.tryParse(rate.text)??0,mu=double.tryParse(mult.text)??1;if(member.text.trim().isNotEmpty&&sh>=0&&ac>=0&&rt>=0&&mu>0){setState(()=>_overtime.insert(0,OvertimeRecord(id:_uuid.v4(),member:member.text.trim(),date:date.text.trim(),scheduled:sh,actual:ac,rate:rt,multiplier:mu)));await _save();_message('Hours saved offline');}}
    for(final c in [member,date,scheduled,actual,rate,mult]){c.dispose();}
  }
  Future<void> _approve(OvertimeRecord r) async {setState(()=>r.approval=Approval.approved);await _save();_message('Overtime approved');}
  Future<void> _export() async {
    final payload=jsonEncode({'exportedAt':DateTime.now().toIso8601String(),'shifts':_shifts.map((e)=>e.toJson()).toList(),'handovers':_handovers.map((e)=>e.toJson()).toList(),'overtime':_overtime.map((e)=>e.toJson()).toList()});
    await Clipboard.setData(ClipboardData(text:payload));if(mounted)_message('Workspace JSON copied to clipboard');
  }
  Future<void> _downloadApk() async {
    final uri=Uri.parse('https://github.com/kennedy-blip/kazi-shift/releases/latest/download/app-release.apk');
    if(!await launchUrl(uri,mode:LaunchMode.externalApplication)&&mounted)_message('Could not open the APK release page');
  }
  static Widget _field(TextEditingController c,String label,{int maxLines=1})=>Padding(padding:const EdgeInsets.only(bottom:10),child:TextField(controller:c,maxLines:maxLines,decoration:InputDecoration(labelText:label)));
  @override Widget build(BuildContext context){
    if(!_loaded)return MaterialApp(debugShowCheckedModeBanner:false,theme:_palette.theme,home:const Scaffold(body:Center(child:CircularProgressIndicator())));
    final pages=<Widget>[
      RotaScreen(palette:_palette,shifts:_shifts,isAdmin:_admin,onAdd:_addShift,onUpdate:_updateShift),
      HandoverScreen(palette:_palette,entries:_handovers,onAdd:_addHandover,onComplete:_completeHandover),
      OvertimeScreen(palette:_palette,records:_overtime,isAdmin:_admin,onAdd:_addOvertime,onApprove:_approve),
      SettingsScreen(palette:_palette,theme:_theme,isAdmin:_admin,onTheme:_setTheme,onRole:_switchRole,onExport:_export,onDownload:_downloadApk,storageReady:LocalStore.instance.isReady)
    ];
    const labels=['Rota','Handover','Overtime','Settings'];
    const icons=[Icons.calendar_month,Icons.fact_check_outlined,Icons.schedule,Icons.settings_outlined];
    return MaterialApp(debugShowCheckedModeBanner:false,title:'KaziShift',theme:_palette.theme,home:LayoutBuilder(builder:(context,box){
      final wide=box.maxWidth>=850;
      return Scaffold(
        appBar:AppBar(title:Row(children:[Container(width:34,height:34,decoration:BoxDecoration(color:_palette.accent.withValues(alpha:.15),borderRadius:BorderRadius.circular(11)),child:Icon(Icons.swap_horiz_rounded,color:_palette.accent)),const SizedBox(width:10),const Text('KaziShift',style:TextStyle(fontWeight:FontWeight.w900,letterSpacing:-.5))]),actions:[Padding(padding:const EdgeInsets.only(right:16),child:Center(child:Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),decoration:BoxDecoration(color:_palette.accent.withValues(alpha:.12),borderRadius:BorderRadius.circular(20)),child:Text(_admin?'SHIFT LEAD':'STAFF',style:TextStyle(color:_palette.accent,fontSize:10,fontWeight:FontWeight.w900)))))]),
        body:Container(decoration:BoxDecoration(gradient:RadialGradient(center:const Alignment(-.8,-.9),radius:1.5,colors:[_palette.secondary.withValues(alpha:.09),_palette.background,_palette.background])),child:Row(children:[
          if(wide)NavigationRail(selectedIndex:_tab,onDestinationSelected:(v)=>setState(()=>_tab=v),labelType:NavigationRailLabelType.all,backgroundColor:Colors.transparent,destinations:List.generate(4,(i)=>NavigationRailDestination(icon:Icon(icons[i]),label:Text(labels[i])))),
          if(wide)VerticalDivider(width:1,color:_palette.border),
          Expanded(child:AnimatedSwitcher(duration:const Duration(milliseconds:260),transitionBuilder:(child,animation)=>FadeTransition(opacity:animation,child:SlideTransition(position:Tween<Offset>(begin:const Offset(.025,0),end:Offset.zero).animate(animation),child:child)),child:KeyedSubtree(key:ValueKey(_tab),child:pages[_tab])))
        ])),
        bottomNavigationBar:wide?null:NavigationBar(selectedIndex:_tab,onDestinationSelected:(v)=>setState(()=>_tab=v),backgroundColor:_palette.surface,destinations:List.generate(4,(i)=>NavigationDestination(icon:Icon(icons[i]),label:labels[i]))),
      );
    }));
  }
}
