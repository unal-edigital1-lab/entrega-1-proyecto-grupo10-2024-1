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