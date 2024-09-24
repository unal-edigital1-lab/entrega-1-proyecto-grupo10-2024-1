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