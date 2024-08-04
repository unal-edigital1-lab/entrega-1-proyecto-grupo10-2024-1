# Entrega 1 del proyecto WP01
## 1.1 Diagrama de flujo

## 1.2 Unidad de control (States Machine)

## 1.3 Data path

## 1.4 Máquina de estados finita


## 1.2  Especificación de los componentes:

### 1.2.1  Visualización

La visualización principal se llevará a cabo en un LCD gráfico 128X64 (posible modelo: WG12864A)
Aquí es donde mostraremos el tamagotchi, así como también las barras del estado.

<img src="https://github.com/unal-edigital1-lab/entrega-1-proyecto-grupo10-2024-1/assets/159223904/ba9cd04e-095f-4776-ba77-2e0c4786a495.type" width="600" height="600">

EL display de 7 segmentos se usará con el fin de brindar un apoyo visualizando puntajes y valores adicionales.


### 1.2.2  Botones

1. Rst
2. Test
3. Interacción 1
4. Interacción 2

El sistema de puntos se hará por medio de una barra seccionada en 10 partes iguales para cada uno de los 5 estados:

1. Hambre
2. Diversión
3. Descanso
4. Salud
5. Felicidad

Ejemplo:
					
![image](https://github.com/unal-edigital1-lab/entrega-1-proyecto-grupo10-2024-1/assets/160156354/edf32659-d83f-4001-9073-475089ce37f8)


En la imagen se observa que el estado hambre tiene solo 7 partes de las 10, le harían falta 3 partes para poder satisfacer al 100% esta necesidad


Las siguientes serán las acciones que podrá hacer el usuario:

1. Jugar
2. Alimentar
3. Curar
4. Dormir
5. Bañar

Para navegar dentro de este menú y poder desplazarse en él, el usuario debe pulsar el botón interacción 1.
Se debe seleccionar una acción, para después pulsar el botón interacción 2, el cual hará que aumente o disminuya en un cuadro cada uno de los estados; lo anterior se describe mejor en la siguiente tabla

![image](https://github.com/unal-edigital1-lab/entrega-1-proyecto-grupo10-2024-1/assets/160156354/e66e6899-7950-4c67-8362-c5af024e3287)

En donde;

- 1 : Aumenta un cuadro
- 0 : Disminuye un cuadro
- -: Se mantiene igual

Entonces, si por ejemplo se pulsa la acción jugar, todos los estados aumentarán en un cuadro excepto el descanso, al cual se le quitará un cuadro.

SI NO SE REALIZA NINGUNA ACCIÓN EN 15 MINUTOS, CADA ESTADO DISMINUIRÁ UN CUADRO


### 1.2.3  Sensor de luz

Se usará el sensor de luz IM120710017, el cual usa un fotoresistencia GL5528.

<img src="https://github.com/unal-edigital1-lab/entrega-1-proyecto-grupo10-2024-1/assets/159223904/154563b2-ced3-43cc-8fbd-30481ccec982.type" width="656" height="476">

Interacción con el sensor de luz: 

- 1: si el sensor detecta oscuridad durante 5 segundos el bicho se duerme automáticamente
-  0: si hay luz 
