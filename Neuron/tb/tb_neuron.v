`timescale 1ns / 1ps

module tb_neuron_Nbits;

  localparam TB_WIDTH = 8;

  reg clk;
  reg rst;
  reg en;
  reg signed [TB_WIDTH-1:0] w, x;
  wire signed [TB_WIDTH-1:0] neuron_out;

  // DUT
  neuron_Nbits #(
      .N(TB_WIDTH)
  ) dut (
      .clk(clk),
      .rst(rst),
      .en (en),
      .W  (w),
      .X  (x),
    .Out(neuron_out)
  );

  // Clock: 10 ns period
  initial clk = 0;
  always #5 clk = ~clk;

  // Função auxiliar para testar
  task check;
    input signed [TB_WIDTH-1:0] expected;
    input [127:0] msg;
    begin
      if (neuron_out !== expected)
        $error("(%s): esperado = %0d, obtido = %0d (t = %0t)", msg, expected, neuron_out, $time);
      else $display("OK (%s): valor = %0d (t = %0t)", msg, neuron_out, $time);
      msg = 0;
    end
  endtask

  // Descomentar se quiser mais informação durante a execução da TB
  // Monitor  
// 	initial begin
//     	$monitor("t=%0t | rst=%b en=%b w=%d x=%d out=%d", $time, rst, en, w, x, neuron_out);
//     end

  // Estímulos
  
  initial begin
    $dumpfile("tb_neuron_Nbits.vcd");
    $dumpvars;

    // Inicialização
    rst = 0;
    en  = 0;
    w   = 0;
    x   = 0;
    #7 rst = 1;  // libera reset antes do próximo posedge

    // Caso 1: acumular por 2 ciclos negativo---------
    // 1º ciclo: w=-3, x=2

    #3;
    w  = -3;
    x  = 2;
    en = 1;
    #10;
    check(0, "Primeiro ciclo n");

    // 2º ciclo: w=5, x=-4
    w = 5;
    x = -4;
    #10;
    check(0, "Segundo ciclo n");
    
    // Caso 2: Reset ativo durante a operação ---------
    rst = 0;
    en  = 0;
    w   = 0;
    x   = 0;
    
    #10;
    check(0, "Teste reset");
    rst = 1;  // libera reset
    en  = 1;
    #10;
    // Caso 2: acumular por 2 ciclos positivo ---------
    // 1º ciclo: w=3, x=2
    w  = 64;
    x  = 2;
    #10;
    check(0, "Primeiro ciclo p");

    // 2º ciclo: w=5, x=4
    w = 64;
    x = 2;
    #10;
    check(1, "Segundo ciclo p");

    // Caso 3: enable desligado (não acumula) ---------
    en = 0;
    #5;
    w = 8;
    x = 4;
	
    #10;
    check(1, "Teste Enable");
    #20;

    $finish;
  end

endmodule
