package de.scameronde.chat;

import static de.scameronde.chat.JsonUtils.jsonToData;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;

import de.scameronde.chat.businesstypes.ChatRegistration;
import de.scameronde.chat.businesstypes.ChatRoom;
import de.scameronde.chat.businesstypes.Message;
import de.scameronde.chat.businesstypes.Participant;

import org.eclipse.jetty.websocket.api.Session;
import org.eclipse.jetty.websocket.api.annotations.OnWebSocketClose;
import org.eclipse.jetty.websocket.api.annotations.OnWebSocketConnect;
import org.eclipse.jetty.websocket.api.annotations.OnWebSocketMessage;
import org.eclipse.jetty.websocket.api.annotations.WebSocket;

import javaslang.control.Either;

@WebSocket
public class ChatHandler {
  private static Repository repository;
  HashMap<Session, SessionInfo> sessions = new HashMap<>();

  @OnWebSocketConnect
  public void connected(Session session) {
    sessions.put(session, new SessionInfo());
  }

  @OnWebSocketClose
  public void closed(Session session, int statusCode, String reason) {
    sessions.remove(session);
  }

  @OnWebSocketMessage
  public void message(Session session, String message) throws IOException {
    if (isMessageOfType(message, "registration")) {
      String messageBody = getMessageBody(message);
      Either<Exception, ChatRegistration> chatRegistration = jsonToData(messageBody, ChatRegistration.class);
      if (chatRegistration.isRight()) {
        sessions.get(session).participant = chatRegistration.get().getParticipant();
        sessions.get(session).chatRoom = chatRegistration.get().getChatRoom();
      }
    }
    else if (isMessageOfType(message, "message")) {
      String messageBody = getMessageBody(message);
      Either<Exception, Message> chatMessage = jsonToData(messageBody, Message.class);

      if (chatMessage.isRight()) {
        ChatRoom chatRoom = sessions.get(session).chatRoom;
        Participant participant = sessions.get(session).participant;

        String newMessage = participant.getName() + " > " + chatMessage.get().getMessage() + "\n";
        repository.addMessage(chatRoom, newMessage, participant);
        List<Session> recipients = sessions.entrySet()
                                           .stream()
                                           .filter(entry -> entry.getValue().chatRoom.equals(chatRoom))
                                           .map(entry -> entry.getKey())
                                           .collect(Collectors.toList());

        for (Session otherSession : recipients) {
          otherSession.getRemote().sendString(newMessage); // and send it back
        }
      }
    }
  }


  private boolean isMessageOfType(String message, String messageType) {
    return message.startsWith(messageType + ":");
  }

  private String getMessageBody(String message) {
    return message.substring(message.indexOf(":") + 1);
  }

  private class SessionInfo {
    public Participant participant;
    public ChatRoom chatRoom;
  }

  public static void setRepository(Repository repository) {
    ChatHandler.repository = repository;
  }
}
