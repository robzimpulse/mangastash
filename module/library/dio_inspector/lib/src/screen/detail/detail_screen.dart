import 'package:flutter/material.dart';

import '../../common/extension.dart';
import '../../common/helper.dart';
import '../../model/http_activity_model.dart';
import 'widgets/item_column.dart';
import 'widgets/item_row.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.data});

  final HttpActivityModel data;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            shape: const CircleBorder(),
            onPressed: () {
              Helper.copyToClipboard(
                context: context,
                text: data.description,
                message: 'Activity copied to clipboard',
              );
            },
            child: const Icon(Icons.copy),
          ),
          appBar: _appBar(context),
          body: SafeArea(
            child: TabBarView(
              children: [
                _overviewWidget(),
                _requestWidget(),
                _responseWidget(),
                _errorWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      title: const Text('Detail Activity'),
      elevation: 3,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.code, size: 20),
          onPressed: () {
            Helper.copyToClipboard(
              context: context,
              text: data.getCurlCommand,
              message: 'Curl command copied to clipboard',
            );
          },
        ),
      ],
      bottom: const TabBar(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white,
        tabs: [
          Tab(
            text: 'Overview',
            icon: Icon(Icons.info, color: Colors.white),
          ),
          Tab(
            text: 'Request',
            icon: Icon(Icons.arrow_upward, color: Colors.white),
          ),
          Tab(
            text: 'Response',
            icon: Icon(Icons.arrow_downward, color: Colors.white),
          ),
          Tab(
            text: 'Error',
            icon: Icon(Icons.warning, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _overviewWidget() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            ItemRow(name: 'Method', value: data.method),
            ItemRow(name: 'Server', value: data.server),
            ItemRow(name: 'Endpoint', value: data.endpoint),
            ItemRow(name: 'Request Time', value: data.request?.time.toString()),
            ItemRow(
              name: 'Response Time',
              value: data.response?.time.toString(),
            ),
            ItemRow(name: 'Duration', value: Helper.formatTime(data.duration)),
            ItemRow(
              name: 'Bytes Sent',
              value: Helper.formatBytes(data.request?.size ?? 0),
            ),
            ItemRow(
              name: 'Bytes Received',
              value: Helper.formatBytes(data.response?.size ?? 0),
            ),
            ItemRow(name: 'Secure', value: data.secure.toString()),
          ],
        ),
      ),
    );
  }

  Widget _requestWidget() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            ItemColumn(name: 'Started :', value: data.request?.time.toString()),
            ItemColumn(
              name: 'Bytes Sent :',
              value: Helper.formatBytes(data.request?.size ?? 0),
            ),
            ItemColumn(
              name: 'Header :',
              value: Helper.encodeRawJson(data.request!.headers),
            ),
            ItemColumn(
              name: 'Query Parameters :',
              value: Helper.encodeRawJson(data.request?.queryParameters),
            ),
            ItemColumn(
              name: 'Body :',
              value: data.request?.body,
              isImage: data.request?.contentType?.contains('image') ?? false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _responseWidget() {
    var contentTypeList = data.response?.headers?["content-type"];
    final isImage = contentTypeList != null &&
        contentTypeList.any((element) => element.contains('image'));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            ItemRow(
              name: 'Received :',
              value: data.response?.time.toString(),
            ),
            ItemRow(
              name: 'Status Code :',
              value: data.response?.status.toString(),
            ),
            ItemRow(
              name: 'Bytes Received :',
              value: Helper.formatBytes(data.response?.size ?? 0),
            ),
            ItemRow(
              name: 'Headers',
              value: Helper.encodeRawJson(data.response?.headers),
              useHeaderFormat: true,
            ),
            if (!isImage)
              ItemColumn(
                name: 'Body :',
                value: data.response?.body,
              ),
            if (isImage)
              ItemColumn(
                name: 'Body :',
                value: '',
                isImage: isImage,
                showCopyButton: false,
              ),
          ],
        ),
      ),
    );
  }

  Widget _errorWidget() {
    if (data.error?.error == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.warning, size: 60),
              SizedBox(height: 14),
              Text('No error found'),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ItemColumn(name: 'Error :', value: data.error?.error.toString()),
          ],
        ),
      ),
    );
  }
}
