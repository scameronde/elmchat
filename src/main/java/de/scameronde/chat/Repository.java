package de.scameronde.chat;

import java.util.List;

public interface Repository {
  List<ChatRoom> getChatRooms();
  String getMessageLog(ChatRoom chatRoom);

  Integer addParticipant(Participant participant);
  Integer addChatRoom(ChatRoom chatRoom);
  void addMessage(ChatRoom chatRoom, String message, Participant participant);
}
