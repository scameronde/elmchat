package de.scameronde.chat;

import static spark.Spark.get;
import static spark.Spark.options;
import static spark.Spark.post;
import static spark.Spark.webSocket;

import java.io.IOException;
import java.io.StringWriter;
import java.util.List;
import java.util.Optional;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;

import javaslang.control.Either;
import spark.Request;
import spark.Response;

public class Server {
  static Repository repository = new InMemoryRepository();

  public static void main(String[] args) {
    // register web socket endpoint for all running chats
    webSocket("/chat", ChatHandler.class);

    // this is only necessary for cross site development
    options("/*", ((request, response) -> allowCrossOriginRequests(response)));

    // get all known chat rooms
    get("/chatRoom", ((request, response) -> {
      List<ChatRoom> chatRooms = repository.getChatRooms();
      Either<Exception, String> jsonChatRooms = dataToJson(chatRooms);
      return createResponse(response, jsonChatRooms);
    }));

    // get chat history for a chat room
    get("/chatRoom/:chatRoomId", ((request, response) -> {
      Integer id = getIntParameter(request, ":chatRoomId");
      Optional<ChatRoom> chatRoom = findChatRoom(id);
      Optional<String> messageLog = chatRoom.map(cr -> repository.getMessageLog(cr));
      Either<Exception, Optional<String>> jsonMessageLog = dataToJson(messageLog);
      return createOptionalResponse(response, jsonMessageLog);
    }));

    // make a participant known to the system and return its id back to the caller
    post("/participant", ((request, response) -> {
      Either<Exception, Participant> participant = jsonToData(request.body(), Participant.class);
      if (participant.isRight()) {
        Integer id = repository.addParticipant(participant.right().get());
        Either<Exception, String> jsonId = participant.map(p -> id.toString());
        return createResponse(response, jsonId);
      }
      else {
        return createResponse(response, participant.map(p -> ""));
      }
    }));

    // make a chat room known to the system and return its id back to the caller
    post("/chatRoom", ((request, response) -> {
      Either<Exception, ChatRoom> chatRoom = jsonToData(request.body(), ChatRoom.class);
      if (chatRoom.isRight()) {
        Integer id = repository.addChatRoom(chatRoom.right().get());
        Either<Exception, String> jsonId = chatRoom.map(c -> id.toString());
        return createResponse(response, jsonId);
      }
      else {
        return createResponse(response, chatRoom.map(c -> ""));
      }
    }));
  }

  private static Optional<ChatRoom> findChatRoom(Integer id) {
    return repository.getChatRooms()
                     .stream()
                     .filter(room -> room.getId() == id)
                     .findFirst();
  }

  private static Object allowCrossOriginRequests(Response response) {
    response.header("Access-Control-Allow-Origin", "*");
    response.header("Access-Control-Allow-Methods", "POST, GET, PUT, DELETE, OPTIONS");
    response.header("Access-Control-Allow-Credentials", "false");
    response.header("Access-Control-Max-Age", "86400"); // 24 hours
    response.header("Access-Control-Allow-Headers", "X-Requested-With, X-HTTP-Method-Override, Content-Type, Accept");

    response.status(204);
    return "";
  }

  private static String createResponse(Response response, Either<Exception, String> payload) {
    if (payload.isRight()) {
      String payloadData = payload.right().get();
      setResponseOK(response);
      return payloadData;
    }
    else {
      setResponseError(response);
      return payload.left().get().getMessage();
    }
  }

  private static String createOptionalResponse(Response response,
                                               Either<Exception, Optional<String>> payload) {
    if (payload.isRight()) {
      Optional<String> payloadData = payload.right().get();
      if (payloadData.isPresent()) {
        setResponseOK(response);
        return payloadData.get();
      }
      else {
        setResponseNotFound(response);
        return "";
      }
    }
    else {
      setResponseError(response);
      return payload.left().get().getMessage();
    }
  }

  private static void setResponseError(Response response) {
    response.status(500);
    response.type("application/text");
    response.header("Access-Control-Allow-Origin", "*");
  }

  private static void setResponseOK(Response response) {
    response.status(200);
    response.type("application/json");
    response.header("Access-Control-Allow-Origin", "*");
  }

  private static void setResponseNotFound(Response response) {
    response.status(404);
    response.type("application/text");
    response.header("Access-Control-Allow-Origin", "*");
  }


  static Integer getIntParameter(Request request, String parameter) {
    String param = request.params(":chatRoomId");
    return Integer.parseInt(param);
  }

  private static <T> Either<Exception, Optional<String>> dataToJson(Optional<T> data) {
    if (data.isPresent()) {
      return internalDataToJson(data.get()).map(json -> Optional.of(json));
    }
    else {
      return Either.right(Optional.empty());
    }
  }

  private static <T> Either<Exception, String> dataToJson(T data) {
    return internalDataToJson(data);
  }

  private static <T> Either<Exception, String> internalDataToJson(T data) {
    try {
      ObjectMapper mapper = new ObjectMapper();
      mapper.enable(SerializationFeature.INDENT_OUTPUT);
      StringWriter sw = new StringWriter();
      mapper.writeValue(sw, data);
      sw.close();
      return Either.right(sw.toString());
    }
    catch (IOException e) {
      e.printStackTrace();
      return Either.left(e);
    }
  }

  private static <T> Either<Exception, T> jsonToData(String json, Class<T> clazz) {
    try {
      ObjectMapper mapper = new ObjectMapper();
      T creation = mapper.readValue(json, clazz);
      return Either.right(creation);
    }
    catch (IOException e) {
      e.printStackTrace();
      return Either.left(e);
    }
  }
}
