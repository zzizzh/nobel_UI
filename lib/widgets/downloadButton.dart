
import 'package:flutter/material.dart';

class DownloadButton extends StatelessWidget {
  const DownloadButton({super.key});

  @override
  Align build(BuildContext context){

    return Align(
      alignment:
          const AlignmentDirectional(
              0.0, 0.0),
      child: Padding(
        padding:
            const EdgeInsetsDirectional
                .fromSTEB(4.0, 0.0,
                    0.0, 16.0),
        child: InkWell(
          splashColor:
              Colors.transparent,
          focusColor:
              Colors.transparent,
          hoverColor:
              Colors.transparent,
          highlightColor:
              Colors.transparent,
          onTap: () async {
            await showDialog(
              context: context,
              builder:
                  (alertDialogContext) {
                return AlertDialog(
                  title: const Text('알림'),
                  content: const Text(
                      '엑셀파일로 저장되었습니다.'),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(
                              alertDialogContext),
                      child: const Text(
                          'Ok'),
                    ),
                  ],
                );
              },
            );
          },
          child: const Icon(
            Icons
                .file_download_outlined,
            color:
                Color(0xFF08018C),
            size: 40.0,
          ),
        ),
      ),
    );
  }
}