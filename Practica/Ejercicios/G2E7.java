import java.util.concurrent.Semaphore;
import java.util.concurrent.ThreadLocalRandom; 

public class G2E7 {
  static int CLIENTES = 3;
  static int DISCOSTOTALES = 10;
  Semaphore mutex = new Semaphore(1);

  // Hay una cola para los que esperan la liberacion de los discos(? Por eso es fair
  Semaphore discos = new Semaphore(DISCOSTOTALES, true); 

  Semaphore[] maquinas = new Semaphore[]{
    new Semaphore(1),
    new Semaphore(2),
    new Semaphore(2),
    new Semaphore(1),
  };
  
  public void tomarMaquina(int nroMaquina, int cantDiscos, int duracion) throws
  InterruptedException{
    if(cantDiscos > DISCOSTOTALES){
      throw new RuntimeException("Anda a otro gym, aca no hay tantos discos") {};
    }
    
    Semaphore maq = maquinas[nroMaquina];

    // Toma la maquina y luego los discos
    maq.acquire();
    discos.acquire(cantDiscos);

    // Ejercita
    Thread.sleep(duracion);

    // Devuelve los discos y libera la maquina
    discos.release(cantDiscos);
    maq.release();
  }

  public static void main() throws
  InterruptedException{
    G2E7 gym = new G2E7();

    Thread[] clients = new Thread[CLIENTES];

    for(int i = 0; i < CLIENTES; i++){
      int id = i;
      clients[i] = new Thread(() ->{
        try {
          System.out.println("Llega un cliente " + id);

          // El cliente usa una maquina random con cant de discos random
          int m = ThreadLocalRandom.current().nextInt(0, gym.maquinas.length); 
          int c = ThreadLocalRandom.current().nextInt(0, DISCOSTOTALES + 1); 
          int d = 0;
          // Aca podria crear una rutina para cada cliente pero voy a dejarlo en que la rutina de cada cliente se basa en un ejercicio 
          gym.tomarMaquina(m, c, d);
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
