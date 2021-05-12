import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:my_app/vkr/models/requests.dart';

void sendRequestPopup(BuildContext context,
    {Map<String, String>? map,
    MethodType method = MethodType.post,
    String path = 'post',
    List<int>? file,
    Function(bool)? onDismiss,
    bool save = true,
    String title = 'Успешно',
    String descSent = 'Данные отправлены!',
    String descSaved =
        'Данные сохранены для отправки при подключении к сети Wi-Fi'}) {
  AwesomeDialog? dialog;
  dialog = AwesomeDialog(
    context: context,
    width: 450,
    headerAnimationLoop: false,
    dialogType: DialogType.SUCCES,
    dismissOnBackKeyPress: false,
    dismissOnTouchOutside: false,
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: RequestSendingWidget(
        req: new Request(
          map: map,
          method: method,
          path: path,
          file: file,
        ),
        onClose: () {
          dialog?.dissmiss();
        },
        onDismiss: onDismiss,
        title: title,
        descSaved: descSaved,
        descSent: descSent,
        context: context,
        save: save,
      ),
    ),
  )..show();
}

class RequestSendingWidget extends StatefulWidget {
  final Request req;
  final Function? onClose;
  final Function(bool)? onDismiss;
  final String title, descSent, descSaved;
  final BuildContext? context;
  final bool save;
  RequestSendingWidget(
      {required this.req,
      required this.title,
      required this.descSent,
      required this.descSaved,
      required this.save,
      this.context,
      this.onClose,
      this.onDismiss});

  @override
  _RequestSendingWidgetState createState() => _RequestSendingWidgetState();
}

class _RequestSendingWidgetState extends State<RequestSendingWidget> {
  Future<bool>? _result;

  @override
  void initState() {
    super.initState();
    _result = (widget.req.file != null)
        ? Requests.sendFile(widget.req, save: widget.save)
        : Requests.send(widget.req, save: widget.save);
  }

  @override
  Widget build(BuildContext context) {
    return _result == null
        ? CircularProgressIndicator()
        : FutureBuilder<bool>(
            future: _result,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headline4,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      snapshot.data! ? widget.descSent : widget.descSaved,
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 15),
                    AnimatedButton(
                      pressEvent: () {
                        if (widget.onDismiss != null)
                          widget.onDismiss!(snapshot.data!);
                        if (widget.onClose != null) widget.onClose!();
                      },
                      text: 'Понятно',
                      color: Colors.green,
                    )
                  ],
                );
              } else if (snapshot.hasError) {
                return Column(
                  children: [
                    Text("${snapshot.error}"),
                    AnimatedButton(
                      pressEvent: () {
                        widget.onDismiss!(false);
                        widget.onClose!();
                      },
                      text: 'Понятно',
                      color: Colors.green,
                    )
                  ],
                );
              }
              return CircularProgressIndicator();
            },
          );
  }
}
