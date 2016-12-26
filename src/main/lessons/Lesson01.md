# Main und Types

## Schritt 1 - main

- Ein leeres Modul mit der Funktion `main` anlegen und Compiler Fehler
  bewundern.
  
  ```
  main = "Hello World!"
  ```
  
- `main` Funktion korrigieren (import von Html nicht vergessen) und den Compiler
  die Typannotation bestimmen lassen.
  
  ```
  main = text "Hello World!"
  ```
  
  
## Schritt 2 - Types

Die verschiedenen Typen zeigen und vom Compiler bestimmen lassen.

- Simple Types

  ```elm
  -- Simple Types

  a = True

  b = 5
  
  c = 6.6
  
  d = 'a'
  
  e = "Ein String"
  
  f = """
  Noch ein String
  """
  ```

- Aggregated Types

  ```elm
  -- Aggregated Types
  g = [ 5, 4, 3 ]
  
  h = ( 5, True, "Hi" )
  
  i = { id = 5, name = "Peter" }
  ```

- Function Type

  ```elm
  -- Function Type    
  j = text

  ```
  
- Summentypen

  ```elm
  -- Sum Type
  type Ampel = Gruen | Gelb | Rot
  
  type Ergebnis = Fehler String | OK Int
  
  type Ergebnis_ a = Fehler_ String | OK_ a
  ```

- Type Alias
  
  ```elm
  -- Type Alias
  type alias Id = Int
  
  type alias Punkt = ( Int, Int )
  
  type alias Moderator = { id : Id, name : String }
  ```

## Schritt 3 - Records (Product Type)
  
- Erzeugen von Records

  ```
  i1 = {id = 6, name = "Klaus" }
  
  i2 = Moderator 7 "Gerd"
  ```
  
- Zugriff auf Records

  ```
    i.id
    .id i
    
    i.name
    .name i
  ```

- "Ändern" von Records

  ```elm
  z1 = Moderator 1 "Steffen"

  z2 = {z1 | name = "Klaus"}
  ```


  
## Schritt 4 - Functions

- Function Aplication and Composition

  ```elm
  add2 value = value + 2
  mult2 value = value * 2
  
  mult2Add2 value = add2 (mult2 value)
  
  mult2Add2_ value = add2 <| mult2 value
  
  mult2Add2__ value = add2 <| mult2 <| value
  
  mult2Add2___ value = value |> mult2 |> add2
  
  mult2Adder2 = add2 << mult2
  mult2Adder2_ = mult2 >> add2
  ```
  
