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