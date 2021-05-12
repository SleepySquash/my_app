import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:my_app/vkr/models/person.dart';
import 'package:my_app/vkr/models/requests.dart';
import 'package:my_app/vkr/ui/awesomeDialog.dart';
import 'package:my_app/vkr/screens/_requestSend.dart';

import '_common.dart';

class VoiceTestScreen extends StatefulWidget {
  @override
  _VoiceTestScreenState createState() => _VoiceTestScreenState();
}

class _VoiceTestScreenState extends State<VoiceTestScreen> {
  bool isRecording = false;

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      AwesomeDialog? dialog;
      dialog = AwesomeDialog(
        context: context,
        width: 650,
        animType: AnimType.RIGHSLIDE,
        dialogType: DialogType.NO_HEADER,
        headerAnimationLoop: false,
        keyboardAware: true,
        dismissOnTouchOutside: false,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: EventStarter(
            caption: 'Голос',
            description: 'Опишите Ваше самочувствие голосом',
            icon: Icons.mic,
            onCancel: () {
              dialog?.dissmiss();
              Navigator.of(context).pop();
            },
            onProceed: () {
              dialog?.dissmiss();
              startListening();
            },
          ),
        ),
      )..show();
    });
  }

  Stream? stream;
  StreamSubscription? listener;
  List<int> currentSamples = [];
  int sampleRate = 44100, bitDepth = 32;
  DateTime? startTime;

  Future<bool> startListening() async {
    print("START LISTENING");
    if (isRecording) return false;

    print("wait for stream");
    stream = await MicStream.microphone(
        audioSource: AudioSource.DEFAULT,
        sampleRate: sampleRate,
        channelConfig: ChannelConfig.CHANNEL_IN_MONO,
        audioFormat: AudioFormat.ENCODING_PCM_8BIT);
    bitDepth = await MicStream.bitDepth;
    sampleRate = (await MicStream.sampleRate).round();
    print(
        "Start Listening to the microphone, sample rate is ${await MicStream.sampleRate}, bit depth is ${await MicStream.bitDepth}, bufferSize: ${await MicStream.bufferSize}");
    // bytesPerSample = await MicStream.bitDepth ~/ 8;

    setState(() {
      isRecording = true;
      startTime = DateTime.now();
    });
    currentSamples = [];
    listener = stream!.listen(calculateSamples);

    return true;
  }

  void calculateSamples(samples) {
    currentSamples.addAll(samples);
    setState(() {});
  }

  void stopListening() {
    if (!isRecording) return;
    print("Stop Listening to the microphone");
    listener!.cancel();
  }

  Uint8List convertToWav(List<int> data,
      {int sampleRate = 44100, int channels = 1, int bitDepth = 32}) {
    var size = data.length;
    var fileSize = size + 36;
    var byteRate = bitDepth ~/ 8;

    return Uint8List.fromList([
      // "RIFF"
      82, 73, 70, 70,
      fileSize & 0xff,
      (fileSize >> 8) & 0xff,
      (fileSize >> 16) & 0xff,
      (fileSize >> 24) & 0xff,
      // WAVE
      87, 65, 86, 69,
      // fmt
      102, 109, 116, 32,
      // fmt chunk size 16
      16, 0, 0, 0,
      // Type of format
      (bitDepth >= 32 ? 3 : 1), 0,
      // One channel
      channels, 0,
      // Sample rate
      sampleRate & 0xff,
      (sampleRate >> 8) & 0xff,
      (sampleRate >> 16) & 0xff,
      (sampleRate >> 24) & 0xff,
      // Byte rate
      byteRate & 0xff,
      (byteRate >> 8) & 0xff,
      (byteRate >> 16) & 0xff,
      (byteRate >> 24) & 0xff,
      // Uhm
      ((16 * channels) / 8).round(), 0,
      // bitsize
      bitDepth, 0,
      // "data"
      100, 97, 116, 97,
      size & 0xff,
      (size >> 8) & 0xff,
      (size >> 16) & 0xff,
      (size >> 24) & 0xff,
      ...data
    ]);
  }

  Future<void> sendData() async {
    await Requests.sendFile(
      new Request(
        map: {
          'phone': Person.phone ?? '',
          'date': DateTime.now().toUtc().toString(),
        },
        path: 'upload',
        file: currentSamples,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Тест'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        textTheme: TextTheme(
          headline6: TextStyle(color: Colors.black, fontSize: 24),
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  'Расскажите о Вашем самочуствии',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5,
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mic_none, size: 200),
                        Text(isRecording
                            ? DateTime.now().difference(startTime!).toString()
                            : '...')
                      ],
                    ),
                  ),
                ),
                AnimatedButton(
                  text: "Готово",
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green,
                  width: 250,
                  pressEvent: () {
                    stopListening();
                    // sendData();
                    showQuestionnaire(context, onDismiss: (String s) {
                      var map = {
                        'phone': Person.phone ?? '',
                        'date': DateTime.now().toUtc().toString(),
                        'questionnaire': s,
                        'sampleRate': sampleRate.toString(),
                        'bitDepth': bitDepth.toString(),
                      };
                      print(map);
                      sendRequestPopup(context,
                          map: {
                            'phone': Person.phone ?? '',
                            'date': DateTime.now().toUtc().toString(),
                            'questionnaire': s,
                            'sampleRate': sampleRate.toString(),
                            'bitDepth': bitDepth.toString(),
                          },
                          path: 'testvoice/phone',
                          file: convertToWav(currentSamples,
                              channels: 1, bitDepth: bitDepth),
                          title: "Отлично!",
                          descSaved:
                              "Тест пройден, результаты сохранены и будут отправлены при подключении к Wi-Fi!",
                          descSent: "Тест пройден, результаты отправлены!",
                          onDismiss: (_) {
                        Navigator.of(context).pop();
                      });
                    });
                    setState(() {
                      isRecording = false;
                      currentSamples = [];
                      startTime = null;
                    });
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showQuestionnaire(
  BuildContext context, {
  required Function(String) onDismiss,
}) {
  AwesomeDialog? dialog;
  dialog = AwesomeDialog(
    context: context,
    headerAnimationLoop: false,
    dialogType: DialogType.NO_HEADER,
    dismissOnBackKeyPress: false,
    dismissOnTouchOutside: false,
    width: 450,
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: QuestionnaireWidjet(
        onClose: (String s) {
          dialog?.dissmiss();
          onDismiss(s);
        },
      ),
    ),
  )..show();
}

class QuestionnaireWidjet extends StatefulWidget {
  final Function(String) onClose;
  QuestionnaireWidjet({required this.onClose});

  @override
  _QuestionnaireWidjetState createState() => _QuestionnaireWidjetState();
}

class CheckValue {
  bool value = false;
  final String title;
  final List<String>? disable;
  CheckValue(this.title, {this.disable});
}

class _QuestionnaireWidjetState extends State<QuestionnaireWidjet> {
  List<CheckValue> values = [
    CheckValue('Грустный', disable: ['Весёлый']),
    CheckValue('Весёлый', disable: ['Грустный']),
    CheckValue('Уставший'),
    CheckValue('Спокойный', disable: ['Агрессивный']),
    CheckValue('Агрессивный', disable: ['Спокойный']),
    CheckValue('Добрый', disable: ['Злой']),
    CheckValue('Злой', disable: ['Добрый']),
    CheckValue('Сонный', disable: ['Бодрый']),
    CheckValue('Бодрый', disable: ['Сонный']),
    CheckValue('Безразличный'),
    CheckValue('Уверенный', disable: ['Неуверенный']),
    CheckValue('Неуверенный', disable: ['Уверенный']),
    CheckValue('Задумчивый'),
    CheckValue('Ни один из перечисленного'),
  ];
  bool atLeastOne = false;

  List<Widget> _buildCheckboxes() {
    return values
        .map((e) => _buildCheckbox(e.value, (b) {
              if (b != null && b) {
                if (e.disable != null)
                  values
                      .where((item) => e.disable!.contains(item.title))
                      .forEach((element) => element.value = false);
                if (e == values.last)
                  values.forEach((element) => element.value = false);
                else
                  values.last.value = false;
              }
              e.value = b!;
              atLeastOne = values.where((e) => e.value).isNotEmpty;
              setState(() => {});
            }, e.title))
        .toList();
  }

  Widget _buildCheckbox(bool value, Function(bool?) onChanged, String title) {
    return CheckboxListTile(
      value: value,
      title: Text(title, style: Theme.of(context).textTheme.headline6),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Анкета',
          style: Theme.of(context).textTheme.headline4,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 5),
        Text(
          'Пожалуйста, отметьте Ваше самочувствие',
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Column(children: _buildCheckboxes()),
        SizedBox(height: 15),
        AnimatedButton(
          pressEvent: () {
            if (atLeastOne)
              widget.onClose(
                  values.where((e) => e.value).map((e) => e.title).toString());
          },
          text: atLeastOne ? 'Готово' : 'Отметьте, пожалуйста',
          color: atLeastOne ? Colors.green : Colors.grey,
        )
      ],
    );
  }
}
