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