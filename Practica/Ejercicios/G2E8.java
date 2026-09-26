import java.util.concurrent.Semaphore;
import java.util.concurrent.ThreadLocalRandom;

// Al final hay que asumir que el consumidor consume infinitamente al igual que el generador
// para esto hay que usar semaforos para que se complan las condiciones de la bolsa
// VER EN MARKDOWN


public class G2E8 {

  static int CANTCONSUMIDORES = 10;
  static int CANTGENERADORES = 20;
  static int CANTPARTICIPANTES = CANTCONSUMIDORES + CANTGENERADORES;
  static int CANTBOLSAS = 2;
  int puntajeC = 0;
  int puntajeG = 0;

  int bolsa = 0;
  Semaphore mutex = new Semaphore(1, true);

  public void generar() throws
  InterruptedException{

    mutex.acquire();
    // Si hay alguna bolsa en la que pueda meter una bolita lo hace y termina
    while(bolsa <= CANTGENERADORES){
      bolsa ++;
      puntajeG ++;
      break;
    }
     mutex.release();
  }

  public void consumir() throws
  InterruptedException{
    mutex.acquire();
    // Si hay alguna bolsa de la que pueda sacar 2 bolitas lo hace y termina (no entiendo si deberia esperar a que haya bolitas, si espera entonces ahi si tiene sentido el deadlock)
    while(bolsa >= 2){
      bolsa -= 2;
      puntajeC ++;
      break;
    }
    mutex.release();
  }

  public static void main(String[] args) throws
  InterruptedException{
    G2E8 game = new G2E8();

    Thread[] participantes = new Thread[CANTPARTICIPANTES];
    // distribucion tiene la cantidad de generadores en la primera posicion y la cantidad de consumidores en la segunda
    int[] distribucion = {CANTGENERADORES, CANTCONSUMIDORES};
    Semaphore mutexRandom = new Semaphore(1,true);

    for(int i = 0; i < CANTPARTICIPANTES; i++){
      int id = i;

      participantes[id] = new Thread(() ->{
        try{
          boolean esGenerador = false;
          int random = ThreadLocalRandom.current().nextInt(0, 2);
          mutexRandom.acquire();
          if(distribucion[random] > 0){
            esGenerador = (random == 0);
            distribucion[random] --;
          } else{
            int otro = 1 - random;
            esGenerador = (otro == 0);
            distribucion[otro] --;
          }
          mutexRandom.release();
          if(esGenerador){
            System.out.println("Llega un generador " + id);
            game.generar();
            System.out.println("Termina generador " + id);
          } else{
            System.out.println("Llega un consumidor " + id);
            game.consumir();
            System.out.println("Termina consumidor " + id);
          }
        } catch (InterruptedException e){
          Thread.currentThread().interrupt();
        }
      });
    }

    for (Thread t : participantes) t.start();
    for (Thread t : participantes) t.join();

    System.out.println("Puntaje Generadores: " + game.puntajeG + " puntos");
    System.out.println("Puntaje Consumidores: " + game.puntajeC + " puntos");

  }
}
