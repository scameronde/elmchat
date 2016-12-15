package de.scameronde.chat;

public class ChatRoom {
  Integer id;
  String title;

  public ChatRoom() {

  }

  public ChatRoom(Integer id, String title) {
    this.id = id;
    this.title = title;
  }

  public String getTitle() {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public Integer getId() {
    return id;
  }

  public void setId(Integer id) {
    this.id = id;
  }
}
