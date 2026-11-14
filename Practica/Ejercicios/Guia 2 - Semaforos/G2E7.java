import java.util.concurrent.Semaphore;
import java.util.concurrent.ThreadLocalRandom;

public class G2E7 {
  static int CLIENTES = 3;
  static int DISCOSTOTALES = 10;
  Semaphore turnstile = new Semaphore(1, true);

  Semaphore discosDisponibles = new Semaphore(DISCOSTOTALES, true);
  boolean estoyEsperando = false;

  Semaphore[] maquinas = new Semaphore[]{
    new Semaphore(1,true),
    new Semaphore(2,true),
    new Semaphore(2,true),
    new Semaphore(1,true),
  };

  public void tomarMaquina(int nroMaquina, int cantDiscos, int duracion) throws
  InterruptedException{
    if(cantDiscos > DISCOSTOTALES){
      throw new RuntimeException("Anda a otro gym, aca no hay tantos discos") {};
    }

    Semaphore maq = maquinas[nroMaquina];

    // Toma la maquina y luego los discos
    maq.acquire();

    turnstile.acquire();
    // De esta manera simula lo que sucede en pseudocodigo pq en java .acquire(int) es atomico
    for(int i = 0; i < cantDiscos; i++){
        discosDisponibles.acquire();
    }
    turnstile.release();

    // Ejercita
    Thread.sleep(duracion);

    // Devuelve los discos y libera la maquina
    for(int i = 0; i < cantDiscos; i++){
        discosDisponibles.release();
    }
    maq.release();
  }

  public static void main(String[] args) throws
  InterruptedException{
    G2E7 gym = new G2E7();

    Thread[] clients = new Thread[CLIENTES];

    for(int i = 0; i < CLIENTES; i++){
      int id = i;
      clients[i] = new Thread(() ->{
        try {
          // Hace una cantidad de ejercicios en su rutina menor o igual a la cantidad de maquinas en el gym
          int cantEjercicios = ThreadLocalRandom.current().nextInt(1, gym.maquinas.length + 1);
          System.out.println("Llega un cliente " + id + " y va a hacer " + cantEjercicios + " ejercicios");
          for(int j = 0; j < cantEjercicios; j++){
            int m = ThreadLocalRandom.current().nextInt(0, gym.maquinas.length);
            int c = ThreadLocalRandom.current().nextInt(0, DISCOSTOTALES + 1);
            int d = 0; // Duracion del ejercicio, podria ser otra forma
            gym.tomarMaquina(m, c, d);
          }
          System.out.println("Se va el cliente " + id);
        } catch (InterruptedException e){
          Thread.currentThread().interrupt();
        }
      });
    }

    for (Thread t : clients) t.start();
    for (Thread t : clients) t.join();
  }
}
