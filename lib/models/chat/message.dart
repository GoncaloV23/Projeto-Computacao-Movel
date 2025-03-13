class Message {
  Message(
      {this.message, this.imageUrl, this.audioUrl, required this.isRecieved});
  String? message;
  String? imageUrl;
  String? audioUrl;
  bool isRecieved;

  bool hasImage() {
    return imageUrl != null;
  }

  bool hasMessage() {
    return message != null;
  }

  bool hasAudio() {
    return audioUrl != null;
  }
}
