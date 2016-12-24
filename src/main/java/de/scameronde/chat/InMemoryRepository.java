package de.scameronde.chat;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import de.scameronde.chat.businesstypes.ChatRoom;
import de.scameronde.chat.businesstypes.MessageLog;
import de.scameronde.chat.businesstypes.Participant;

public class InMemoryRepository implements Repository {
  static Integer idcounter = 100;

  List<Participant> participants = new ArrayList<>();
  List<ChatRoom> chatRooms = new ArrayList<>();
  Map<ChatRoom, String> logs = new HashMap<>();

  public InMemoryRepository() {
    ChatRoom chatRoom1 = new ChatRoom("1", "Room 1");
    ChatRoom chatRoom2 = new ChatRoom("2", "Room 2");
    chatRooms.add(chatRoom1);
    chatRooms.add(chatRoom2);
    logs.put(chatRoom1, "");
    logs.put(chatRoom2, "");
  }

  @Override
  public String addParticipant(Participant participant) {
    String id = String.valueOf(idcounter++);
    participant.setId(id);
    participants.add(participant);
    return id;
  }

  @Override
  public List<ChatRoom> getChatRooms() {
    return chatRooms;
  }

  @Override
  public String addChatRoom(ChatRoom chatRoom) {
    String id = String.valueOf(idcounter++);
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
