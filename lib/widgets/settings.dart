import 'package:fluffernitter/service_locator.dart';
import 'package:fluffernitter/services/user_prefs_service.dart';
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
    _instanceController = TextEditingController(
        text: locator.get<UserPrefsService>().userPrefs.nitterInstance.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
        slivers: _buildSlivers(),
        shrinkWrap: true,
      ),
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

  Widget _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Text(
          title,
          style: Stylez.forContext(context, Stylez.bold),
        ),
      ),
    );
  }

  Widget _buildInstanceSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _instanceController,
              onChanged: _onInstanceChanged,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 12),
              child: Row(
                children: [
                  Text(
                    'Please use a fully qualified url. ie:  ',
                    style: Stylez.linkUrl,
                  ),
                  Text(
                    'http://nitter.net',
                    style: Stylez.instanceHint,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOk() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: FractionallySizedBox(
          widthFactor: .5,
          child: ElevatedButton(
            onPressed: _instanceController.text.isEmpty ? null : _onSaveTap,
            child: Text('Save'),
          ),
        ),
      ),
    );
  }

  void _onSaveTap() {
    UserPrefsService prefsSrv = locator.get<UserPrefsService>();
    // if they updated the instance, save it
    if (_instanceController.text != prefsSrv.userPrefs.nitterInstance.toString()) {
      try {
        prefsSrv.updateNitterInstance(_instanceController.text);
      } catch (er) {
        print('uh oh');
      }
    }
    Navigator.pop(context);
  }

  void _onInstanceChanged(String value) {
    setState(() {});
  }
}
