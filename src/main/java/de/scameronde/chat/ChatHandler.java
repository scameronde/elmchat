package de.scameronde.chat;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;

import org.eclipse.jetty.websocket.api.Session;
import org.eclipse.jetty.websocket.api.annotations.OnWebSocketClose;
import org.eclipse.jetty.websocket.api.annotations.OnWebSocketConnect;
import org.eclipse.jetty.websocket.api.annotations.OnWebSocketMessage;
import org.eclipse.jetty.websocket.api.annotations.WebSocket;

@WebSocket
public class ChatHandler {
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
    System.out.println("received: " + message);
    if (message.startsWith("participant:")) {
      String participantIdAsString = message.substring(message.indexOf(":") + 1, message.indexOf(","));
      String participantName = message.substring(message.indexOf(",") + 1);
      sessions.get(session).participantId = Integer.valueOf(participantIdAsString);
      sessions.get(session).participantName = participantName;
    }
    else if (message.startsWith("chatRoom:")) {
      String chatRoomIdAsString = message.substring(message.indexOf(":") + 1);
      sessions.get(session).chatRoomId = Integer.valueOf(chatRoomIdAsString);
    }
    else if (message.startsWith("message:")) {
      Integer myChatRoomId = sessions.get(session).chatRoomId;
      String newMessage = sessions.get(session).participantName + " > " + message.substring(message.indexOf(":") + 1);
      List<Session> sessionList = sessions.entrySet()
                                          .stream()
                                          .filter(entry -> entry.getValue().chatRoomId == myChatRoomId)
                                          .map(entry -> entry.getKey())
                                          .collect(Collectors.toList());

      for (Session otherSession : sessionList) {
        otherSession.getRemote().sendString(newMessage); // and send it back
      }
    }
  }


  private class SessionInfo {
    public Integer participantId;
    public String participantName;
    public Integer chatRoomId;
  }
}
