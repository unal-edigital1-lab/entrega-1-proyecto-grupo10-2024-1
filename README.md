# Entrega 1 del proyecto WP01
### 1. Cajas negras
![diagrama caja](https://github.com/unal-edigital1-lab/entrega-1-proyecto-grupo10-2024-1/assets/160156354/65799273-b1e6-485b-99a4-61b6771c8025)

### 2.  Máquina de estado finita

Botones:

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


Las siguientes serán las acciones que podrá hacer el usuario al momento de estar dentro del menú test:

1. Jugar
2. Alimentar
3. Curar
4. Dormir
5. Bañar

Para navegar dentro de este menú y poder desplazarse en él, el usuario debe pulsar el botón interacción 1.
Se debe seleccionar una acción, para después pulsar el botón interacción 2, el cual hará que aumente o disminuya en un cuadro cada uno de los estados; lo anterior se describe mejor en la siguiente tabla



![image](https://github.com/unal-edigital1-lab/entrega-1-proyecto-grupo10-2024-1/assets/160156354/e66e6899-7950-4c67-8362-c5af024e3287)



Donde

- 1 : Aumenta un cuadro
- 0 : Disminuye un cuadro
- -: Se mantiene igual

Entonces, si se pulsa la acción juar, todos los estados aumentarán en un cuadro excepto el descanso al cual se le quitará un cuadro

SI NO SE REALIZA NINGUNA ACCIÓN EN 15 MINUTOS, CADA ESTADO DISMINUIRÁ UN CUADRO

Interacción con el sensor de luz: 

- 1: si el sensor detecta un 10% de luz en un espacio, se podrán hacer todas las acciones excepto dormir (la acción dormir estará deshabilitada en el test)
-  0: Si por el contrario este es menos de un 10%, solo se podrán ejecutar las acciones de dormir y alimentar

