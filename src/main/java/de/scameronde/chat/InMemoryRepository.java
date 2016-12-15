package de.scameronde.chat;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import de.scameronde.chat.businesstypes.ChatRoom;
import de.scameronde.chat.businesstypes.MessageLog;
import de.scameronde.chat.businesstypes.Participant;

public class InMemoryRepository implements Repository {
  static int idcounter = 1;

  List<Participant> participants = new ArrayList<>();
  List<ChatRoom> chatRooms = new ArrayList<>();
  Map<ChatRoom, String> logs = new HashMap<>();

  public InMemoryRepository() {
    ChatRoom chatRoom1 = new ChatRoom(1, "Room 1");
    ChatRoom chatRoom2 = new ChatRoom(2, "Room 2");
    ChatRoom chatRoom3 = new ChatRoom(3, "Room 3");
    ChatRoom chatRoom4 = new ChatRoom(4, "Room 4");
    chatRooms.add(chatRoom1);
    chatRooms.add(chatRoom2);
    chatRooms.add(chatRoom3);
    chatRooms.add(chatRoom4);
    logs.put(chatRoom1, "");
    logs.put(chatRoom2, "");
    logs.put(chatRoom3, "");
    logs.put(chatRoom4, "");
  }

  @Override
  public Integer addParticipant(Participant participant) {
    int id = idcounter++;
    participant.setId(id);
    participants.add(participant);
    return id;
  }

  @Override
  public List<ChatRoom> getChatRooms() {
    return chatRooms;
  }

  @Override
  public Integer addChatRoom(ChatRoom chatRoom) {
    int id = idcounter++;
    chatRoom.setId(id);
    chatRooms.add(chatRoom);
    logs.put(chatRoom, "");
    return id;
  }

  @Override
  public void addMessage(ChatRoom chatRoom, String message, Participant participant) {
    logs.merge(chatRoom, message, String::concat);
  }

  @Override
  public MessageLog getMessageLog(ChatRoom chatRoom) {
    return new MessageLog(logs.get(chatRoom));
  }
}
