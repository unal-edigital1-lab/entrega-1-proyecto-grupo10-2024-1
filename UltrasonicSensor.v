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