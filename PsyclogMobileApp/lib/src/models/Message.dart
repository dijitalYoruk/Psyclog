
class Message {
  final String _id;
  final String text;
  final String _authorID;
  final String _contactID;
  final String _chatID;
  final String createdAt;
  final String updatedAt;
  final MessageOwner messageOwner;
  bool isSeen;

  get getId => _id;
  get getAuthorID => _authorID;
  get getContactID => _contactID;
  get getChatID => _chatID;

  Message.message(this.isSeen, this._id, this.text, this._contactID, this._authorID, this._chatID, this.createdAt, this.updatedAt, this.messageOwner);

  Message.messageWithOwner(this.isSeen, this._id, this.text, this.messageOwner, this._contactID, this._chatID, this.createdAt, this.updatedAt, this._authorID);
}

class MessageOwner {
  final String id;
  final String username;
  final String name;
  final String profileImage;

  MessageOwner(this.id, this.username, this.name, this.profileImage);

}
