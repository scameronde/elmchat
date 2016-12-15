package de.scameronde.chat;

public class Message {
  Participant participant;
  String message;

  public Message() {

  }

  public Message(Participant participant, String message) {
    this.participant = participant;
    this.message = message;
  }


  public Participant getParticipant() {
    return participant;
  }

  public void setParticipant(Participant participant) {
    this.participant = participant;
  }

  public String getMessage() {
    return message;
  }

  public void setMessage(String message) {
    this.message = message;
  }
}
