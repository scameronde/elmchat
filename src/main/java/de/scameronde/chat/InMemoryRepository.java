package de.scameronde.chat;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class InMemoryRepository implements Repository {
  static int idcounter = 1;

  List<Participant> participants = new ArrayList<>();
  List<ChatRoom> chatRooms = new ArrayList<>();
  Map<ChatRoom, String> logs = new HashMap<>();

  public InMemoryRepository() {
    chatRooms.add(new ChatRoom(1, "Room 1"));
    chatRooms.add(new ChatRoom(2, "Room 2"));
    chatRooms.add(new ChatRoom(3, "Room 3"));
    chatRooms.add(new ChatRoom(4, "Room 4"));
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
    String longMessage = participant.toString() + " > " + message;
    logs.merge(chatRoom, longMessage, String::concat);
  }

  @Override
  public String getMessageLog(ChatRoom chatRoom) {
    return logs.get(chatRoom);
  }
}
