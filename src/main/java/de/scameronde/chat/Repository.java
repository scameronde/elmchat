package de.scameronde.chat;

import java.util.List;

import de.scameronde.chat.businesstypes.ChatRoom;
import de.scameronde.chat.businesstypes.MessageLog;
import de.scameronde.chat.businesstypes.Participant;

public interface Repository {
  String addParticipant(Participant participant);

  List<ChatRoom> getChatRooms();

  String addChatRoom(ChatRoom chatRoom);

  void deleteChatRoom(ChatRoom chatRoom);

  void addMessage(ChatRoom chatRoom, String message, Participant participant);

  MessageLog getMessageLog(ChatRoom chatRoom);
}
