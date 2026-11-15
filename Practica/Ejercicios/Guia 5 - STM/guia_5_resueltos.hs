import Control.Concurrent.STM
import Control.Concurrent.Async

-- Ejercicio 1
-- a) 
get1 :: TVar ( Maybe t ) -> STM ( Maybe t )
get1 var = do 
  v <- readTVar var
  writeTVar var Nothing
  return v

put1 :: TVar ( Maybe t ) -> t -> STM Bool
put1 var val = do
  v <- readTVar var 
  case v of
    Nothing -> do
      writeTVar var (Just val)
      return True
    Just _ -> return False

-- b)
programa1b :: IO ()   
programa1b = do 
  buffer <- newTVarIO (Just 0)
  thread1 <- async (atomically (get1 buffer))
  thread2 <- async (atomically (put1 buffer 1))  

  v <- wait thread1
  _ <- wait thread2
  print v

-- c)
get2 :: TVar ( Maybe b ) -> STM b
get2 buff = do
  v <- readTVar buff
  case v of 
    Nothing -> retry
    Just res -> do 
      writeTVar buff Nothing
      return res

put2 :: TVar ( Maybe t ) -> t -> STM ()
put2 buff val = do
  v <- readTVar buff 
  case v of
    Nothing -> writeTVar buff (Just val)
    Just _ -> retry

-- d)
leer :: TVar ( Maybe b ) -> STM b
leer buff = do
  v <- readTVar buff
  case v of 
    Nothing -> retry
    Just res -> return res

-- Ejercicio 2
initSem :: STM (TVar Int)
initSem = newTVar 0

waitSem :: TVar Int -> STM ()
waitSem var = do
  val <- readTVar var
  check (val > 0)
  writeTVar var (val - 1)

signalSem :: TVar Int -> STM ()
signalSem var = do
  val <- readTVar var
  writeTVar var (val + 1)

programa2b :: IO ()
programa2b = do
  sem <- atomically initSem
  t1 <- async (atomically (tomarDos sem))
  t2 <- async (atomically (signalSem sem))
  t3 <- async (atomically (signalSem sem))
  wait t1
  wait t2
  wait t3
  where
    tomarDos s = do
      waitSem s
      waitSem s

-- Ejercicio 3
data Juego = Juego { bolsa :: TVar Int, cantGeneradores :: TVar Int }

nuevoJuego :: IO Juego
nuevoJuego = do
  b <- newTVarIO 0
  g <- newTVarIO 0
  return Juego { bolsa = b, cantGeneradores = g }

-- Para contar la cantidad de generadores de manera dinamica
entrarGenerador :: Juego -> STM ()
entrarGenerador j = modifyTVar' (cantGeneradores j) (+1)

salirGenerador :: Juego -> STM ()
salirGenerador j = do
  g <- readTVar (cantGeneradores j)
  b <- readTVar (bolsa j)
  check (b <= g - 1)
  writeTVar (cantGeneradores j) (g - 1)

ponerBolita ::  Juego -> STM ()
ponerBolita j = do
  bolitas <- readTVar (bolsa j)
  generadores <- readTVar (cantGeneradores j)
  check(generadores >= bolitas)
  writeTVar (bolsa j) (bolitas + 1)

tomarPar :: Juego -> STM ()
tomarPar j = do
  bolitas <- readTVar (bolsa j)
  check(bolitas > 1)
  writeTVar (bolsa j) (bolitas - 2)

generador :: Juego -> String -> Int -> IO ()
generador j nombre rondas = do
  atomically (entrarGenerador j)
  puntos <- jugar rondas 0
  atomically (salirGenerador j)
  putStrLn (nombre ++ ": " ++ show puntos ++ " puntos")
  where
    jugar 0 p = return p
    jugar k p = do 
      atomically (ponerBolita j) 
      jugar (k - 1) (p + 1)

consumidor :: Juego -> String -> Int -> IO ()
consumidor j nombre rondas = do
  puntos <- jugar rondas 0
  putStrLn (nombre ++ ": " ++ show puntos ++ " puntos")
  where
    jugar 0 p = return p
    jugar k p = do 
      atomically (tomarPar j) 
      jugar (k - 1) (p + 1)

programa3 :: IO ()
programa3 = do
  j <- nuevoJuego
  hilos <- mapM async
    [ generador  j "G1" 10, generador  j "G2" 10
    , consumidor j "C1" 5,  consumidor j "C2" 5 ]
  mapM_ wait hilos
