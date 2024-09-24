# NOMBRES
+ Diego Ruiz
+ Roger Bejarano
+ Sebastian Conejo
+ Santiago Cubillos

# Entrega 1 del proyecto WP01
## 1.1 Diagrama de flujo
![Electrónica I Proyecto Primera entrega](https://github.com/user-attachments/assets/8f12221a-597c-4c37-bd57-5fdada03e0ea)

## 1.2 Unidad de control (States Machine)
![Electrónica I Proyecto Primera entrega (1)](https://github.com/user-attachments/assets/f6fd0498-f7bf-4c9e-af9b-42a9cb640f1c)

## 1.3 Caja Negra

![Electrónica I Proyecto Primera entrega (2)](https://github.com/user-attachments/assets/4a06cffc-c040-498e-be50-4de644e20b82)

![cajalcd](https://github.com/user-attachments/assets/84a14539-6fe7-48de-b892-a8a6cae484ab)

* En este diagrama, se utilizan parámetros como *ready_i* que servirá para modificar los estados que muestra la pantalla LCD
* El pin RW cuando está en 0 determina que la operación es de escritura.
* El pin RS selecciona registros, dependiendo del estado puede mover el cursor o limpiar la pantalla (si está en 0) o puede enviar datos para mostrar en la pantalla si está en 1.
* *Data* (D0 a D7) se utilizan para enviar información de comandos y caracteres al controlador de la pantalla. Todo esto mediante un microcontrolador.

![caja7seg](https://github.com/user-attachments/assets/926c33a8-3dae-47b4-b5c3-6ec32247f0bc)

* Mediante los botones *Btn A* y *Btn B*. Se modificará el tiempo que tiene el usuario para realizar una acción y evitar que los estados bajen una unidad. Lo que se muestra en el 7 segmentos es llamado *time*.

## 1.4  Especificación de los componentes:

### 1.4.1  Visualización

La visualización principal se llevará a cabo en un LCD gráfico 16x4 (posible modelo: WG12864A)
Aquí es donde mostraremos el tamagotchi, así como también las barras del estado.

![lcd g](https://github.com/user-attachments/assets/83a85125-9025-4149-8bd2-5601da65ddf5)

EL display de 7 segmentos se usará con el fin de brindar un apoyo visualizando puntajes y valores adicionales.


### 1.4.2  Botones

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


### 1.4.3  Sensor de luz

Se usará el sensor de luz IM120710017, el cual usa un fotoresistencia GL5528.

<img src="https://github.com/unal-edigital1-lab/entrega-1-proyecto-grupo10-2024-1/assets/159223904/154563b2-ced3-43cc-8fbd-30481ccec982.type" width="656" height="476">

Interacción con el sensor de luz: 

- 1: si el sensor detecta oscuridad durante 5 segundos el bicho se duerme automáticamente
-  0: si hay luz
# 2. Proceso 
# 3. Explicación de códigos
## 3.1 Módulo UltrasonicSensor
```verilog
module UltrasonicSensor(
    input clk,
    output reg trigger,
    input echo,
    output reg object_detected
);

    reg [31:0] counter = 0; // Cuenta ciclos de reloj mientras se recibe Echo
    reg [31:0] pulse_width = 0; // Duracion Echo
    reg echo_start = 0, echo_end = 0;
    reg [19:0] trig_counter = 0; // Cuenta ciclos mientras trigger está activo
    reg trig_state = 0; // Trigger on u off

    parameter integer clk_freq = 50000000;
    parameter integer pulse_duration = clk_freq / 100000;
    parameter integer max_distance_cm = 20;
    parameter integer time_threshold = (max_distance_cm * clk_freq * 2) / 34000;

    // Process for generating the trigger signal
    always @(posedge clk) begin
        if (trig_state == 0) begin
            trigger <= 0;
            trig_counter <= trig_counter + 1;
            if (trig_counter == pulse_duration) begin
                trigger <= 1;
                trig_state <= 1;
                trig_counter <= 0;
            end
        end else begin
            trigger <= 0;
            trig_state <= 0;
        end
    end

    // Process for measuring the echo pulse width
    always @(posedge clk) begin
        if (echo == 1 && echo_start == 0) begin
            echo_start <= 1;
            counter <= 0;
        end else if (echo == 0 && echo_start == 1) begin
            echo_end <= 1;
            pulse_width <= counter;
            echo_start <= 0;
        end else if (echo_start == 1) begin
            counter <= counter + 1;
        end
    end

    // Process to detect the object based on pulse width
    always @(pulse_width) begin
        if (pulse_width <= time_threshold)
            object_detected <= 1;
        else
            object_detected <= 0;
    end

endmodule
```
Este módulo consta de tres bloques principales:
- **Generación del trigger:** Este bloque genera un pulso para activar el sensor ultrasónico.
- **Medición del ancho del pulso:** Este bloque mide el tiempo que el pulso "echo" permanece alto, lo que corresponde a la distancia a la que está el objeto.
- **Detección del objeto:** Basado en el ancho del pulso, se decide si un objeto está dentro del rango detectable.
### 3.1.1 Explicación del bloque de generación de trigger
- **Señal de entrada:** clk (señal de reloj).
- **Registro de estado de trigger:** El registro trig_state controla cuándo se activa el pulso de trigger. Este cambia entre 0 y 1, activando el trigger por una duración específica.
- **Contador de ciclos:** trig_counter acumula ciclos del reloj hasta que alcanza la duración de pulso definida en pulse_duration. Una vez alcanzada, se genera el pulso de activación del sensor.
- **Salida:** trigger es la señal que activa el sensor ultrasónico.
### 3.1.2 Explicación del bloque de medición del ancho del pulso
- **Entrada:** echo es la señal que proviene del sensor ultrasónico y representa el tiempo que tarda en recibir el eco de vuelta.
- **Contador de tiempo:** counter empieza a contar cuando echo está en alto, y sigue contando mientras se mantiene alta. Este contador mide el tiempo que transcurre entre el envío y la recepción del pulso ultrasónico.
- **Registro del ancho del pulso:** pulse_width almacena el valor final del contador cuando el echo vuelve a cero, lo que representa la duración del eco.
### 3.1.3 Explicación del bloque de detección del objeto
- **Entrada:** pulse_width se compara con el umbral time_threshold. Este valor umbral está relacionado con la distancia máxima que puede detectar el sensor.
- **Salida:** object_detected se activa (es 1) si el ancho del pulso indica que un objeto está dentro de la distancia definida (pulse_width <= time_threshold).
### 3.1.4 Flujo de datos
- **Generación del Trigger:** El trigger se genera periódicamente y se envía al sensor ultrasónico.
- **Medición del eco:** El eco medido se convierte en el ancho de pulso, que se mide en ciclos del reloj.
- **Decisión de detección:** El ancho de pulso se compara con un valor de referencia para determinar si hay un objeto en el rango detectado.

## 3.2 Módulo del sensor de luz
```verilog
module sensor_luz (
    input LDR_signal,  // Entrada digital del LDR
    output reg sensor      // Salida para el LED
);

always @ (LDR_signal) begin
    if (LDR_signal) begin
        sensor <= 1'b1;  // Activa el LED en presencia de luz
    end else begin
        sensor <= 1'b0;  // Apaga el LED en ausencia de luz
    end
end

endmodule
```
### 3.2.1 Entradas y salidas
- **Entrada:** LDR_signal, que es la señal digital proveniente del LDR (convertida previamente de analógica a digital por un ADC externo o un comparador).
- **Salida:** sensor, que activa o desactiva el LED basado en la señal del LDR.
### 3.2.2 Explicación del módulo sensor_luz
Este módulo tiene un solo bloque combinacional. El flujo de datos sigue un simple camino en el que el valor de la entrada (señal del LDR) controla directamente la salida (control del LED).
**Bloques principales:**

**Comparación de la señal LDR:**
- **Entrada:** LDR_signal (0 o 1).
- La señal del LDR se evalúa de manera directa. Si la señal es alta (1), significa que hay suficiente luz, y si es baja (0), significa que no hay luz o está oscuro.

**Control de la salida:**
- Si LDR_signal == 1, el LED (sensor) se enciende (1'b1).
- Si LDR_signal == 0, el LED (sensor) se apaga (1'b0).
### 3.2.3 Explicación detallada
- **Entrada:** LDR_signal, que indica si el sensor detecta luz.
- **Decisión:** El bloque lógico compara el valor de LDR_signal:
- Si hay luz (LDR_signal == 1), el LED se enciende (sensor <= 1'b1).
- Si no hay luz (LDR_signal == 0), el LED se apaga (sensor <= 1'b0).
- **Salida:** El estado de sensor (encendido o apagado) se actualiza según el valor de la señal del LDR.

### 3.2.4 Flujo de datos:
- **Entrada del LDR:** Se recibe la señal digital del LDR.
- **Proceso combinacional:** Dependiendo de si la señal del LDR es 1 o 0, el LED se activa o desactiva.
- **Salida del LED:** El valor de sensor se ajusta para encender o apagar el LED.

## 3.3 Módulo del BCD2SSEG
### 3.3.1 Entradas y salidas
**Entrada:**

BCD es un valor de 4 bits que representa un número en formato BCD (0-9 o A-F en hexadecimal).

**Salidas:**

**SSeg:** Es un valor de 7 bits que representa qué segmentos del display de 7 segmentos se deben encender.

**an:** Es un valor de 2 bits que controla qué dígito del display múltiple (en este caso, se asume que el display tiene dos dígitos) está activo. En este caso, se configura en un valor fijo (2'b10).
### 3.3.2 Explicación del módulo BCDtoSSeg
Este es un módulo combinacional, ya que la salida SSeg se actualiza directamente en función del valor de entrada BCD. Aquí está el flujo de datos y su procesamiento en detalle:

**A.** Entrada del valor BCD

**Entrada:** BCD (4 bits).
- El valor en formato BCD representa un número decimal del 0 al 9, o un valor hexadecimal del A al F. Este valor se pasa al bloque combinacional para su conversión.

**B.** Conversión de BCD a 7 segmentos
- El bloque principal es un bloque always @ (*) que ejecuta una estructura case para comparar el valor de BCD.
- Dependiendo del valor de BCD, el caso correspondiente enciende los LEDs correctos en el display de 7 segmentos mediante la asignación a SSeg.
- Por ejemplo, si BCD es 4'b0000, esto representa el número "0", por lo que se asigna 7'b0000001 a SSeg, que enciende los LEDs adecuados para mostrar un "0" en el display.
- Si el valor es 4'b0001, representa el número "1", por lo que se asigna 7'b1001111 a SSeg.
- El código cubre los números del 0 al 9 y las letras del A al F en hexadecimal.

**C.** Activación del display
- La salida an es fija en 2'b10. Esto indica que se activa un dígito específico del display de 7 segmentos en un sistema que soporta múltiples dígitos.
- No hay control dinámico de an en este módulo, ya que está configurado de manera fija.
### 3.3.3 Flujo de datos
**Entrada BCD:**
- Se recibe un número en formato BCD de 4 bits.

**Procesamiento combinacional:**
- El bloque always con el case revisa el valor de BCD y selecciona la combinación de bits adecuada para representar el número o letra en el display.
- Las combinaciones de bits activan los LEDs del display de 7 segmentos.

**Salida del valor convertido:**
- La salida SSeg se actualiza con el valor correcto para encender los LEDs necesarios para representar el número o letra.
- La salida an mantiene activo el dígito del display donde se mostrará el valor.
### 3.3.4 Resumen
**Entrada:**
- BCD (4 bits).

**Decodificación:**
- Bloque combinacional case que convierte BCD en el código de 7 segmentos.

**Salida:**
- SSeg (7 bits) representa los LEDs que se encienden en el display.
- an (2 bits) indica qué dígito del display está activo.

**Ejemplo del funcionamiento:**
- Si el valor de entrada BCD = 4'b0011 (que representa el número 3):
- El bloque case selecciona la salida correspondiente SSeg = 7'b0000110 (que enciende los LEDs necesarios para mostrar un "3" en el display).
- La salida an se fija en 2'b10, activando el segundo dígito del display.
## 3.4 Módulo Temporizador de 7 segmentos
### 3.4.1. Componentes del Módulo
- Este módulo es un temporizador de 7 segmentos que ajusta su velocidad en función de un botón (fast_button) y tiene varias funciones:
- Control del temporizador con un botón para cambiar la frecuencia.
- Cuenta regresiva de un valor BCD (de 9 a 0).
- Bandera de estado (bandera) que indica cuando el temporizador llega a 0.
### 3.4.2 Entradas y Salidas
**Entradas:**
- **clk:** Señal de reloj.
- **reset:** Para reiniciar el temporizador.
- **fast_button:** Botón que ajusta la velocidad del temporizador.
**Salidas:**
  
- **an:** Selección del display de 7 segmentos.
- **sseg:** Representación del número en el display de 7 segmentos.
- **bandera:** Señal que se activa cuando el temporizador llega a 0.
### 3.4.3 Explicación detallada
- La Explicación se puede dividir en varios bloques importantes:
**A.** Bloque de control de frecuencia del temporizador
  
**Entradas:**

- **clk:** Reloj principal.
- **fast_button:** Determina si se usa la frecuencia rápida o normal.
- 
**Variables clave:**
- **counter_seg:** Lleva el conteo de los ciclos de reloj.
- **count_limit:** Depende del estado de fast_button y define la frecuencia (normal o rápida).

**Salida:**
- freq: Señal de frecuencia que controla el temporizador.

**Funcionamiento:**
- El temporizador cuenta hasta el valor de count_limit (diferente según el estado de fast_button).
- Cuando counter_seg supera count_limit, la señal freq cambia de estado.
- Si se presiona el fast_button, se cambia dinámicamente el valor de count_limit, acelerando el temporizador.

**B. Bloque del segundero**

**Entradas:**
- **freq:** Señal generada por el bloque de control de frecuencia.
- **reset:** Para reiniciar el temporizador.

**Variables clave:**
- **segundero:** Contador que aumenta hasta 60 (representa un minuto).
- **BCD:** Contador BCD que lleva la cuenta regresiva de 9 a 0.

**Salida:**
- segundero: Controla los segundos.
- bandera: Se activa cuando el temporizador llega a 0.

**Funcionamiento:**
- El segundero aumenta en cada ciclo de freq y se resetea cuando llega a 60.
- El valor de BCD disminuye cuando el segundero llega a 60.
- Si el valor de BCD llega a 0 y el segundero llega a 59, la bandera se activa (temporizador completo).

**C.** Bloque de visualización BCD a 7 segmentos
- Este bloque convierte el valor en BCD a la representación correspondiente en el display de 7 segmentos.
- **Entrada:** BCD (el valor actual del temporizador en formato BCD).
- **Salida:** sseg (los 7 segmentos que forman el número en el display) y an (la selección del dígito a mostrar).
### 3.4.4 Flujo de Datos Completo
**Control de la Frecuencia:**
- El temporizador cuenta los ciclos del reloj según la frecuencia configurada.
- Dependiendo del botón fast_button, se ajusta la velocidad a normal o rápida.
- La señal freq controla cuándo el contador del segundero se incrementa.

**Cuenta regresiva del segundero:**
- El contador segundero aumenta cada vez que freq cambia de estado, hasta llegar a 60.
- Cada vez que segundero llega a 60, el valor en BCD se decrementa.

**Bandera de fin del temporizador:**
- Si el valor del segundero llega a 59 y BCD es 0, se activa la bandera bandera para indicar que el temporizador ha terminado.

**Visualización en el display:**
- El valor en BCD se convierte y muestra en el display de 7 segmentos mediante el bloque BCDtoSSeg.
### 3.4.5 Resumen
- **Entradas:** clk, reset, fast_button.

**Procesamiento:**
- Control de frecuencia (fast_button ajusta count_limit).
- Segundero que cuenta de 0 a 60.
- BCD que cuenta de 9 a 0.
- **Salidas:** sseg y an para mostrar los números en el display, y bandera que indica el fin del temporizador.
## 3.5 Módulo visualización personalizada
### 3.5.1 Entradas y Salidas
**Entradas:**
* **clk:** Señal de reloj para la sincronización.
* **rst:** Señal de reinicio para restaurar el estado inicial del sistema.
* estado: Indica cuál es el estado del Tamagotchi (se utiliza para leer diferentes archivos de memoria).
* saciedad, diversion, descanso, salud, felicidad: Variables de estado que se muestran en la pantalla como barras de progreso.
* luz, cercania, fast: Variables que activan iconos o barras de estado en la pantalla.

**Salidas:**
- **rs:** Controla si los datos enviados a la pantalla son comandos o datos.
- **rw:** Señal de lectura/escritura para la pantalla.
- **enable:** Señal que habilita la escritura en la pantalla.
- **data:** Datos enviados a la pantalla LCD (caracteres o comandos de configuración).
## 3.5.2 Descripción general del módulo
Este módulo se divide en varios bloques funcionales:
- **Control del estado:** Una máquina de estados finita (FSM) que decide qué comando o dato se debe enviar a la pantalla LCD en cada momento.
- **Generación de caracteres personalizados:** Se definen caracteres específicos que se almacenan en la CGRAM de la pantalla LCD.
- **Escritura de datos en la pantalla:** Actualización de los datos visibles en la pantalla, incluyendo barras de estado y caracteres.
- **Divisor de frecuencia:** Ajusta la velocidad de operación de la pantalla LCD para cumplir con las restricciones de tiempo.
## 3.5.3 Bloque de control del estado (FSM)
Este bloque es una máquina de estados finita que se encarga de secuenciar las distintas fases del proceso de visualización en la pantalla LCD.

**Entradas:**
- **clk:** Señal de reloj.
- **rst:** Señal de reinicio.
- Señales internas como done_lcd_write y done_cgram_write que indican cuándo se ha completado una tarea.

**Estados:**
- **IDLE:** Estado de espera hasta que el sistema esté listo para comenzar la configuración o actualización de la pantalla.
- **INIT_CONFIG:** En este estado, se envían los comandos de inicialización de la pantalla LCD (como activar el modo de 8 bits y desactivar el cursor).
- **CREATE_CHARS:** Se escribe la información de los caracteres personalizados en la CGRAM.
- **SET_CURSOR_AND_WRITE:** Configura el cursor en la posición correcta y escribe los caracteres en la pantalla.

**Salidas:**
- Control de las señales rs, rw, data, y actualización de los contadores internos como command_counter y data_counter.
## 3.5.4 Generación de caracteres personalizados
- Este bloque se encarga de escribir caracteres personalizados en la CGRAM de la pantalla LCD. Cada carácter tiene 8 bytes que definen su forma.

**Entradas:**
- **estado:** Utilizado para determinar qué archivo de memoria cargar (por ejemplo, "Cara sonriendo.txt").
- Contadores internos como char_counter y cgram_addrs_counter que controlan cuántos caracteres se han escrito y en qué posición de la CGRAM.

**Salidas:**
- **data:** En este caso, los datos que se escriben en la pantalla son los bytes que forman los caracteres personalizados.
- **rs y rw:** Se controlan para asegurarse de que los datos se escriben en la CGRAM y no en la DDRAM (que es donde se almacenan los datos visibles en la pantalla).
## 3.5.5 Escritura de datos en la pantalla
Este bloque se encarga de mostrar los datos visuales en la pantalla. Se muestran los caracteres personalizados, las barras de estado (saciedad, diversión, etc.), y los indicadores (luz, cercanía, etc.).

**Entradas:**
- Variables como saciedad, diversion, descanso, salud, felicidad, que controlan el llenado de las barras de estado.
- Variables como luz, cercania, y fast, que controlan la visualización de iconos específicos.

**Salidas:**
- **data:** El valor que se envía a la pantalla para representar el contenido actual (ya sea un carácter o una barra de estado).
- **done_lcd_write:** Señal que indica cuándo se ha completado la escritura en la pantalla.
## 3.5.6 Divisor de frecuencia
Este bloque reduce la frecuencia de la señal de reloj (clk) para que la pantalla LCD pueda operar a la velocidad requerida.

**Entrada:** clk.

**Salida:** clk_16ms, que se utiliza como reloj para el resto de los bloques del sistema.
## 3.5.7 Flujo de datos completo
**Configuración inicial:**
- El sistema comienza en el estado IDLE. Una vez que el sistema está listo (ready_i), pasa al estado INIT_CONFIG.
- En INIT_CONFIG, se envían los comandos de configuración inicial de la pantalla.

**Generación de caracteres:**
- En el estado CREATE_CHARS, el sistema escribe los caracteres personalizados en la CGRAM de la pantalla LCD.
- Los caracteres son seleccionados en función del estado del Tamagotchi (por ejemplo, si está durmiendo, sonriendo, etc.).

**Escritura de datos en la pantalla:**
- En el estado SET_CURSOR_AND_WRITE, el sistema posiciona el cursor en la pantalla y comienza a escribir los caracteres y las barras de estado.
- Dependiendo de las variables de estado (saciedad, diversion, etc.), las barras de progreso se llenan o se vacían.

**Actualización continua:**
Una vez que se ha completado la escritura, el sistema vuelve al estado IDLE y espera la siguiente actualización.
## 3.6 Módulo control máquina de estados
### 3.6.1 Entradas y Salidas
**Entradas:**
- **clk:** Señal de reloj para sincronizar la FSM.
- **rst:** Señal de reinicio para volver al estado inicial.
- **boton_jugar, boton_alimentar, boton_dormir, boton_curar, boton_caricia:** Botones que permiten realizar acciones en el sistema.
- **fast_button:** Botón que activa un temporizador rápido.
**Salidas:**
- **saciedad, diversion, descanso, salud, felicidad:** Variables de estado que representan los niveles actuales de saciedad, diversión, descanso, salud y felicidad.
- **state:** Estado actual de la FSM.
- **an, sseg:** Salidas para el control del display de 7 segmentos.
### 3.6.2 Explicación general del módulo
La Explicación se organiza en tres bloques principales:
- **Bloque de control de estado (FSM):** Controla en qué estado está el sistema y define cómo cambiar de un estado a otro.
- **Temporizador:** Genera señales de tiempo (bandera) que controlan la duración en cada estado.
- **Ajuste de las variables de estado:** Actualiza los valores de saciedad, diversion, descanso, salud, y felicidad en función de las acciones tomadas en cada estado.
### 3.6.3 Bloque de control de estado (FSM)
Este es el bloque central de la máquina de estados. Según las entradas (botones) y el estado actual, la FSM cambia de un estado a otro y ajusta los niveles de saciedad, diversión, etc.

**Estados:**
- **ESTADO_IDEAL:** Es el estado inicial, donde todos los valores están al máximo.
- **ESTADO_NEUTRO:** En este estado, los valores de saciedad, diversión, etc., comienzan a disminuir lentamente.
- **ESTADO_DIVERSION:** Si se presiona boton_jugar, el sistema entra en este estado, donde aumentan la diversión y la felicidad, pero disminuye el descanso.
- **ESTADO_ALIMENTAR, ESTADO_DESCANSO, ESTADO_SALUD, ESTADO_FELIZ:** Estados correspondientes a otras acciones como alimentar, descansar, curar y dar caricias, donde las variables relevantes aumentan.
ESTADO_MUERTO: Si saciedad o salud llega a 0, el sistema entra en este estado, donde todas las variables se ponen a 0 y el Tamagotchi "muere".
### 3.6.4 Bloque del temporizador
El módulo Temporizador7seg genera una señal (bandera) que actúa como temporizador. Esta señal se utiliza para controlar la duración de cada estado y desencadenar las transiciones de un estado a otro. Cuando la señal bandera está activa, el sistema puede realizar acciones como disminuir o aumentar los valores de saciedad, diversión, etc.

**Entradas:**
- clk, rst, fast_button: Señales que controlan el temporizador.
**Salidas:**
- **bandera:** Señal que indica cuándo el temporizador ha terminado, lo que permite las transiciones entre estados en la FSM.
### 3.6.5 Ajuste de las variables de estado
Este bloque se encarga de ajustar los valores de saciedad, diversion, descanso, salud, y felicidad en función de las acciones del usuario y las transiciones entre estados. Por ejemplo, en el estado ESTADO_DIVERSION, los valores de diversión y felicidad aumentan, mientras que el valor de descanso disminuye.

**Entradas:**
- bandera: Señal del temporizador que indica cuándo ajustar las variables.
- Los botones (boton_jugar, boton_alimentar, etc.) que determinan qué acción se toma.

**Salidas:**
Las variables de estado (saciedad, diversion, etc.) que se ajustan según el estado actual.
### 3.6.6 Flujo de datos completo
Estado inicial (ESTADO_IDEAL):
- El sistema comienza en el estado ESTADO_IDEAL, donde todas las variables (saciedad, diversion, etc.) están al máximo. El sistema permanece en este estado durante un tiempo controlado por el temporizador (timer).

**Estado neutro (ESTADO_NEUTRO):**
- Una vez que el temporizador alcanza un valor determinado, el sistema transiciona al estado ESTADO_NEUTRO, donde las variables de estado comienzan a disminuir.
- En este estado, el sistema también evalúa si alguno de los botones está presionado. Si se presiona un botón, el sistema cambia al estado correspondiente (ESTADO_DIVERSION, ESTADO_ALIMENTAR, etc.).

**Estados de acción (jugar, alimentar, etc.):**
- Si se presiona un botón, el sistema entra en el estado correspondiente (por ejemplo, ESTADO_DIVERSION si se presiona boton_jugar).
- En estos estados, las variables correspondientes aumentan (por ejemplo, diversion y felicidad en ESTADO_DIVERSION), mientras que otras variables pueden disminuir (por ejemplo, descanso).
- El sistema permanece en este estado hasta que el temporizador o la señal bandera indican que es hora de volver al estado ESTADO_NEUTRO.

**Estado muerto (ESTADO_MUERTO):**
Si las variables saciedad o salud llegan a 0 en el estado ESTADO_NEUTRO, el sistema transiciona al estado ESTADO_MUERTO, donde todas las variables se ponen a 0 y el Tamagotchi muere.
### 3.6.7 Resumen
**Entradas:**
- clk, rst, botones de acción (boton_jugar, boton_alimentar, etc.), señal del temporizador (bandera).
- **FSM (Máquina de estados):** Controla en qué estado está el sistema (ideal, neutro, jugar, alimentar, etc.) y cuándo realizar las transiciones entre estados.
- **Temporizador:** Genera la señal de temporización (bandera) que controla cuánto tiempo permanece el sistema en cada estado.
- **Ajuste de las variables:** En cada estado, las variables de saciedad, diversion, descanso, salud, y felicidad se ajustan según la acción tomada.
## 3.7 Módulo de Tamagotchi
### 3.7.1 Entradas y Salidas
**Entradas:**
- **boton_jugar, boton_alimentar, boton_curar, boton_acelerar:** Botones que permiten al usuario interactuar con el Tamagotchi (jugar, alimentar, curar, acelerar el tiempo).
- **sensor_luz:** Señal del sensor de luz que detecta si hay suficiente luz.
- **echo:** Señal del sensor ultrasónico que detecta objetos cercanos.
- **rst_neg:** Señal de reset.
- **clk:** Señal de reloj.

**Salidas:**
- **trigger:** Señal de activación para el sensor ultrasónico.
- **segment:** Señales para el display de 7 segmentos.
- **anodos:** Control de los anodos del display.
- **rs, rw, enable, data:** Señales de control para la pantalla LCD.
- **prb:** Señal que replica el botón de aceleración (boton_acelerar).
### 3.7.2 Explicación general
El módulo TamaguchiUpdateNewPro conecta varios submódulos que, en conjunto, permiten interactuar con el Tamagotchi, mostrar información en un display de 7 segmentos y una pantalla LCD, y detectar el entorno mediante sensores.

**A.** Asignaciones iniciales
- **rst:** El reset es negado para asegurar que se use correctamente en los submódulos.
- **prb:** Se conecta directamente al botón de aceleración (boton_acelerar).

**B.** Submódulos
- **sensor_luz:** Este submódulo detecta la presencia de luz y activa la señal bandera_iluminacion cuando se detecta luz a través del LDR.

**Entradas:**
- LDR_signal (señal del sensor de luz).

**Salida:**
- sensor (bandera_iluminacion), que indica si hay luz o no.
**control_fsm:** Este es el núcleo de control del Tamagotchi. Es una máquina de estados que ajusta las variables de saciedad, diversion, descanso, salud, y felicidad según los botones presionados y los sensores.
  
**Entradas:**
- Señales de control como boton_jugar, boton_alimentar, boton_curar, y otras (incluyendo bandera_iluminacion y object_detected).
- clk y rst para la sincronización.

**Salidas:**
Las variables de estado (saciedad, diversion, descanso, salud, felicidad), la señal del estado actual (state), y señales para el display de 7 segmentos (segment, anodos).

**UltrasonicSensor:** Este submódulo detecta objetos cercanos usando un sensor ultrasónico. Genera una señal de trigger para activar el sensor y recibe la señal echo que indica si un objeto está cerca.

**Entradas:**
- **clk:** Para sincronización.
- **echo:** Señal del sensor ultrasónico.

**Salidas:**
- **trigger:** Señal que activa el sensor ultrasónico.
- **object_detected:** Señal que indica si un objeto está cerca (utilizada para detectar cercanía en el Tamagotchi).

**visualizacion_personalizada:**

Este submódulo controla la pantalla LCD, mostrando los estados del Tamagotchi (saciedad, diversión, etc.) y otros indicadores, como si hay luz o un objeto cerca.

**Entradas:**
- Variables de estado (saciedad, diversion, descanso, salud, felicidad), la señal del estado de la FSM (state), y las señales de luz y cercanía.
- clk, rst, y fast para sincronización y control.

**Salidas:**

Señales de control para la pantalla LCD (rs, rw, enable, data).
### 3.7.3 Flujo de datos
**Interacción del usuario:**
- El usuario puede presionar los botones (boton_jugar, boton_alimentar, etc.) que sirven como entradas para el control FSM (control_fsm).
- El botón boton_acelerar se utiliza para aumentar la velocidad del temporizador, y su señal se conecta a varios módulos.

**Detección de luz y objetos:**
- El submódulo sensor_luz detecta si hay suficiente luz, activando bandera_iluminacion, que se usa en la FSM para determinar si el Tamagotchi está en un ambiente iluminado.
- El submódulo UltrasonicSensor detecta objetos cercanos y activa object_detected cuando se detecta un objeto.

**Control de la FSM:**
- El submódulo control_fsm gestiona el estado del Tamagotchi, ajustando las variables de estado (saciedad, diversion, etc.) en función de las entradas de los botones y las señales de los sensores.
- El estado de la FSM se envía a la pantalla LCD para mostrar la información correspondiente.

**Visualización en la pantalla LCD:**
- El submódulo visualizacion_personalizada toma las variables de estado y otras señales (como luz y cercania) para mostrar información relevante en la pantalla LCD.
- También controla el cursor y los datos enviados a la pantalla.

**Visualización en el display de 7 segmentos:**

Las señales segment y anodos, generadas por la FSM, controlan un display de 7 segmentos que puede mostrar información adicional (por ejemplo, tiempo o estado).
### 3.7.4 Resumen
**Entradas:**

Botones del usuario y señales de sensores (boton_jugar, sensor_luz, echo, etc.).

**Procesamiento:**
- **FSM (control_fsm):** Toma decisiones basadas en los botones y las señales de los sensores.
- **Detección de luz (sensor_luz):** Detecta si hay luz.
- **Detección de objetos (UltrasonicSensor):** Detecta objetos cercanos.
- **Visualización (visualizacion_personalizada):** Muestra el estado en la pantalla LCD.

**Salidas:**
- **Pantalla LCD:** Controlada por visualizacion_personalizada.
- **Display de 7 segmentos:** Controlado por control_fsm.
- Señal de trigger para el sensor ultrasónico.
