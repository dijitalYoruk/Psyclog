class Message {
  final String _id;
  final String text;
  final String _authorID;
  final String _contactID;
  final String _chatID;
  final String createdAt;
  final String updatedAt;
  bool isSeen;

  get getId => _id;
  get getAuthorID => _authorID;
  get getContactID => _contactID;
  get getChatID => _chatID;

  Message(this.isSeen, this._id, this.text, this._contactID, this._authorID, this._chatID, this.createdAt, this.updatedAt);
}
