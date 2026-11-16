# Guia 6 - Mensajes y canales

## Ejercicio 1

``` Go
type Cmd = String
Count = Cantidad de mensajes "Next" que recibio desde la última vez.

```

### a)
Definir una función que implementa el comportamiento del servidor (En Go, puede ser `func Srv(ch chan Cmd)` donde Cmd es un string que puede ser `"Next"` o `"Count"`).

``` Go
func Srv(ch chan Cmd){
  cantN := 0
  for {
    switch receive(ch, elem){
      case "Next": cantN++
      case "Count":
        print(cantN)
        cantN = 0
    }
  }
}
```

### b)
Definir una función para el cliente, que tome un valor entero `n`, un canal para comunicarse con el servidor e indefinidamente envíe `n` mensajes `"Next"` seguido de un mensaje `"Count"` (En Go, sería `Client(n int, ch chan Cmd)`)

``` Go
func Client(n int, ch chan Cmd){
  for{
    for int i := 0; i < n; i++{
      send(ch, "Next")
    }
    send(ch, "Count")
  }
}
```

### c)
Escribir una función main que cree un sistema compuesto por un servidor y dos clientes que comuniquen a través de un mismo canal.

``` Go
func main(){
  (chan Cmd) ch := create(chan Cmd, 0)
  n1 := randInt(20)
  n2 := randInt(20)
  process Srv(ch)
  process Client(n1, ch)
  process Client(n2, ch)
}
```

## Ejercicio 2
Modificar la solución anterior para hacer que el servidor en lugar de mostrar por
pantalla el número correspondiente, lo envíe al cliente y sea este último el que lo muestre por pantalla. Para ello, cada mensaje Count lleva adjunto un canal de respuesta por el cual el servidor devolverá el número (Cambie acordemente los tipos y signaturas que lo requieran).

``` Go
data Cmd = Next | Count (chan int)

func Srv(ch chan Cmd){
  cantN := 0
  for{
    switch receive(ch){
      case Next: cantN++
      case Count(chVuelta):
        send(chVuelta, cantN)
        cantN = 0
    }
  }
}

func Client(n int, ch chan Cmd){
  (chan int) chVuelta := create(chan int, 0)
  for{
    for int i := 0; i < n; i++{
      send(ch, Next)
    }
    send(ch, Count (chVuelta))
    cant := receive(chVuelta)
    print(cant)
  }
}

func main(){
  (chan Cmd) ch := create(chan Cmd, 0)
  n1 := randInt(20)
  n2 := randInt(20)
  process Srv(ch)
  process Client(n1, ch)
  process Client(n2, ch)
}
```

## Ejercicio 3
Se desea implementar un servidor que utiliza dos canales (pasados cómo parámetros) para comunicar con dos clientes. Cada cliente utiliza un canal para comunicar con el servidor números enteros. Cada cliente continuamente envía mensajes conteniendo números generados aleatoriamente (por ejemplo, con `rand.Intn`). El servidor continuamente espera recibir un par de mensajes (uno por cada cliente) y muestra por pantalla si los mismos coinciden o no. \
(Implementado en Go, sería un servidor `Srv(ch1, ch2 chan int)`, un cliente que fuera `Cliente(ch chan int)` y la función `main()`, que componga el sistema)

``` Go
func Srv(ch1, ch2 chan int){
  for{
    int numCliente1 = receive(ch1)
    int numCliente2 = receive(ch2)
  
    if numCliente1 == numCliente2{
      print("Son iguales y son ", numCliente1, " y ", numCliente2)
    } else{
      print("Son distintos y son ", numCliente1, " y ", numCliente2)
    }
  }
}

func Cliente(ch chan int){
  for{
    int num = rand.Int(100)
    send(ch, num)
  }
}

main(){
  (chan int) ch1 = create(chan int, 0)
  (chan int) ch2 = create(chan int, 0)

  process Cliente(ch1)
  process Cliente(ch2)
  process Srv(ch1, ch2)
}
```

## Ejercicio 4
Se desea definir un servidor que provea el siguiente comportamiento: debe generar
un número pseudoaleatorio entero en el rango [0,10]. El (en principio, único) cliente debe intentar adivinar el número que ha generado el servidor. Para ello envía sucesivamente mensajes conteniendo un número (puede usar cualquier estrategía para generar los números). Cada mensaje es contestado por el servidor indicando si el cliente acertó o no. El juego finaliza cuando el cliente
acierta.

+ Dar una implementación para el servidor y para el cliente (En Go, funciones Server y Cliente, con los parámetros que considere necesarios), más una implementación de un sistema consistente en un servidor y un cliente.
+ Modificar su solución de manera tal que varios clientes puedan usar secuencialmente al
servidor (Un cliente comienza a jugar cuando el anterior ha finalizado)
+ Dar una solución que permita a varios clientes jugar concurrentemente (cada uno debe
adivinar su propio número).

