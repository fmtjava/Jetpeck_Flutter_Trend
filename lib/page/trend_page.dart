import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_module/color/color.dart';
import 'package:flutter_module/http/http_manager.dart';
import 'package:flutter_module/model/trend_model.dart';
import 'package:flutter_module/string/string.dart';
import 'package:flutter_module/util/toast_util.dart';
import 'package:flutter_module/widget/loading_dialog.dart';
import 'package:flutter_module/widget/trend_page_item.dart';

class TrendPage extends StatefulWidget {
  @override
  _TrendPageState createState() => _TrendPageState();
}

class _TrendPageState extends State<TrendPage> {
  List<TrendModel> _trendList = [];
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _requestTrendData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => SystemNavigator.pop()),
          backgroundColor: DColor.themeColor,
          title: Text('Trend'),
          actions: <Widget>[
            //弹出菜单
            PopupMenuButton(
                onSelected: (action) {
                  _requestTrendData(since: action);
                },
                offset: Offset(0, 55),
                itemBuilder: (context) => <PopupMenuItem<String>>[
                      PopupMenuItem(
                          child: Text(DString.DAILY), value: DString.DAILY),
                      PopupMenuItem(
                          child: Text(DString.WEEKLY), value: DString.WEEKLY),
                      PopupMenuItem(
                          child: Text(DString.MONTHLY), value: DString.MONTHLY)
                    ])
          ],
        ),
        body: ListView.builder(
          controller: _scrollController,
          itemBuilder: (context, index) {
            return TrendPageItem(_trendList[index]);
          },
          itemCount: _trendList.length,
        ));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showLoadingDialog() {
    //flutter在initState中显示Dialog加载框,加上Future.delayed
    Future.delayed(Duration.zero, () {
      showDialog(
          context: context, barrierDismissible: false, child: LoadingDialog());
    });
  }

  void _requestTrendData({String since = "daily"}) {
    _showLoadingDialog();
    var url = "https://guoshuyu.cn/github/trend/list?since=$since";
    HttpManager.get(url, (data) {
      Navigator.of(context).pop();
      _trendList.clear();
      List<dynamic> list = data;
      list.forEach((element) {
        _trendList.add(TrendModel.fromJsonMap(element));
      });
      setState(() {});
      //滚动到顶部
      _scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 500), curve: Curves.decelerate);
    }, (error) {
      Navigator.of(context).pop();
      ToastUtil.showError(error);
    });
  }
}
