-- Ejercicio 1
-- a)

longitud :: [a] -> Int
longitud = foldr (\_ -> (+) 1) 0

-- b)

sumatoria :: [Int] -> Int
sumatoria = foldr (+) 0 

-- c)

pertenece :: Eq a => a -> [a] -> Bool
pertenece x = foldr (\y -> (||) (x == y)) False

-- d)
quitar :: Eq a => a -> [a] -> [a]
quitar _ [] = []
quitar e (y:ys) 
  | e == y = ys
  | otherwise = y : (quitar e ys)


-- Ejercicio 2
-- a)

cuadrados :: [Int] -> [Int]
cuadrados = map (^ 2)

positivos :: [Int] -> [Int]
positivos = filter (> 0)

-- b)
cantidad :: (a -> Bool) -> [a] -> Int
cantidad f = foldr (\y -> if f y then (+) 1 else (+) 0) 0

-- Ejercicio 3
data Arbol a = Hoja | Nodo (Arbol a) a (Arbol a)
  deriving Show
-- a)

insertar :: Ord a => a -> Arbol a -> Arbol a
insertar e Hoja =  Nodo Hoja e Hoja
insertar e (Nodo ramaIzq valor ramaDer) 
  | e == valor = (Nodo ramaIzq valor ramaDer)
  | e < valor  = Nodo (insertar e ramaIzq) valor ramaDer
  | otherwise  = Nodo ramaIzq valor (insertar e ramaDer)

-- b) 
estaEn :: Ord a => a -> Arbol a -> Bool
estaEn e Hoja = False
estaEn e (Nodo ramaIzq valor ramaDer) 
  | e == valor = True
  | e < valor = estaEn e ramaIzq 
  | otherwise = estaEn e ramaDer

-- c)

enOrden :: Arbol a -> [a]
enOrden Hoja = []
enOrden (Nodo ramaIzq valor ramaDer) = (enOrden ramaIzq) ++ [valor] ++ (enOrden ramaDer)

-- d) 
desdeLista :: Ord a => [a] -> Arbol a
desdeLista = foldr insertar Hoja

-- Nodo (Nodo (Nodo Hoja 1 Hoja) 2 Hoja) 3 (Nodo (Nodo (Nodo Hoja 4 Hoja) 5 Hoja) 6 Hoja)

-- Ejercicio 4
-- a)
safeHead :: [a] -> Maybe a
safeHead [] = Nothing
safeHead (y:_) = Just y

-- b) 
buscar :: Eq k => k -> [(k,v)] -> Maybe v
-- buscar e [] = Nothing
-- buscar e ((k,v): ys) 
--   | e == k = Just v
--   | otherwise = buscar e ys

buscar e = foldr (\(k, v) acc -> if e == k then Just v else acc) Nothing

-- c)
dividir :: Int -> Int -> Maybe Int
dividir _ 0 = Nothing
dividir e d = Just (div e d)

-- d)

data Cuenta = Cuenta {titular :: String, saldo :: Int}

depositar :: Int -> Cuenta -> Cuenta
depositar dinero c = c {saldo = saldo c + dinero}

etraer :: Int -> Cuenta -> Maybe Cuenta
etraer dinero c
  | dinero > saldo c = Nothing
  | otherwise = Just c {saldo = saldo c - dinero}

-- Monadas
-- Ejercicio 5
-- a)
calcular :: Int -> Int -> Int -> Maybe Int
calcular a b c = 
  case dividir a b of
    Nothing -> Nothing
    Just d -> case dividir d c of
      Nothing -> Nothing
      Just e -> Just (e + 1)

calcular2 :: Int -> Int -> Int -> Maybe Int
calcular2 a b c = do 
  d <- dividir a b
  e <- dividir d c
  return (e + 1)

calcular3 :: Int -> Int -> Int -> Maybe Int
calcular3 a b c = dividir a b >>= (\d -> dividir d c >>= (\e -> return (e + 1)))

