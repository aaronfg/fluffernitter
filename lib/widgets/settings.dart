import 'package:fluffernitter/styles.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController _instanceController;
  @override
  void initState() {
    _instanceController = TextEditingController(text: 'nitter.net');
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(slivers: _buildSlivers(), shrinkWrap: true,),
    );
    // return Text('asdas');
  }

  List<Widget> _buildSlivers() {
    List<Widget> slivs = [];
    // slivs.add(_buildTitle());
    slivs.add(_buildSectionTitle('Nitter Instance'));
    slivs.add(_buildInstanceSection());
    // slivs.add(_buildAbout());
    slivs.add(_buildOk());
    return slivs;
  }

  Widget _buildTitle() {
    return SliverToBoxAdapter(child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(child: Text('Settings', style: Stylez.forContext(context, Stylez.screenTitle))),
    ));
  }

  Widget _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Text(title,
            style: Stylez.forContext(context, Stylez.bold),
        ),
      ),
    );
  }

  Widget _buildInstanceSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextField(
          controller: _instanceController,
        ),
      ),
    );
  }

  Widget _buildAbout() {
    return SliverToBoxAdapter(
      child: ListTile(
        title: Text('About'),
        onTap: ()=>{},
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildOk() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: FractionallySizedBox(
            widthFactor: .5,
            child: RaisedButton(onPressed: _onOkTap, child: Text('OK'),),
        ),
      ),
    );
  }

  void _onOkTap() {
    Navigator.pop(context);
  }
}
