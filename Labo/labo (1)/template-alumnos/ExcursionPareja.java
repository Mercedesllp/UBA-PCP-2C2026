// Volcan Lanin, parte 1.
import java.util.concurrent.Semaphore;

public class ExcursionPareja {
    static int STAGES = 5;

    // TODO

    public void caminarAndrea() throws InterruptedException {
        System.out.println("Andrea llega a la pirca");
        // TODO
        System.out.println("Andrea arranca el siguiente tramo");
    }

    public void caminarBernardo() throws InterruptedException {
        System.out.println("Bernardo llega a la pirca");
        // TODO
        System.out.println("Bernardo arranca el siguiente tramo");
    }

    public static void main(String[] args) throws InterruptedException {
        ExcursionPareja excursion = new ExcursionPareja();

        for (int stage = 1; stage <= STAGES; stage++) {
            System.out.println("--- tramo " + stage + " ---");


        }
    }
}