-- b) 
transferir :: Int -> Cuenta -> Cuenta -> Maybe ( Cuenta , Cuenta )
transferir dinero origen destino = do
  origenNuevo <- etraer dinero origen 
  let destinoNuevo = depositar dinero destino
  return (origenNuevo, destinoNuevo)

-- c)
dividir2 :: Int -> Int -> Either String Int
dividir2 _ 0 = Left "error"
dividir2 e d = Right (div e d)

etraer2 :: Int -> Cuenta -> Either String Cuenta
etraer2 dinero c
  | dinero > saldo c = Left "error"
  | otherwise = Right c {saldo = saldo c - dinero}

transferir2 :: Int -> Cuenta -> Cuenta -> Either String ( Cuenta , Cuenta )
transferir2 dinero origen destino = do
  origenNuevo <- etraer2 dinero origen 
  let destinoNuevo = depositar dinero destino
  return (origenNuevo, destinoNuevo)

-- Ejercicio 6
-- a)
pares :: [a] -> [b] -> [(a, b)]
pares ls ys = do
  l <- ls
  y <- ys
  return (l, y)

-- b)
pitagoricas :: Int -> [(Int, Int, Int)]
pitagoricas n = do 
  c <- [0..n]
  b <- [0..c]
  a <- [0..b]
  if a^2 + b^2 == c^2 then return (a, b, c) else []

-- Ejercicio 7
-- a)
when :: Monad m => Bool -> m () -> m ()
when bool monad = if bool then monad else return ()

-- b)
replicateM_ :: Monad m => Int -> m a -> m ()
replicateM_ 0 _ = return ()
replicateM_ n accion = do 
  _ <- accion
  replicateM_ (n-1) accion

-- c)
mapM1 :: Monad m => (a -> m b) -> [a] -> m [b]
mapM1 _ [] = return []
mapM1 f (x:xs) = do
  y  <- f x
  ys <- mapM1 f xs
  return (y : ys)

-- d)
forM1_ :: Monad m => [a] -> (a -> m b) -> m ()
forM1_ [] f =  return ()
forM1_ (l:ls) f = do 
  y <- f l
  ys <- forM1_ ls f 
  return ()

-- e)
forever1 :: Monad m => m a -> m b
forever1 accion = do 
  _ <- accion 
  forever1 accion

-- Ejercicio 8
-- a)
saludar :: IO ()
saludar = do
  putStrLn "Ingrese su nombre:"
  nombre <- getLine
  putStrLn ("Hola " ++ nombre)

-- b)
sumarHastaCero :: IO Int
sumarHastaCero = do 
  linea <- getLine
  let num = read linea 
  if num /= 0 then do
    resto <- sumarHastaCero
    return (num + resto) 
    else return 0

-- Ejercicio 9
hola :: IO ()
hola = putStrLn " hola "

-- a)
programa1 :: IO ()
programa1 = do
  let x = hola  
  putStrLn " chau "

programa2 :: IO ()
programa2 = do
  let x = hola
  x
  x

programa3 :: IO ()
programa3 = do
  n <- return 5
  return 10
  print n

-- programa4 :: IO ()
-- programa4 = do
--   let as = [putStrLn " a " ,
--             putStrLn " b " ,
--             putStrLn " c " ]
--   as !! 2
--   head as

-- b)
repetir :: Int -> IO () -> IO ()
repetir 0 _ = return ()
repetir n accion = do 
  _ <- accion
  repetir (n-1) accion

-- repetir n accion
--   | n <= 0    = return ()
--   | otherwise = accion >> repetir (n - 1) accion

-- Ejercicio 10
adivinar :: Int -> IO ()
adivinar secreto = intentar 1
  where
    intentar :: Int -> IO ()
    intentar intentos = do
      linea <- getLine
      let num = read linea :: Int
      if num == secreto
        then putStrLn ("Muy bien! Lo adivinaste en " ++ show intentos ++ " intentos") 
        else do
          putStrLn (if secreto > num then "Es mas alto" else "Es mas bajo")
          intentar (intentos + 1)