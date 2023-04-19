import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TwitterItemView extends StatefulWidget {
  String tweetUrl;
  String tweetText;
  String tweetAuthor;
  bool isDepressive;

  TwitterItemView(this.tweetUrl, this.tweetText, this.tweetAuthor, this.isDepressive, {super.key});

  @override
  State<TwitterItemView> createState() => _TwitterItemViewState();
}

class _TwitterItemViewState extends State<TwitterItemView> {

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.tweetText, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(widget.tweetAuthor, style: const TextStyle(fontStyle: FontStyle.italic)),
      trailing: widget.isDepressive ? const Icon(Icons.sentiment_very_dissatisfied) : const Icon(Icons.sentiment_very_satisfied),
      onTap: () {
        launchUrlString(
          widget.tweetUrl,
          mode: LaunchMode.externalApplication
        );
      },
      iconColor: widget.isDepressive ? Colors.red : Colors.green,
      dense: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      minVerticalPadding: 12,
      horizontalTitleGap: 8,
    );
  }

}