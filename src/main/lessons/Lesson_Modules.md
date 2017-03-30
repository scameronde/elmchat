# Komposition von Benutzeroberflächen

- Aufteilen in Graph
- nur Blätter haben eigene Models und Views
- Knoten sind rein zur Koordination da
- es gibt zwei Arten von Knoten
  - Summenknoten: es wird nur eines der Blätter gleichzeitig dargestellt und sein Modell im Speicher gehalten
  - Produktknoten: es werden alle Blätter gleichzeitig dargestellt und die Modelle im Speicher gehalten
- Die Kommunikation von den Knoten nach Unten zu anderen Knoten und Blättern erfolgt über den Aufruf der
  Lebenszyklus Functions (init, update, view, subscriptions)
- Die Kommunikation von Blättern und Knoten nach Oben erfolgt über Messages