### a)
``` Go
func Srv(chACliente chan string, chAServidor chan int){
  int n = rand.Int(10)
  while(receive(chAServidor) != n){
    send(chACliente, "no encontrado")
  }
  send(chACliente, "encontrado")
}

func Cliente(chACliente chan string, chAServidor chan int){
  int num = rand.Int(10)
  send(chAServidor, num)
  while("no encontrado" ==  receive(chACliente)){
    int n = rand.Int(10)
    send(chAServidor, num)
  }
}

main(){
  (chan string) ch1 = create(chan string, 0)
  (chan int) ch2 = create(chan int, 0)

  process Cliente(ch1, ch2)
  process Srv(ch1, ch2)
}
```

### b)

``` Go
data Chs = Chs (chan int, chan bool)

func Srv(ch chan Chs){
  for{
    int n = rand.Int(10)
    Chs (chInt, chBool) = receive(ch)
    int num = receive(chInt)
    while(num != n){
      send(chBool, false)
      num = receive(chInt)
    }
    send(chBool, true)
  }
}

func Cliente(ch chan Chs){
    (chan int) chInt = create((chan int), 0)
    (chan bool) chBool = create((chan bool), 0)

    int num = rand.Int(10)
    send(ch, (chInt, chBool))
    send(chInt, num)
    bool encontrado = receive(chBool)  
    while(!encontrado){
      num = rand.Int(10)
      send(chInt, num)
      encontrado = receive(chBool)
    }

}

func main(){
  Chs ch = create(Chs, 0)
  process Srv(ch)
  process Cliente(ch) 
  process Cliente(ch) 
  process Cliente(ch) 
  process Cliente(ch) 
  process Cliente(ch) 
}
```

### c)

``` Go
data Chs = chan (chan bool, int)
data ChanCli = chan (int, int)

func Srv(ch Chs, chInt ChanCli){
  (map[int](chan bool,int)) dic = make(map[int](chan bool,int))
  
  for{
    select{
      case (chan bool, int) (chBool, id) = receive(ch):
        int n = rand.Int(10)
        dic[id] = (chBool, n)
      case (int, int) (id, num) = receive(chInt):
        (chan bool, int) (chBool, n) = dic[id]
        send(chBool, n == num)
    }
  }
}

func Cliente(ch Chs, chInt ChanCli, id int){
  (chan bool) chBool = create((chan bool), 0)

  send(ch, (chBool, id))
  bool encontrado = false  
  while(!encontrado){
    int num = rand.Int(10)
    send(chInt, (id, num))
    encontrado = receive(chBool)
  }
}

func main(){
  Chs ch = create(Chs, 0)
  ChanCli chInt = create(ChanCli, 0)
  process Srv(ch, chInt)
  process Cliente(ch, chInt, 0) 
  process Cliente(ch, chInt, 1) 
  process Cliente(ch, chInt, 2) 
  process Cliente(ch, chInt, 3) 
  process Cliente(ch, chInt, 4) 
}
```

## Ejercicio 5
Para este ejercicio, suponga que sólo cuenta con canales sincrónicos e implemente
un canal asincrónico de capacidad (virtualmente) ilimitada, usando un canal de entrada y uno de salida. (En Go, implemente una función `AsyncChan` que use los canales `entrada` y `salida` de tipo `chan any` (`any` es lo mismo que `interface{}`))

``` Go
func AsynChan(entrada, salida chan any){
  any[] elementos = []
  for{
    if(len(elementos) == 0){
      any elem = receive(entrada)
      elementos.append(entrada)
    }else{
      select{
        case any elem = receive(entrada):
          elementos.append(entrada)
        case send(salida, elementos[0]):
          elementos = [1:]
      }
    }
  }
}
```

## Ejercicio 6
¿Cómo modificaría la solución del ejercicio 4 si el modelo de comunicación es
asincrónico y el cliente puede enviar mensajes aún cuando el servidor no ha respondido a los mensajes anteriores?

## Ejercicio 7
Se desea definir un servidor que funcione como una variable compartida a la que
los clientes pueden acceder mediante oportunos mensajes.

+ Dar una solución considerando comunicación sincrónica.
+ ¿Es correcta su solución si la comunicacación es asincrónica? En caso contrario, modificar la solución anterior.

### a)
``` Go 
func servidor(chRecibir chan any, chEnviar chan (chan any)){
  any variable = nil
  for{
    select{
      case any val = receive(chRecibir):
        variable = val
      case (chan any) ch = receive(chEnviar):
        send(ch, variable)
    } 
  }
}
```