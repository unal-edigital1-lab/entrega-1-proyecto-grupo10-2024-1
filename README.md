# NOMBRES
+ Diego Ruiz
+ Roger Bejarano
+ Sebastian Conejo
+ Santiago Cubillos

# Entrega 1 del proyecto WP01
## 1.1 Unidad de control (States Machine)
![MaquinaDeEstados](https://github.com/user-attachments/assets/c881c3f3-824a-4327-93e9-d452828adb93)

## 1.2 Caja Negra
![Diagrama en blanco (1)](https://github.com/user-attachments/assets/b260674d-5ec3-4574-828c-c3e9bd07f5d3)


## 1.3  Especificación de los componentes:

### 1.3.1  Visualización

La visualización principal se llevará a cabo en un LCD gráfico 20x4 (lcd 20x4 hd44780)
Aquí es donde mostraremos el tamagotchi, así como también las barras del estado.

![image](https://github.com/user-attachments/assets/19a924f3-c576-437c-8ec3-194a80025101)

EL display de 7 segmentos se usará con el fin de mostrar el contador de minutos restantes antes de que cada uno de los atributos baje un cuadro.

### 1.3.2  Botones

1. Rst
2. Test
3. Fast Button
4. Botón 1 (jugar)
5. Botón 2 (alimentar)
6. Botón 3 (curar)

El sistema de puntos se hará por medio de una barra seccionada en 16  partes iguales (cada 4 partes es un cuadro) para cada uno de los 4 atributos. DIVERSION se calcula a partir de los otros atributos, por lo tanto este atributo no tiene un botón físico:

1. Saciedad
2. Diversión
3. Descanso
4. Salud
5. Felicidad

Las siguientes serán las acciones que podrá hacer el usuario:

1. Jugar
2. Alimentar
3. Dormir
4. Curar
5. Caricia

Para realizar cada una de estas acciones, el usuario podrá pulsar alguno de los tres botones, o accionar alguno de los dos sensores incorporados al Tamagotchi.

Entonces, si por ejemplo se pulsa la acción jugar, DIVERSIÓN Y FELICIDAD aumentarán en un cuadro excepto el DESCANSO, al cual se le quitará un cuadro.

SI NO SE REALIZA NINGUNA ACCIÓN EN 10 MINUTOS, CADA ESTADO DISMINUIRÁ UN CUADRO.

### 1.3.3  Sensor de luz

Se usará el sensor de luz IM120710017, el cual usa un fotoresistencia GL5528.

<img src="https://github.com/unal-edigital1-lab/entrega-1-proyecto-grupo10-2024-1/assets/159223904/154563b2-ced3-43cc-8fbd-30481ccec982.type" width="656" height="476">

**Interacción con el sensor de luz:**

- 1: si el sensor detecta luz entonces el tamagotchi puede perder un cuadro en DESCANSO si no recibe un cambio en 10 minutos.
- 0: si no hay luz, indica que la mascota virtual se encuentra durmiendo, suben el atributo de DESCANSO.
### 1.3.4  Sensor de ultra sonido

Se usará el sensor de ultra sonido HC-SR04.
![image](https://github.com/user-attachments/assets/c8594a4d-dedd-441f-8b37-0b636ed588c9)

**Interacción con el sensor de ultra sonido:**

- **Si hay un objeto a más de 20 centímetros:** el sensor no detecta ningún objeto, a la FPGA debería llegar un 0. No sube ningún atributo.
- **Si hay un objeto a menos de 20 centímetros:** el sensor detecta un objeto, a la FPGA debería llegar un 1. Sube algún atributo, en este caso FELICIDAD.
# 2. Proceso 
Durante la elaboracion de nuestro proyecto decidimos trabajar por etapas, es decir, centrandonos principalmente en:
- **Maquina de Estados Principal.**
- **Visualizacion**
- **Temporizador y Fast Button**
- **Implementacion de sensores**
  
Lo que haremos en esta seccion es pofundizar un poco en lo que fue el proceso de diseño abordado desde un aspecto general donde estaremos mostrando cuales fueron los principales retos para nosotros adjuntando evidencias fotograficas y de simulacion para soportar nuestro trabajo.
## 2.1 Maquina de Estados Principal
Para el diseño de la maquina de estados principal hicimos un primer diseño totalmente distinto a la FSM que presentamos en la primera entrega en cuanto a como seria la transicion de estados, esto debido a que aun no conociamos muy bien de que forma podiamos diseñar el codigo en verilog. A raiz de esto, al momento de hacer pruebas para ver si con cada cambio de estado podriamos al menos cambiar una cara nos encontramos con que el codigo corria bien pero no lograbamos cambiar de estado. A continuacion un pedazo del codigo de nuestro primer diseño de la FSM principal:
```verilog
always @(*) begin
    // Estado por defecto
    next_state = state;

    case (state)
        ESTADO_SACIEDAD: begin
            if (boton_alimentar) begin
                saciedad <= (saciedad < 15) ? saciedad + 1 : 15; // Aumenta la saciedad al alimentar
                sal <= (sal < 15) ? sal + 1 : 15;                 // Mejora la salud
                feli <= (feli < 15) ? feli + 1 : 15;              // Aumenta la felicidad
                next_state = ESTADO_FELICIDAD;                    // Pasa a estado de felicidad
```
Con ayuda de la profesora de laboratorio nos dimos cuenta de que no estabamos haciendo bien la transición entre estados, el error lo teniamos en ese **nex_state**. A partir de este error y como teniamos casi todo el codigo estructurado de esta forma decidimos entonces volver a hacer la maquina de estados desde 0, mas parecida a nuestra idea original, y con una transicion entre estados mas simple.

A continuacion mostraremos parte del codigo donde ya teniamos una estructura de cambio de estados mas definida:
```verilog
 case (state)
            ESTADO_IDEAL: begin
                // En el estado ideal, todos los valores están al máximo
                sac <= 4'd15;
                div <= 4'd15;
                des <= 4'd15;
                sal <= 4'd15;
                feli <= 4'd15;

                // Temporizador para pasar al estado neutro
                if (timer == 16'd10) begin  // Temporizador ajustado para simulación rápida
                    state <= ESTADO_NEUTRO;
                    timer <= 16'd0;
                end else begin
                    timer <= timer + 1;
                end
            end

            ESTADO_NEUTRO: begin
                // En el estado neutro, los valores empiezan a bajar lentamente
                if (timer==160000) begin  // Temporizador ajustado para simulación rápida
                    sac <= (sac > 0) ? sac - 1 : 0;
                    div <= (div > 0) ? div - 1 : 0;
                    des <= (des > 0) ? des - 1 : 0;
                    sal <= (sal > 0) ? sal - 1 : 0;
                    feli <= (feli > 0) ? feli - 1 : 0;
                    timer <= 16'd0;
                end else begin
                    timer <= timer + 1;
                end

                // Si se presiona el botón de jugar, cambiar al estado de diversión
                if (boton_jugar) begin
                    state <= ESTADO_DIVERSION;
                end else if (boton_alimentar)begin
                    state <= ESTADO_ALIMENTAR;
```
En este codigo ya contabamos conun estado ideal, que seria el estado inicial donde el tamagotchi volveria luego de oprimir el boton de rest. En esta nueva version de nuestra FMS ya contabamos con una transicion entre estados mas sencilla donde podriamos hacer que los valores de las necesidades bajaran automaticamente programando un temporizador. A continuacion mostramos parte del test bench para verificar el correcto funcionamiento de este codigo:

![WhatsApp Image 2024-09-24 à 23 06 02_03b87805](https://github.com/user-attachments/assets/af0b6345-1f09-44a2-88e3-a12432fb5079)


Luego de ver que este codigo si nos funcionaba decidimos agregar un par de condiciones para cambiar entre estado, esto con el objetivo de asegurarnos de que los valores solo puedan bajar en estado neutro, para entonces obtener el codigo que es presentado en la seccion 3.
## 2.2 Visualización
Consideramos que esta fue la parte mas dificil del proceso debido a que teniamos que tener en cuenta la pantalla que ibamos a utilizar y como era el protocolo de comunicacion de esta. Afortunadamente con ayuda de la profesora diana logramos sacar adelante aspectos claves de esta visualizacion.

Tenemos que enteder que esta pantalla utiliza un controlador **HD44780**  donde se comunica utilizando un protocolo paralelo. Es por esto que era fundamental aprender a utilizar los comandos de rs donde indicabamos a la pantalla si estabamos mandandole un comando o escribiendo en ella.

El primer problema que nos surgio fue cuando nos dimos cuenta de que esta pantalla solo podia elaborar 8 caracteres especiales, lo cual nos limitaba la idea de poder diseñar una mascota a nuestro gusto. Nos dimos cuenta rapidamente de este error asi que comprendiendo que cada uno de estos caracteres tiene una direccion CGRAM donde podemos almacenar los caracteres especiales, si queremos utilizar mas de 8 caracteres especiales tendremos que Re-utilizar una de estas direcciones. Como pimera solucion intentamos entonces escoger la primer direccion para asi sobreescribirla pero se nos presentaba el siguiente problema: (acceder al link para ver el video):
https://github.com/user-attachments/assets/5444b2f4-195a-4e24-b215-76a8ce6302be

Aca como podemos observar, este ultimo caracter especial se quedaba ciclando entre el primer caracter y el ultimo. Segun lo que investigamos este error no podria ser solucionado, si sobreescribiamos mas caracteres estos siempre se iban a quedar en un ciclo donde se mostraba el primer caracter y el ultimo. Entendimos que este problema se podria solucionar seleccionando 2 caracteres que sean iguales, de esta forma si comenzaban a alternan entre ellos no se notaria y asi fue como lo implementamos finalmente. A continuacion la parte del codigo de visualizacion final donde asignamos cada una de la direccion CGRAM a un lugar en la pantalla, donde la direccion del noveno caracter se comparte con la del 6 caracter.
``` verilog
case(cgram_addrs_counter) //esta zona pinta la pantalla segun se quiera
									//pinta los dos dibujos, izqierda y derecha
									8'h80:data <= 8'h00;
									8'h91:data <= 8'h00;
									8'h81:data <= 8'h01;
									8'h92:data <= 8'h01;
									8'h82:data <= 8'h02;
									8'h93:data <= 8'h02;
									8'hC0:data <= 8'h03;
									8'hD1:data <= 8'h03;
									8'hC1:data <= 8'h04;
									8'hD2:data <= 8'h04;
									8'hC2:data <= 8'h05;
									8'hD3:data <= 8'h05;
									8'h94:data <= 8'h06;
									8'hA5:data <= 8'h06;
									8'h95:data <= 8'h07;
									8'hA6:data <= 8'h07;
									8'h96:data <= 8'h06;
									8'hA7:data <= 8'h06;
```

Tambien entendimos que la pantalla puede llenarse con los 8 caracteres personalizados y tambien los espacios que sobraban se podian llenar con caracteres pre definidos que tiene la pantalla y de esta forma podemos representar las barras de los niveles y algunos indicadores de los sensores como podemos observar acontinuacion:
```verilog
									//pinta el indicador de luz
									8'h8E:data <= (luz)?8'h2A:8'hA0;
									8'h8F:data <= (luz)?8'h2A:8'hA0;
									
									//indicador de cercania
									8'hA2:data <= (cercania)?8'hFC:8'hA0;
									8'hA3:data <= (cercania)?8'hFC:8'hA0;
									//indicador de tiempo acelerado
									8'hCE:data <= (fast)?8'h3E:8'hA0;
									8'hCF:data <= (fast)?8'h3E:8'hA0;
									//barra de saciedad
									8'h84:data <= (saciedad > 12)?8'hFF:8'hA0;
									8'hC4:data <= (saciedad > 8)?8'hFF:8'hA0;
									8'h98:data <= (saciedad > 4)?8'hFF:8'hA0;
									8'hD8:data <= (saciedad > 0)?8'hFF:8'hA0;
									
```
Por ultimo, debido a que la forma de hacer las caras para la visualizacion era diseñando matrices de 0 y 1 que la pantalla identificaba como on y off, asi que diseñamos una forma rapida de hacer estos diseños en excel:

![image](https://github.com/user-attachments/assets/5d695481-1d86-4f44-8550-d26aa4a96ecd)

Este programa en Excel nos permite previsualizar las caras. Por otro lado, convierte cada celda en instrucciones binarias, en 8 grupos que son los permitidos por la LCD. Estas instrucciones se convierten a un archivo .txt que se lee en el módulo de visualización personalizada.

Para acceder a este excel, dejaremos el link a continuación: [https://unaledu-my.sharepoint.com/:x:/g/personal/jconejo_unal_edu_co/ESAUbMh3lb1EuitcPmC59xwBviMvpCttHFcrLA8HWKZERQ?e=w4gii9](url)

## 2.3 Temporizador y fast button
El temporizador que diseñamos además de mostrar el un valor de 0 a 9 en el 7 segmentos que representa un ciclo de 10 minutos antes de que la barra de niveles baja, también tiene la función de enviar una bandera que indicaría que estos hipotéticos 10 minutos ya pasaron y es momento de bajar los niveles o de volver a estado  neutro en caso de encontrarse en otro estado. Además de esto, diseñamos un botón que aumentaría *10 la velocidad del paso del tiempo para comodidad del usuario

Para el diseño de este botón de aceleración simplemente dentro del código del temporizador modificamos el tiempo limite con el que nuestra frecuencia iba a estar enviando un pulso para que así el modulo segundero pudiera ejecutarse:  
```Verilog
  // Parámetro ajustable según el botón
    parameter count_limit_normal = 25000000; // Frecuencia para 1 Hz
    parameter count_limit_fast = 416666;    // Frecuencia más rápida
  // Temporizador que cambia su velocidad según el botón presionado
    always @(posedge clk) begin
        if (reset) begin
            counter_seg  <= 0;
            freq <= 'b0;
        end 
		  else begin
				if (counter_seg > count_limit) begin
					freq <= ~freq;
					counter_seg <= 'd0;
				end
				else begin
					counter_seg <= counter_seg + 1;
					count_limit <= (fast_button)?count_limit_fast:count_limit_normal;
				end
		  end
    end
```
Un problema que se nos presento al momento de diseñar la bandera fue que estábamos colocando la condición mal en el código. Nosotros pensamos que la señal se debía activar cada vez que este count_limit llegara a 0, pero al momento de realizar el test bench nos dimos cuenta que esto estaba mal, porque la bandera siempre estaría encendida y los valores bajarían con cada ciclo cumplido de count_limit, es por eso que con un cambio en el código decidimos poner la bandera en:
```verilog

    // Lógica para el segundero
    always @(posedge freq, posedge reset) begin
        if (reset) begin
            segundero <= 'd0;
            BCD <= 4'b1001;
            bandera <= 0;  // Reiniciamos la bandera
        end 
		  else begin
			if (segundero == 60) begin
					segundero <= 0;
					if(BCD == 0)begin
						BCD <= 9;
					end
					else begin
						BCD <= BCD - 1;
						
					end
         end else begin
            segundero <= segundero + 1;
				if(segundero == 59 & BCD == 0)begin
					bandera <= 1;
				end
				else begin
					bandera <= 0;
				end
         end
		end  
```

## 2.4 Sensores
### Errores cometidos en el proceso en el sensor de ultrasonido
- **Integración con el clock de la FPGA:** Se desconocía qué ciclos de reloj se debían usar para configurar el trigger del ultrasonido. Tras consultas en internet e información de la profesora de laboratorio, se decidió por usar el mismo de la FPGA (50MHz).
- **Uso de timethreshold:** Para poder determinar si el objeto se detecta, se optó por usar timethreshold. Aunque se obtenía el valor, no se sabía claramente cómo usarlo en el código para detectar un objeto a cierta distancia. Se resuelve el problema al ver cómo se configura esta variable en sistemas que involucraban Arduino.
### (cambiar a conveniencia) Errores cometidos en el proceso en el sensor de luz:
- **Definición de encendido/apagado:** Ya que al detectar sol, la fotorresistencia envía un 1 a la FPGA. En los códigos se instanciaba de manera errónea. Se resuelve el problema al ver de manera práctica que sin tapar la fotorristencia siempre llegaba un cero a la FPGA.
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
```verilog
module BCDtoSSeg (BCD, SSeg, an);

  input [3:0] BCD;
  output reg [6:0] SSeg;
  output [1:0] an;

assign an=2'b10;


always @ ( * ) begin
  case (BCD)
   4'b0000: SSeg = 7'b0000001; // "0"  
	4'b0001: SSeg = 7'b1001111; // "1" 
	4'b0010: SSeg = 7'b0010010; // "2" 
	4'b0011: SSeg = 7'b0000110; // "3" 
	4'b0100: SSeg = 7'b1001100; // "4" 
	4'b0101: SSeg = 7'b0100100; // "5" 
	4'b0110: SSeg = 7'b0100000; // "6" 
	4'b0111: SSeg = 7'b0001111; // "7" 
	4'b1000: SSeg = 7'b0000000; // "8"  
	4'b1001: SSeg = 7'b0000100; // "9" 
   4'ha: SSeg = 7'b0001000;  
   4'hb: SSeg = 7'b1100000;
   4'hc: SSeg = 7'b0110001;
   4'hd: SSeg = 7'b1000010;
   4'he: SSeg = 7'b0110000;
   4'hf: SSeg = 7'b0111000;
    default:
    SSeg = 0;
  endcase
end

endmodule
```
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
```verilog
module Temporizador7seg (
    input clk,
    input reset,
    input fast_button, // Botón para acelerar el temporizador
    output [1:0] an,
    output [6:0] sseg,
    output reg bandera
);

    reg [3:0] BCD;

    // Parámetro ajustable según el botón
    parameter count_limit_normal = 25000000; // Frecuencia para 1 Hz
    parameter count_limit_fast = 416666;    // Frecuencia más rápida (por ejemplo, 5 Hz)
    reg [31:0] count_limit;  // Contador dinámico para cambiar la velocidad
    reg [31:0] counter_seg;
    reg freq;
    reg [5:0] segundero;

    initial begin
        counter_seg = 'd0;
        freq = 'd0;
        segundero = 'd0;
        BCD = 'd9;
        bandera = 0;
    end

    // Temporizador que cambia su velocidad según el botón presionado
    always @(posedge clk) begin
        if (reset) begin
            counter_seg  <= 0;
            freq <= 'b0;
        end 
		  else begin
				if (counter_seg > count_limit) begin
					freq <= ~freq;
					counter_seg <= 'd0;
				end
				else begin
					counter_seg <= counter_seg + 1;
					count_limit <= (fast_button)?count_limit_fast:count_limit_normal;
				end
		  end
    end


    // Lógica para el segundero
    always @(posedge freq, posedge reset) begin
        if (reset) begin
            segundero <= 'd0;
            BCD <= 4'b1001;
            bandera <= 0;  // Reiniciamos la bandera
        end 
		  else begin
			if (segundero == 60) begin
					segundero <= 0;
					if(BCD == 0)begin
						BCD <= 9;
					end
					else begin
						BCD <= BCD - 1;
						
					end
         end else begin
            segundero <= segundero + 1;
				if(segundero == 59 & BCD == 0)begin
					bandera <= 1;
				end
				else begin
					bandera <= 0;
				end
         end
		end  
		 


        // Activamos la bandera cuando BCD llega a 0

    end

    // Instancia del módulo de conversión BCD a 7 segmentos
    BCDtoSSeg visualizador (.BCD(BCD), .SSeg(sseg), .an(an));

endmodule
```
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
```verilog
module visualizacion_personalizada#(parameter num_commands = 3, // Npumero de comandos de configuración a enviar a la LCD
                                      num_data_all = 64,  // cantidad líneas dentro de cada cuadro en la lcd
                                      char_data = 8, // Número de bytes que componen cada carácter personalizado (usualmente 8).
                                      num_cgram_addrs = 8,
                                      COUNT_MAX = 8000)(
    input clk,            
    input rst,          
    
	input [2:0]estado,
	input [3:0]saciedad,
	input [3:0]diversion,
    input [3:0]descanso,
    input [3:0]salud ,
    input [3:0]felicidad,
	 
	 input luz,
	 input cercania,
	 input fast,
	 
    output reg rs,        
    output reg rw,
    output enable,    
    output reg [7:0] data
);




// Definir los estados del controlador
localparam IDLE = 0;
localparam INIT_CONFIG = 1;
localparam CLEAR_COUNTERS0 = 2;
localparam CREATE_CHARS = 3;
localparam CLEAR_COUNTERS1 = 4;
localparam SET_CURSOR_AND_WRITE = 5;

localparam SET_CGRAM_ADDR = 0;
localparam WRITE_CHARS = 1;
localparam SET_CURSOR = 2;
localparam WRITE_LCD = 3;
localparam CHANGE_LINE = 4;

// Direcciones de escritura de la CGRAM 
localparam CGRAM_ADDR0 = 8'h40;
localparam CGRAM_ADDR1 = 8'h48;
localparam CGRAM_ADDR2 = 8'h50;
localparam CGRAM_ADDR3 = 8'h58;
localparam CGRAM_ADDR4 = 8'h60;
localparam CGRAM_ADDR5 = 8'h68;
localparam CGRAM_ADDR6 = 8'h70;
localparam CGRAM_ADDR7 = 8'h78;


reg [3:0] fsm_state;
reg [3:0] next;
reg clk_16ms;

// Definir un contador para el divisor de frecuencia
reg [$clog2(COUNT_MAX)-1:0] counter_div_freq;

// Comandos de configuración
localparam CLEAR_DISPLAY = 8'h01;
localparam SHIFT_CURSOR_RIGHT = 8'h06;
localparam DISPON_CURSOROFF = 8'h0C;
localparam DISPON_CURSORBLINK = 8'h0E;
localparam LINES2_MATRIX5x8_MODE8bit = 8'h38;
localparam LINES2_MATRIX5x8_MODE4bit = 8'h28;
localparam LINES1_MATRIX5x8_MODE8bit = 8'h30;
localparam LINES1_MATRIX5x8_MODE4bit = 8'h20;
localparam START_2LINE = 8'hC0;

// Definir un contador para controlar el envío de comandos
reg [$clog2(num_commands):0] command_counter;
// Definir un contador para controlar el envío de cada dato
reg [$clog2(num_data_all):0] data_counter;
// Definir un contador para controlar el envío de caracteres a la CGRAM
reg [$clog2(char_data):0] char_counter;
// Definir un contador para controlar el envío de comandos
reg [15:0] cgram_addrs_counter;

// Banco de registros
reg [7:0] data_memory [0: num_data_all-1];
reg [7:0] config_memory [0:num_commands-1]; 
reg [7:0] cgram_addrs [0: num_cgram_addrs-1];

reg [1:0] create_char_task;
reg init_config_executed;
wire done_cgram_write;
reg done_lcd_write;
reg ready_i;

initial begin
    fsm_state <= IDLE;
    data <= 'b0;
    command_counter <= 'b0;
    data_counter <= 'b0;
    rw <= 0;
	 rs <= 0;
    clk_16ms <= 'b0;
    counter_div_freq <= 'b0;
    init_config_executed <= 'b0;
    cgram_addrs_counter <= 'b0; 
    char_counter <= 'b0;
    done_lcd_write <= 1'b0; 

    create_char_task <= SET_CGRAM_ADDR;

	//$readmemb("C:/Users/diego/Documents/UNAL/Sexto Semestre/tamagotchichimba/CaraTriste.txt", data_memory);
	config_memory[0] <= LINES2_MATRIX5x8_MODE8bit;
	config_memory[1] <= DISPON_CURSOROFF;
	config_memory[2] <= CLEAR_DISPLAY;

    cgram_addrs[0] <= CGRAM_ADDR0;
    cgram_addrs[1] <= CGRAM_ADDR1;
    cgram_addrs[2] <= CGRAM_ADDR2;
    cgram_addrs[3] <= CGRAM_ADDR3;
    cgram_addrs[4] <= CGRAM_ADDR4;
    cgram_addrs[5] <= CGRAM_ADDR5;
    cgram_addrs[6] <= CGRAM_ADDR6;
    cgram_addrs[7] <= CGRAM_ADDR7;

	 
	 
	 ready_i <= 1;
end

// Divisor de frecuencia
always @(posedge clk) begin
    if (counter_div_freq == COUNT_MAX-1) begin
        clk_16ms <= ~clk_16ms;
        counter_div_freq <= 0;
    end else begin
        counter_div_freq <= counter_div_freq + 1;
    end
end


always @(posedge clk_16ms)begin
    if(rst)begin
        fsm_state <= IDLE;
    end else begin
        fsm_state <= next;
    end
end

always @(*) begin
    case(fsm_state)
        IDLE: begin
            next <= (ready_i)? ((init_config_executed)? CREATE_CHARS : INIT_CONFIG) : IDLE;
        end
        INIT_CONFIG: begin 
            next <= (command_counter == num_commands)? CLEAR_COUNTERS0 : INIT_CONFIG;
        end
        CLEAR_COUNTERS0: begin
            next <= CREATE_CHARS;
        end
        CREATE_CHARS:begin
            next <= (done_cgram_write)? CLEAR_COUNTERS1 : CREATE_CHARS;
        end
        CLEAR_COUNTERS1: begin
            next <= SET_CURSOR_AND_WRITE;
        end
        SET_CURSOR_AND_WRITE: begin 
            next <= (done_lcd_write)? CLEAR_COUNTERS0 : SET_CURSOR_AND_WRITE;
        end
        default: next = IDLE;
    endcase
end

always @(posedge clk_16ms) begin
    if (rst) begin
        command_counter <= 'b0;
        data_counter <= 'b0;
		  data <= 'b0;
        char_counter <= 'b0;
        init_config_executed <= 'b0;
        cgram_addrs_counter <= 'b0;
        done_lcd_write <= 1'b0; 
    end else begin 
	 case (estado)
        3'b000: begin
            $readmemb("Iniciando.txt", data_memory);
        end
        3'b001: begin
            $readmemb("Cara sueno abre.txt", data_memory);
        end
        3'b010: begin
            $readmemb("Cara sonriendo.txt", data_memory);
        end
		  3'b011: begin
            $readmemb("Manzana.txt", data_memory);
        end
		  3'b100: begin
            $readmemb("cara sueno cierra.txt", data_memory);
        end
		  3'b101: begin
            $readmemb("Cruz.txt", data_memory);
        end
		  3'b110: begin
            $readmemb("Balonfutbol.txt", data_memory);
        end
		   3'b111: begin
            $readmemb("RIP.txt", data_memory);
        end	  
    endcase

        case (next)
            IDLE: begin
                char_counter <= 'b0;
                command_counter <= 'b0;
                data_counter <= 'b0;
                rs <= 'b0;
                cgram_addrs_counter <= 'b0;
                done_lcd_write <= 1'b0;
            end
            INIT_CONFIG: begin
                rs <= 'b0;
                command_counter <= command_counter + 1;
					 data <= config_memory[command_counter];
                if(command_counter == num_commands-1) begin
                    init_config_executed <= 1'b1;
                end
            end
            CLEAR_COUNTERS0: begin
                data_counter <= 'b0;
                char_counter <= 'b0;
                create_char_task <= SET_CGRAM_ADDR;
                cgram_addrs_counter <= 'b0;
                done_lcd_write <= 1'b0;
                rs <= 'b0;
                data <= 'b0;
            end
				CREATE_CHARS: begin
					case(create_char_task)
						SET_CGRAM_ADDR: begin
							rs <= 'b0;
							data <= cgram_addrs[cgram_addrs_counter];
							create_char_task <= WRITE_CHARS; 
						end
						WRITE_CHARS: begin
							rs <= 1;
							data <= data_memory[data_counter];
							data_counter <= data_counter + 1;
							if(char_counter == char_data -1) begin
								char_counter = 0;
								if (cgram_addrs_counter == num_cgram_addrs-1) begin
									done_lcd_write <= 1'b0;
								end else begin
									cgram_addrs_counter <= cgram_addrs_counter + 1;
								end
								create_char_task <= SET_CGRAM_ADDR;
							end else begin
								char_counter <= char_counter + 1;
							end
					end
				endcase
			end
				
            CLEAR_COUNTERS1: begin
                data_counter <= 'b0;
                char_counter <= 'b0;
                create_char_task <= SET_CURSOR;
                cgram_addrs_counter <= 8'h80;
            end
            SET_CURSOR_AND_WRITE: begin
					case(create_char_task)
						SET_CURSOR: begin
							rs <= 0;
							data<= cgram_addrs_counter;
							create_char_task <= WRITE_LCD;
						end
						WRITE_LCD: begin
							rs <= 1; 
								case(cgram_addrs_counter) //esta zona pinta la pantalla segun se quiera
									//pinta los dos dibujos, izqierda y derecha
									8'h80:data <= 8'h00;
									8'h91:data <= 8'h00;
									8'h81:data <= 8'h01;
									8'h92:data <= 8'h01;
									8'h82:data <= 8'h02;
									8'h93:data <= 8'h02;
									8'hC0:data <= 8'h03;
									8'hD1:data <= 8'h03;
									8'hC1:data <= 8'h04;
									8'hD2:data <= 8'h04;
									8'hC2:data <= 8'h05;
									8'hD3:data <= 8'h05;
									8'h94:data <= 8'h06;
									8'hA5:data <= 8'h06;
									8'h95:data <= 8'h07;
									8'hA6:data <= 8'h07;
									8'h96:data <= 8'h06;
									8'hA7:data <= 8'h06;
									
									//pinta el indicador de luz
									8'h8E:data <= (luz)?8'h2A:8'hA0;
									8'h8F:data <= (luz)?8'h2A:8'hA0;
									
									//indicador de cercania
									8'hA2:data <= (cercania)?8'hFC:8'hA0;
									8'hA3:data <= (cercania)?8'hFC:8'hA0;
									//indicador de tiempo acelerado
									8'hCE:data <= (fast)?8'h3E:8'hA0;
									8'hCF:data <= (fast)?8'h3E:8'hA0;
									//barra de saciedad
									8'h84:data <= (saciedad > 12)?8'hFF:8'hA0;
									8'hC4:data <= (saciedad > 8)?8'hFF:8'hA0;
									8'h98:data <= (saciedad > 4)?8'hFF:8'hA0;
									8'hD8:data <= (saciedad > 0)?8'hFF:8'hA0;
									
									//barra de diversion
									8'h86:data <= (diversion >12)?8'hFF:8'hA0;
									8'hC6:data <= (diversion> 8)?8'hFF:8'hA0;
									8'h9A:data <= (diversion > 4)?8'hFF:8'hA0;
									8'hDA:data <= (diversion > 0)?8'hFF:8'hA0;
									//barra de descanso
									8'h88:data <= (descanso >12)?8'hFF:8'hA0;
									8'hC8:data <= (descanso > 8)?8'hFF:8'hA0;
									8'h9C:data <= (descanso > 4)?8'hFF:8'hA0;
									8'hDC:data <= (descanso > 0)?8'hFF:8'hA0;
									//barra de salud
									8'h8A:data <= (salud >12)?8'hFF:8'hA0;
									8'hCA:data <= (salud > 8)?8'hFF:8'hA0;
									8'h9E:data <= (salud > 4)?8'hFF:8'hA0;
									8'hDE:data <= (salud > 0)?8'hFF:8'hA0;
									//barra de felicidad
									8'h8C:data <= (felicidad >12)?8'hFF:8'hA0;
									8'hCC:data <= (felicidad > 8)?8'hFF:8'hA0;
									8'hA0:data <= (felicidad > 4)?8'hFF:8'hA0;
									8'hE0:data <= (felicidad > 0)?8'hFF:8'hA0;
									
									default: data<= 8'hA0;
								endcase
								
								if(cgram_addrs_counter == 8'hE7) begin
									done_lcd_write <= 1'b1;
								end else begin
									if(cgram_addrs_counter == 8'hA7)
                                    cgram_addrs_counter <= 8'hC0; //salto
									else cgram_addrs_counter <= cgram_addrs_counter + 1;
								end
								create_char_task <= SET_CURSOR; 
						end
					endcase
				end
       endcase
   end
end

assign enable = clk_16ms;
assign done_cgram_write = (data_counter == num_data_all-1)? 'b1 : 'b0;

endmodule
```
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
```verilog
module control_fsm (
    input wire clk,          // Señal de reloj
    input wire rst,          // Señal de reset
    input wire boton_jugar,  // Botón para jugar
    input wire boton_alimentar,
    input wire boton_dormir,
    input wire boton_curar,
    input wire boton_caricia,
    input wire fast_button,
    output reg [3:0] saciedad,    // Estado de saciedad
    output reg [3:0] diversion,    // Estado de diversión
    output reg [3:0] descanso,    // Estado de descanso
    output reg [3:0] salud,    // Estado de salud
    output reg [3:0] felicidad,   // Estado de felicidad
    output reg [2:0] state,   // Estado actual de la FSM
    output wire [1:0] an,    // Anodos del display de 7 segmentos
    output wire [6:0] sseg  // Segmentos del display de 7 segmentos
);

// Definición de los estados
localparam ESTADO_IDEAL     = 3'b000;
localparam ESTADO_NEUTRO    = 3'b001;
localparam ESTADO_DIVERSION = 3'b010;
localparam ESTADO_ALIMENTAR = 3'b011;
localparam ESTADO_DESCANSO  = 3'b100;
localparam ESTADO_SALUD     = 3'b101;
localparam ESTADO_FELIZ     = 3'b110;
localparam ESTADO_MUERTO	= 3'b111;

reg [31:0] timer;  // Temporizador para control de estados
wire bandera;
reg bandera_prev;

Temporizador7seg temporizador_inst (
    .clk(clk),
    .reset(rst),
    .fast_button(fast_button),
    .an(an),
    .sseg(sseg),
    .bandera(bandera)   // Bandera que se activa cuando el temporizador llega a 0
);
// Inicialización de los estados
initial begin
    saciedad = 4'd15;  // Saciedad al máximo en el estado ideal
    diversion = 4'd15;  // Diversión al máximo en el estado ideal
    descanso = 4'd15;  // Descanso al máximo en el estado ideal
    salud = 4'd15;  // Salud al máximo en el estado ideal
    felicidad = 4'd15; // Felicidad al máximo en el estado ideal
    state = ESTADO_IDEAL;  // Estado inicial
    timer = 32'd0;
	 bandera_prev <= 0;// Temporizador en 0
	 end

// Máquina de estados
always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Resetear todos los valores a sus estados iniciales
        saciedad <= 4'd15;
        diversion <= 4'd15;
        descanso <= 4'd15;
        salud <= 4'd15;
        felicidad <= 4'd15;
        state <= ESTADO_IDEAL;
        timer <= 32'd0;
    end 
	 else begin
        // Actualizar el estado de la FSM
        case (state)
            ESTADO_IDEAL: begin
                // En el estado ideal, todos los valores están al máximo
                saciedad <= 4'd15;
                diversion <= 4'd15;
                descanso <= 4'd15;
                salud <= 4'd15;
                felicidad <= 4'd15;

                // Temporizador para pasar al estado neutro
                if (timer == 250000000) begin  // Temporizador ajustado para simulación rápida
                    state <= ESTADO_NEUTRO;
                    timer <= 31'd0;
                end else begin
                    timer <= timer + 1;
                end
            end

            ESTADO_NEUTRO: begin
                // En el estado neutro, los valores empiezan a bajar lentamente
                if (bandera ) begin  // Temporizador ajustado para simulación rápida
						  if(!bandera_prev)begin
								bandera_prev <= 1;
								saciedad <= (saciedad > 3) ? saciedad - 4 : 0;
								diversion <= (diversion > 3) ? diversion - 4 : 0;
								descanso <= (descanso > 3) ? descanso - 4 : 0;
								salud <= (salud > 3) ? salud - 4 : 0;
								felicidad <= (felicidad > 3) ? felicidad - 4 : 0;
						 end
                end
					 else begin
						if(saciedad == 0 | salud == 0)begin
							state <= ESTADO_MUERTO;
						end
						else begin
						bandera_prev <= 0;
						if (boton_jugar == 1) begin
                    state <= ESTADO_DIVERSION;
						 end
						 else begin
							if (boton_alimentar == 1)begin
								state <= ESTADO_ALIMENTAR;
							end
							else begin
								if(boton_dormir == 0)begin
									state<= ESTADO_DESCANSO;
								end
								else begin
									if(boton_curar == 1)begin
										state <= ESTADO_SALUD;
									end
									else begin
										if (boton_caricia == 1)begin
											state <= ESTADO_FELIZ;
										end
										else begin
											state <= ESTADO_NEUTRO;
										end
									end
								end
							end
							end
						 end
					 end

                
            end

            ESTADO_DIVERSION: begin
					if(timer == 150000000)begin
						timer <= 0;
						// Después de jugar, volver al estado neutro
						state <= ESTADO_NEUTRO;
					end
					else begin
						timer <= timer + 1;
						state <= ESTADO_DIVERSION;
						if(timer == 75000000 | bandera)begin
							// En el estado de diversión, aumentan diversión y felicidad
							diversion <= (diversion < 11) ? diversion + 4 : 15;
							felicidad <= (felicidad < 11) ? felicidad + 4 : 15;
							descanso <= (descanso > 1) ? descanso - 4 : 0;
						end
						if(bandera)begin
							timer <= 0;
							state <= ESTADO_NEUTRO;
						end
					end 
            end
            ESTADO_ALIMENTAR: begin
					 if(timer == 150000000)begin
						timer <= 0;
						// Después de jugar, volver al estado neutro
						state <= ESTADO_NEUTRO;
					end
					else begin
						timer <= timer + 1;
						state <= ESTADO_ALIMENTAR;
						if(timer == 75000000 | bandera)begin
							saciedad <= (saciedad<11)?saciedad+4:15;  // Aumentar saciedad al alimentar
						end
						if(bandera)begin
							timer <= 0;
							state <= ESTADO_NEUTRO;
						end
					end 
                
            end
            ESTADO_DESCANSO: begin
                if(timer == 150000000)begin
						timer <= 0;
						state <= ESTADO_NEUTRO;
					end
					else begin
						timer <= timer + 1;
						state <= ESTADO_DESCANSO;
						if(timer == 75000000 | bandera)begin
							descanso <= (descanso < 11)?descanso + 4:15;
						end
						if(bandera)begin
							timer <= 0;
							state <= ESTADO_NEUTRO;
						end
					end 
            end
            ESTADO_SALUD: begin
                if(timer == 150000000)begin
						timer <= 0;
						state <= ESTADO_NEUTRO;
					end
					else begin
						timer <= timer + 1;
						state <= ESTADO_SALUD;
						if(timer == 75000000 | bandera)begin
							salud <= (salud < 11)? salud + 4:15;
						end
						if(bandera)begin
							timer <= 0;
							state <= ESTADO_NEUTRO;
						end
					end 

            end
            ESTADO_FELIZ: begin 	
					 if(timer == 150000000)begin
						timer <= 0;
						state <= ESTADO_NEUTRO;
					end
					else begin
						timer <= timer + 1;
						state <= ESTADO_FELIZ;
						if(timer == 75000000 | bandera)begin
							felicidad <=(felicidad < 11)?felicidad+4:15;
						end
						if(bandera)begin
							timer <= 0;
							state <= ESTADO_NEUTRO;
						end
					end 
					 
            end
				ESTADO_MUERTO:begin
					saciedad <= 0;
					salud <= 0;
					felicidad <= 0;
					descanso <= 0;
					diversion <= 0;
					state <= ESTADO_MUERTO;
				end
            default: begin
                // Por defecto, regresar al estado ideal xd nunca entra aca :V sdlg
                state <= ESTADO_IDEAL;
            end
        endcase
    end
end

endmodule
```
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
```verilog
module TamaguchiUpdateNewPro(
	input boton_jugar,
    input boton_alimentar,
    input sensor_luz,
    input boton_curar,
    input echo,
	input rst_neg,
	input clk,
	input boton_acelerar,
//  input boton_test,
	 
	 output trigger,
	 output [6:0] segment,
	 output [1:0] anodos,
	 
	 output rs,        
    output rw,
    output enable,    
    output [7:0] data,
	 output prb
);

assign rst = ~rst_neg;
assign prb = boton_acelerar;
wire bandera_iluminacion;
wire object_detected;

wire[3:0] saciedad;    // Estado de saciedad
wire[3:0] diversion;    // Estado de diversión
wire[3:0] descanso;    // Estado de descanso
wire[3:0] salud;    // Estado de salud
wire[3:0] felicidad;   // Estado de felicidad
wire[2:0] state;
	 
sensor_luz fnsba(
	.LDR_signal(sensor_luz),
	.sensor(bandera_iluminacion)
);

control_fsm modulo_principal(
	.clk(clk),
	.rst(rst),
	.boton_jugar(boton_jugar),
	.boton_alimentar(boton_alimentar),
	.boton_curar(boton_curar),
	.boton_dormir(!bandera_iluminacion),
	.boton_caricia(object_detected),
	.fast_button(boton_acelerar),
	.saciedad(saciedad),
	.diversion(diversion),
	.descanso(descanso),
	.salud(salud),
	.felicidad(felicidad),
	.state(state),
	.an(anodos),
	.sseg(segment)
);


UltrasonicSensor dhaissdnas(
	.clk(clk),
	.trigger(trigger),
	.echo(echo),
	.object_detected(object_detected)
);

visualizacion_personalizada diahdias(
	.clk(clk),
	.rst(rst),
	.estado(state),
	.saciedad(saciedad),
	.diversion(diversion),
	.descanso(descanso),
	.salud(salud),
	.felicidad(felicidad),
	.luz(!bandera_iluminacion),
	.cercania(object_detected),
	.fast(boton_acelerar),
	.rs(rs),
	.rw(rw),
	.enable(enable),
	.data(data)
);
endmodule
```
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

# 3. Resultado final (video funcionamiento del tamagotchi)
Debido a que el video supera el límite de Mb que permite subir github, se anexa enlace a YouTube.
https://youtu.be/yGnoxMfuyR8

**Video comprimido (baja resolución):**
https://github.com/user-attachments/assets/24296551-ab1f-40aa-8229-70826c067567

# 4. Conclusiones:
De acuerdo a los requerimientos planteados, a nuestros diseño y especificaciones hechos inicialmente, y gracias a nuestra capacidad de trabajo en equipo, podemos concluir que el proyecto fue llevado a cabo con satisfaccion y que los resultados fueron los esperados
