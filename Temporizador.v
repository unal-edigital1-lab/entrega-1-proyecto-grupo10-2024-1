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